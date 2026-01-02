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
    
    private let eventSubject = PassthroughSubject<GameEvent, Never>()
    var eventPublisher: AnyPublisher<GameEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    private var currentUserId: String = "1"
    private var currentUserName: String = ""
    private var currentKeyword: String = ""
    private var users: [User] = []
    private var videoCallTimer: Timer?
    
    // MARK: - GameRepositoryProtocol
    
    func joinRoom(keyword: String, userName: String) async throws {
        self.currentKeyword = keyword
        self.currentUserName = userName
        
        // 自分を追加
        let myUser = User(id: currentUserId, name: userName, isReady: false)
        users.append(myUser)
        eventSubject.send(.userJoined(myUser))
        
        // シミュレーション: 1秒後に他のユーザーが参加
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            let mockUsers = [
                User(id: "2", name: "太郎", isReady: true),
                User(id: "3", name: "花子", isReady: true),
                User(id: "4", name: "次郎", isReady: true)
            ]
            
            for user in mockUsers {
                self.users.append(user)
                self.eventSubject.send(.userJoined(user))
            }
        }
    }
    
    func leaveRoom() async throws {
        users.removeAll()
        videoCallTimer?.invalidate()
        videoCallTimer = nil
    }
    
    func toggleReady() async throws {
        // 自分の準備状態を切り替え
        if let index = users.firstIndex(where: { $0.id == currentUserId }) {
            users[index].isReady.toggle()
            let isReady = users[index].isReady
            
            eventSubject.send(.userReadyStateChanged(userId: currentUserId, isReady: isReady))
            
            // 全員が準備完了したら役職を割り当て
            if users.allSatisfy({ $0.isReady }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.assignRoles()
                }
            }
        }
    }
    
    func toggleMute(isMuted: Bool) async throws {
        if let index = users.firstIndex(where: { $0.id == currentUserId }) {
            users[index].isMuted = isMuted
            eventSubject.send(.userMuteStateChanged(userId: currentUserId, isMuted: isMuted))
        }
    }
    
    func submitAnswer(userId: String) async throws {
        // 回答を送信
        eventSubject.send(.answerSubmitted(userId: currentUserId, selectedUserId: userId))
        
        // シミュレーション: 0.5秒後に結果を発表
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.revealAnswers(myAnswer: userId)
        }
    }
    
    func resetGame() async throws {
        users.removeAll()
        videoCallTimer?.invalidate()
        videoCallTimer = nil
        eventSubject.send(.gameReset)
    }
    
    // MARK: - Private Methods
    
    private func assignRoles() {
        // ランダムに1人を人狼に選ぶ
        let werewolfIndex = Int.random(in: 0..<users.count)
        
        for (index, _) in users.enumerated() {
            let role: Role = (index == werewolfIndex) ? .werewolf : .villager
            users[index].role = role
        }
        
        let swappedUserId = users[werewolfIndex].id
        
        // 役職割り当てイベントを送信
        eventSubject.send(.rolesAssigned(users: users, swappedUserId: swappedUserId))
        
        // シミュレーション: 5秒後にビデオ通話開始
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.startVideoCall(swappedUserId: swappedUserId)
        }
    }
    
    private func startVideoCall(swappedUserId: String) {
        eventSubject.send(.videoCallStarted)
        
        var timeRemaining = 10
        videoCallTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.eventSubject.send(.videoCallCountdown(timeRemaining: timeRemaining))
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                self.videoCallTimer = nil
                self.eventSubject.send(.answerPhaseStarted)
            }
        }
    }
    
    private func revealAnswers(myAnswer: String) {
        // 人狼のIDを取得
        guard let werewolf = users.first(where: { $0.role == .werewolf }) else {
            return
        }
        let swappedUserId = werewolf.id
        
        // 全員の回答を生成
        var allAnswers: [PlayerAnswer] = []
        
        for user in users {
            if user.id == currentUserId {
                // 自分の回答
                let isCorrect = (myAnswer == swappedUserId)
                allAnswers.append(PlayerAnswer(
                    id: user.id,
                    playerName: user.name,
                    selectedUserId: myAnswer,
                    isCorrect: isCorrect
                ))
            } else {
                // ダミーの回答（ランダム）
                let otherUsers = users.filter { $0.id != user.id }
                let randomAnswer = otherUsers.randomElement()?.id
                let isCorrect = (randomAnswer == swappedUserId)
                
                allAnswers.append(PlayerAnswer(
                    id: user.id,
                    playerName: user.name,
                    selectedUserId: randomAnswer,
                    isCorrect: isCorrect
                ))
            }
        }
        
        // 結果発表イベントを送信
        eventSubject.send(.answerRevealed(answers: allAnswers, swappedUserId: swappedUserId))
    }
}
