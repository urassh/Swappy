//
//  MockGameRepository.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import Foundation
import Combine

/// 開発・テスト用のモックGameRepository実装
/// 現在のGameViewModelのダミーロジックを移行
class MockGameRepository: GameRepositoryProtocol {
    // MARK: - Properties
    
    // イベントハンドラ
    private var onUserJoined: ((User) -> Void)?
    private var onUserLeft: ((User) -> Void)?
    private var onUserReadyStateChanged: ((User, Bool) -> Void)?
    private var onUserMuteStateChanged: ((User, Bool) -> Void)?
    private var onGameStarted: (() -> Void)?
    private var onRolesAssigned: (([User]) -> Void)?
    private var onAnswerSubmitted: ((PlayerAnswer) -> Void)?
    private var onError: ((String) -> Void)?

    private var currentKeyword: String = ""
    private var joinTask: Task<Void, Never>?
    private var pendingReadyUserIDs = Set<UUID>()
    private static var rooms: [String: [User]] = [:]  // keyword -> users
    
    // MARK: - Computed Properties
    
    private var users: [User] {
        get { Self.rooms[currentKeyword] ?? [] }
        set { Self.rooms[currentKeyword] = newValue }
    }
    
    // MARK: - GameRepositoryProtocol
    
    func setEventHandlers(
        onUserJoined: @escaping (User) -> Void,
        onUserLeft: @escaping (User) -> Void,
        onUserReadyStateChanged: @escaping (User, Bool) -> Void,
        onUserMuteStateChanged: @escaping (User, Bool) -> Void,
        onGameStarted: @escaping () -> Void,
        onRolesAssigned: @escaping ([User]) -> Void,
        onAnswerSubmitted: @escaping (PlayerAnswer) -> Void,
        onError: @escaping (String) -> Void
    ) {
        self.onUserJoined = onUserJoined
        self.onUserLeft = onUserLeft
        self.onUserReadyStateChanged = onUserReadyStateChanged
        self.onUserMuteStateChanged = onUserMuteStateChanged
        self.onGameStarted = onGameStarted
        self.onRolesAssigned = onRolesAssigned
        self.onAnswerSubmitted = onAnswerSubmitted
        self.onError = onError
    }
    
    func joinRoom(keyword: String, me: User) {
        self.currentKeyword = keyword
        
        // ルームが存在しない場合は初期化
        if Self.rooms[keyword] == nil {
            Self.rooms[keyword] = []
        }
        
        // BackEndのシミュレーション開始（自分の参加 + 他のユーザー参加）
        simulateJoinRoom(me: me)
    }
    
    func leaveRoom(me: User) {
        simulateLeaveRoom(me: me)
    }
    
    func completeCallReady(me: User) {
        simulateCompleteCallReady(me: me)
    }
    
    func startGame() {
        simulateStartGame()
    }
    
    func toggleMute(me: User, isMuted: Bool) {
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
            
            await MainActor.run {
                guard let index = self.users.indices.first else { return }
                
                self.users[index].isMuted = isMuted
                self.onUserMuteStateChanged?(self.users[index], isMuted)
            }
        }
    }
    
    func submitAnswer(me: User, selectedUser: User) {
        simulateSubmitAnswer(me: me, selectedUser: selectedUser)
    }
    
    func resetGame() {
        simulateResetGame()
    }
    
    // MARK: - Private Methods
    
    private func assignRoles() {
        // ランダムに1人を人狼に選ぶ
        let werewolfIndex = Int.random(in: 0..<users.count)
        
        for (index, user) in users.enumerated() {
            let role: Role = (index == werewolfIndex) ? .werewolf : .villager
            users[index].role = role
        }
                
        // 役職割り当てイベントを送信
        onRolesAssigned?(users)
    }
    
    // MARK: - Backend Simulation
    
    /// ルーム参加のシミュレーション（自分 + 他のユーザー）
    private func simulateJoinRoom(me: User) {
        joinTask?.cancel()
        joinTask = Task {
            // 通信時間をシミュレート（0.5秒）
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                var joiningUser = me
                if self.pendingReadyUserIDs.contains(me.id) {
                    joiningUser.isReady = true
                    self.pendingReadyUserIDs.remove(me.id)
                }
                self.users.append(joiningUser)
                self.onUserJoined?(joiningUser)
            }
            
            // 他のユーザーの参加（3秒後）
            try? await Task.sleep(nanoseconds: 2_500_000_000) // 残り2.5秒
            guard !Task.isCancelled else { return }
            
            let mockUsers = [
                User(name: "太郎", isReady: true),
                User(name: "花子", isReady: true),
                User(name: "次郎", isReady: true)
            ]
            
            for user in mockUsers {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.users.append(user)
                    self.onUserJoined?(user)
                }
            }
        }
    }
    
    /// ルーム退出のシミュレーション
    private func simulateLeaveRoom(me: User) {
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒
            
            await MainActor.run {
                let keyword = self.currentKeyword
                self.currentKeyword = ""
                self.joinTask?.cancel()
                self.joinTask = nil
                self.pendingReadyUserIDs.removeAll()
                if !keyword.isEmpty {
                    Self.rooms[keyword] = nil
                }
                self.onUserLeft?(me)
            }
        }
    }
    
    /// 準備完了のシミュレーション
    private func simulateCompleteCallReady(me: User) {
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
            
            await MainActor.run {
                // 自分の準備状態を更新
                if let index = self.users.firstIndex(where: { $0.id == me.id }) {
                    self.users[index].isReady = true
                    self.onUserReadyStateChanged?(self.users[index], true)
                } else {
                    self.pendingReadyUserIDs.insert(me.id)
                }
            }
        }
    }
    
    /// ゲーム開始のシミュレーション
    private func simulateStartGame() {
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒
            
            await MainActor.run {
                // ゲーム開始イベントを送信
                self.onGameStarted?()
                
                // 役職を割り当て
                Task {
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
                    await MainActor.run {
                        self.assignRoles()
                    }
                }
            }
        }
    }

    /// 回答送信のシミュレーション
    private func simulateSubmitAnswer(me: User, selectedUser: User) {
        Task {
            // 人狼を取得
            guard let werewolf = await MainActor.run(body: { self.users.first(where: { $0.role == .werewolf }) }) else {
                return
            }
            
            // 自分の回答を送信
            await MainActor.run {
                let myAnswer = PlayerAnswer(
                    answer: me,
                    selectedUser: selectedUser,
                    isCorrect: selectedUser.id == werewolf.id
                )
                self.onAnswerSubmitted?(myAnswer)
            }
            
            // 他のプレイヤーの回答をシミュレート（1-3秒後）
            for otherUser in users.filter({ $0.id != me.id }) {
                let delay = UInt64.random(in: 1_000_000_000...3_000_000_000)
                try? await Task.sleep(nanoseconds: delay)
                
                await MainActor.run {
                    // ダミーの回答（ランダム）
                    let otherUsers = self.users.filter { $0.id != otherUser.id }
                    let randomSelectedUser = otherUsers.randomElement()!
                    let answer = PlayerAnswer(
                        answer: otherUser,
                        selectedUser: randomSelectedUser,
                        isCorrect: randomSelectedUser.id == werewolf.id
                    )
                    self.onAnswerSubmitted?(answer)
                }
            }
        }
    }
    
    /// ゲームリセットのシミュレーション
    private func simulateResetGame() {
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒
            
            await MainActor.run {
                if !self.currentKeyword.isEmpty {
                    Self.rooms[self.currentKeyword] = nil
                }
            }
        }
    }
}
