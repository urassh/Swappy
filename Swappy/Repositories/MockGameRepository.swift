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
    private var onUserMuteStateChanged: ((String, Bool) -> Void)?
    private var onRolesAssigned: (([String: Role], String) -> Void)?
    private var onAnswerRevealed: (([PlayerAnswer]) -> Void)?
    private var onError: ((String) -> Void)?

    private var currentKeyword: String = ""
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
        onUserMuteStateChanged: @escaping (String, Bool) -> Void,
        onRolesAssigned: @escaping ([String: Role], String) -> Void,
        onAnswerRevealed: @escaping ([PlayerAnswer]) -> Void,
        onError: @escaping (String) -> Void
    ) {
        self.onUserJoined = onUserJoined
        self.onUserLeft = onUserLeft
        self.onUserReadyStateChanged = onUserReadyStateChanged
        self.onUserMuteStateChanged = onUserMuteStateChanged
        self.onRolesAssigned = onRolesAssigned
        self.onAnswerRevealed = onAnswerRevealed
        self.onError = onError
    }
    
    func joinRoom(keyword: String, me: User) async throws {
        self.currentKeyword = keyword
        
        // ルームが存在しない場合は初期化
        if Self.rooms[keyword] == nil {
            Self.rooms[keyword] = []
        }
        
        // 自分を追加
        users.append(me)
        onUserJoined?(me)
        
        // シミュレーション: 3秒後に他のユーザーが参加
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            
            let mockUsers = [
                User(id: "2", name: "太郎", isReady: true),
                User(id: "3", name: "花子", isReady: true),
                User(id: "4", name: "次郎", isReady: true)
            ]
            
            for user in mockUsers {
                self.users.append(user)
                self.onUserJoined?(user)
            }
        }
    }
    
    func leaveRoom() async throws {
        if !currentKeyword.isEmpty {
            Self.rooms[currentKeyword] = nil
        }
    }
    
    func completeCallReady(me: User) async throws {
        // 自分の準備状態を切り替え
        if let index = users.firstIndex(where: { $0.id == me.id }) {
            users[index].isReady.toggle()
            let user = users[index]
            
            onUserReadyStateChanged?(user, user.isReady)
            
            // 全員が準備完了したら役職を割り当て
            if users.allSatisfy({ $0.isReady }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.assignRoles()
                }
            }
        }
    }
    
    func toggleMute(me: User, isMuted: Bool) async throws {
        if let index = users.firstIndex(where: { $0.id == me.id }) {
            users[index].isMuted = isMuted
            onUserMuteStateChanged?(me.id, isMuted)
        }
    }
    
    func submitAnswer(me: User, selectUserId: String) async throws {
        // シミュレーション: 5秒後に結果を発表
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self = self else { return }
            
            // 人狼を取得
            guard let werewolf = self.users.first(where: { $0.role == .werewolf }) else {
                return
            }
            
            // 全員の回答を生成
            var allAnswers: [PlayerAnswer] = []
            
            for user in self.users {
                if user.id == me.id {
                    // 自分の回答
                    let isCorrect = (selectUserId == werewolf.id)
                    allAnswers.append(PlayerAnswer(
                        id: user.id,
                        playerName: user.name,
                        selectedUserId: selectUserId,
                        isCorrect: isCorrect
                    ))
                } else {
                    // ダミーの回答（ランダム）
                    let otherUsers = self.users.filter { $0.id != user.id }
                    let randomAnswer = otherUsers.randomElement()?.id
                    let isCorrect = (randomAnswer == werewolf.id)
                    
                    allAnswers.append(PlayerAnswer(
                        id: user.id,
                        playerName: user.name,
                        selectedUserId: randomAnswer,
                        isCorrect: isCorrect
                    ))
                }
            }
            
            // 結果発表イベントを送信
            self.onAnswerRevealed?(allAnswers)
        }
    }
    
    func resetGame() async throws {
        if !currentKeyword.isEmpty {
            Self.rooms[currentKeyword] = nil
        }
    }
    
    // MARK: - Private Methods
    
    private func assignRoles() {
        // ランダムに1人を人狼に選ぶ
        let werewolfIndex = Int.random(in: 0..<users.count)
        
        var userRoles: [String: Role] = [:]
        for (index, user) in users.enumerated() {
            let role: Role = (index == werewolfIndex) ? .werewolf : .villager
            users[index].role = role
            userRoles[user.id] = role
        }
        
        let swappedUserId = users[werewolfIndex].id
        
        // 役職割り当てイベントを送信
        onRolesAssigned?(userRoles, swappedUserId)
    }
}
