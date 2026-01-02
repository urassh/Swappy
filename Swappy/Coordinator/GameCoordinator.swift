//
//  GameCoordinator.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import Foundation
import SwiftUI
import AgoraRtcKit

/// ゲーム全体のナビゲーションと共有データを管理するCoordinator
@Observable
class GameCoordinator {
    
    // MARK: - Navigation State
    
    var currentScreen: ScreenState = .keywordInput
    
    // MARK: - Shared Data
    
    var users: [User] = []
    var swappedUserId: String? = nil
    var allAnswers: [PlayerAnswer] = []
    var myUserId: String = "1"  // 現在のユーザーID（将来的にはBackendから取得）
    
    // MARK: - Dependencies
    
    let gameRepository: GameRepositoryProtocol
    private(set) var agoraManager: AgoraManager?
    
    // MARK: - Private Properties
    
    private let appId = "test-mode"
    
    // MARK: - Initialization
    
    init(gameRepository: GameRepositoryProtocol = MockGameRepository()) {
        self.gameRepository = gameRepository
        setupEventHandlers()
    }
    
    // MARK: - Event Handlers Setup
    
    private func setupEventHandlers() {
        gameRepository.setEventHandlers(
            onUserJoined: { [weak self] user in
                DispatchQueue.main.async {
                    self?.handleUserJoined(user)
                }
            },
            onUserLeft: { [weak self] userId in
                DispatchQueue.main.async {
                    self?.handleUserLeft(userId)
                }
            },
            onUserReadyStateChanged: { [weak self] userId, isReady in
                DispatchQueue.main.async {
                    self?.handleUserReadyStateChanged(userId: userId, isReady: isReady)
                }
            },
            onUserMuteStateChanged: { [weak self] userId, isMuted in
                DispatchQueue.main.async {
                    self?.handleUserMuteStateChanged(userId: userId, isMuted: isMuted)
                }
            },
            onRolesAssigned: { [weak self] userRoles, swappedUserId in
                DispatchQueue.main.async {
                    self?.handleRolesAssigned(userRoles: userRoles, swappedUserId: swappedUserId)
                }
            },
            onVideoCallStarted: { [weak self] in
                DispatchQueue.main.async {
                    self?.handleVideoCallStarted()
                }
            },
            onVideoCallCountdown: { timeRemaining in
                // VideoCallViewModelで処理するため、ここでは何もしない
                print("⏱️ Video call countdown: \(timeRemaining)")
            },
            onAnswerPhaseStarted: { [weak self] in
                DispatchQueue.main.async {
                    self?.handleAnswerPhaseStarted()
                }
            },
            onAnswerSubmitted: { userId, selectedUserId in
                // 特に処理なし
                print("📝 Answer submitted: \(userId) -> \(selectedUserId)")
            },
            onAnswerRevealed: { [weak self] answers, swappedUserId in
                DispatchQueue.main.async {
                    self?.handleAnswerRevealed(answers: answers, swappedUserId: swappedUserId)
                }
            },
            onGameReset: { [weak self] in
                DispatchQueue.main.async {
                    self?.handleGameReset()
                }
            },
            onError: { [weak self] message in
                DispatchQueue.main.async {
                    self?.handleError(message)
                }
            }
        )
    }
    
    // MARK: - Event Handlers
    
    private func handleUserJoined(_ user: User) {
        if !users.contains(where: { $0.id == user.id }) {
            users.append(user)
        }
    }
    
    private func handleUserLeft(_ userId: String) {
        users.removeAll { $0.id == userId }
    }
    
    private func handleUserReadyStateChanged(userId: String, isReady: Bool) {
        if let index = users.firstIndex(where: { $0.id == userId }) {
            users[index].isReady = isReady
        }
    }
    
    private func handleUserMuteStateChanged(userId: String, isMuted: Bool) {
        if let index = users.firstIndex(where: { $0.id == userId }) {
            users[index].isMuted = isMuted
        }
    }
    
    private func handleRolesAssigned(userRoles: [String: Role], swappedUserId: String) {
        // 各ユーザーにロールを割り当て
        for (userId, role) in userRoles {
            if let index = users.firstIndex(where: { $0.id == userId }) {
                users[index].role = role
            }
        }
        self.swappedUserId = swappedUserId
        navigate(to: .roleReveal)
    }
    
    private func handleVideoCallStarted() {
        navigate(to: .videoCall)
    }
    
    private func handleAnswerPhaseStarted() {
        navigate(to: .answerInput)
    }
    
    private func handleAnswerRevealed(answers: [PlayerAnswer], swappedUserId: String) {
        self.allAnswers = answers
        self.swappedUserId = swappedUserId
        navigate(to: .answerReveal)
    }
    
    private func handleGameReset() {
        cleanupAgoraManager()
        
        users = []
        swappedUserId = nil
        allAnswers = []
        
        navigate(to: .keywordInput)
    }
    
    private func handleError(_ message: String) {
        print("❌ Game error: \(message)")
        // TODO: ユーザーにエラーを表示
    }
    
    // MARK: - Navigation
    
    func navigate(to screen: ScreenState) {
        currentScreen = screen
    }
    
    // MARK: - Public Methods
    
    /// ルームに参加
    func enterRoom(keyword: String, userName: String) {
        navigate(to: .robby)
        
        // Agora Managerをセットアップ
        setupAgoraManager()
        
        // Agoraチャンネルに参加
        Task {
            do {
                try await agoraManager?.joinChannel(keyword, uid: 0, role: "publisher")
                print("🎤 Joined voice channel: \(keyword)")
            } catch {
                print("❌ Failed to join Agora channel: \(error)")
            }
        }
        
        // GameRepositoryを通じてルームに参加
        Task {
            do {
                try await gameRepository.joinRoom(keyword: keyword, userName: userName)
            } catch {
                print("❌ Failed to join game room: \(error)")
            }
        }
    }
    
    /// ゲームをリセット
    func resetGame() {
        Task {
            do {
                try await gameRepository.resetGame()
            } catch {
                print("❌ Failed to reset game: \(error)")
            }
        }
    }
    
    // MARK: - Agora Management
    
    private func setupAgoraManager() {
        let tokenRepository = AgoraTestTokenRepository()
        
        let builder = AgoraManagerBuilder(appId: appId, tokenRepository: tokenRepository)
        agoraManager = builder
            .withAudio(delegate: nil)
            .withChannelDelegate(AgoraCoordinatorDelegate(coordinator: self))
            .build()
    }
    
    private func cleanupAgoraManager() {
        agoraManager?.leaveChannel()
        agoraManager = nil
    }
    
    // MARK: - Computed Properties
    
    var myUser: User? {
        users.first(where: { $0.id == myUserId })
    }
    
    var myRole: Role? {
        myUser?.role
    }
}

// MARK: - Agora Delegate Adapter

/// AgoraのイベントをCoordinatorに橋渡しするアダプター
private class AgoraCoordinatorDelegate: ChannelEventDelegate {
    weak var coordinator: GameCoordinator?
    
    init(coordinator: GameCoordinator) {
        self.coordinator = coordinator
    }
    
    func didJoinChannel(uid: UInt) {
        print("✅ Successfully joined Agora channel with uid: \(uid)")
    }
    
    func didUserJoin(uid: UInt) {
        print("👤 User joined Agora: \(uid)")
    }
    
    func didUserLeave(uid: UInt) {
        print("👋 User left Agora: \(uid)")
    }
    
    func didLeaveChannel() {
        print("📤 Left Agora channel")
    }
    
    func didOccurError(code: AgoraErrorCode) {
        print("❌ Agora error: \(code.rawValue)")
    }
}
