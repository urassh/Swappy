//
//  GameCoordinator.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import Foundation
import SwiftUI
import AgoraRtcKit
import Combine

/// ゲーム全体のナビゲーションと共有データを管理するCoordinator
@Observable
class GameCoordinator {
    
    // MARK: - Navigation State
    
    var currentScreen: ScreenState = .keywordInput
    
    // MARK: - Shared Data
    
    var users: [User] = [] {
        didSet {
            usersSubject.send(users)
        }
    }
    
    private let usersSubject = CurrentValueSubject<[User], Never>([])
    var usersPublisher: AnyPublisher<[User], Never> {
        usersSubject.eraseToAnyPublisher()
    }
    
    var allAnswers: [PlayerAnswer] = [] {
        didSet {
            allAnswersSubject.send(allAnswers)
            // 全員の回答が揃ったらAnswerRevealに遷移
            if allAnswers.count == users.count && currentScreen == .answerWaiting {
                navigate(to: .answerReveal)
            }
        }
    }
    
    private let allAnswersSubject = CurrentValueSubject<[PlayerAnswer], Never>([])
    var allAnswersPublisher: AnyPublisher<[PlayerAnswer], Never> {
        allAnswersSubject.eraseToAnyPublisher()
    }
    
    var me: User? = nil
    var wolfUser: User? {
        users.first(where: { $0.role == .werewolf })
    }

    let gameRepository: GameRepositoryProtocol
    private(set) var agoraManager: AgoraManager?
    
    
    private let appId = "test-mode"
    
    
    init(gameRepository: GameRepositoryProtocol = MockGameRepository()) {
        self.gameRepository = gameRepository
        setupEventHandlers()
    }
    
    func navigate(to screen: ScreenState) {
        currentScreen = screen
    }
    
    // MARK: - Agora Management
    
    private func setupAgoraManager() {
        let tokenRepository = AgoraTestTokenRepository()
        
        let builder = AgoraManagerBuilder(appId: appId, tokenRepository: tokenRepository)
        agoraManager = builder
            .withAudio(delegate: nil)
            .withChannelDelegate(self)
            .build()
    }
    
    private func cleanupAgoraManager() {
        agoraManager?.leaveChannel()
        agoraManager = nil
    }
}

// MARK: - Publish GameEvent(WebSocet)
extension GameCoordinator {
    /// ルームに参加
    func joinRoom(keyword: String, userName: String) {
        navigate(to: .robby)
        
        self.me = User(name: userName)
        
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
        gameRepository.joinRoom(keyword: keyword, me: self.me!)
    }
    
    func leaveRoom() {
        guard let me = me else { return }
        cleanupAgoraManager()
        gameRepository.leaveRoom(me: me)
        users = []
        allAnswers = []
        self.me = nil
    }
    
    /// 準備状態を完了状態にする
    private func completeCallReady() {
        // 楽観的更新: まず自分の状態を更新
        self.me!.isReady = true
        
        // users内の自分も更新
        if let index = users.firstIndex(where: { $0.id == self.me!.id }) {
            users[index].isReady = true
        }
        
        // Repositoryに送信（イベントハンドラで最終的な状態を受け取る）
        gameRepository.completeCallReady(me: self.me!)
    }
    
    /// ミュート状態をトグル
    func toggleMute(isMuted: Bool) {
        // Agoraのミュート状態を変更
        if isMuted {
            agoraManager?.audio?.mute()
        } else {
            agoraManager?.audio?.unmute()
        }
        
        // 楽観的更新: まず自分の状態を更新
        self.me!.isMuted = isMuted
        
        // users内の自分も更新
        if let index = users.firstIndex(where: { $0.id == self.me!.id }) {
            users[index].isMuted = isMuted
        }
        
        // Repositoryに送信（イベントハンドラで最終的な状態を受け取る）
        gameRepository.toggleMute(me: self.me!, isMuted: isMuted)
    }
    
    /// ゲームを開始
    func startGame() {
        gameRepository.startGame()
        navigate(to: .roleWaiting)
    }
    
    func startVideoCall() {
        navigate(to: .videoCall)
    }
    
    func startAnswerInput() {
        navigate(to: .answerInput)
    }
    
    func submitAnswer(selectUser: User) {
        // Repositoryに送信
        gameRepository.submitAnswer(me: self.me!, selectedUser: selectUser)
        
        // 回答待機画面に遷移
        navigate(to: .answerWaiting)
    }

    /// ゲームをリセット
    func resetGame() {
        gameRepository.resetGame()
    }
    
}

// MARK: - Subscribe GameEvent(WebSocket)
extension GameCoordinator {
    // MARK: - Event Handlers Setup
    private func setupEventHandlers() {
        gameRepository.setEventHandlers(
            onUserJoined: { [weak self] user in
                DispatchQueue.main.async {
                    self?.handleUserJoined(user)
                }
            },
            onUserLeft: { [weak self] user in
                DispatchQueue.main.async {
                    self?.handleUserLeft(user)
                }
            },
            onUserReadyStateChanged: { [weak self] user, isReady in
                DispatchQueue.main.async {
                    self?.handleUserReadyStateChanged(user: user, isReady: isReady)
                }
            },
            onUserMuteStateChanged: { [weak self] user, isMuted in
                DispatchQueue.main.async {
                    self?.handleUserMuteStateChanged(user: user, isMuted: isMuted)
                }
            },
            onGameStarted: { [weak self] in
                DispatchQueue.main.async {
                    self?.handleGameStarted()
                }
            },
            onRolesAssigned: { [weak self] users in
                DispatchQueue.main.async {
                    self?.handleRolesAssigned(users: users)
                }
            },
            onAnswerSubmitted: { [weak self] answer in
                DispatchQueue.main.async {
                    self?.handleAnswerSubmitted(answer)
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
            if user.id == me?.id, me?.isReady == true, let index = users.firstIndex(where: { $0.id == user.id }) {
                users[index].isReady = true
                usersSubject.send(users)
            }
        }
    }
    
    private func handleUserLeft(_ user: User) {
        users.removeAll { $0.id == user.id }
    }
    
    private func handleUserReadyStateChanged(user: User, isReady: Bool) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index].isReady = isReady
            // 配列の要素を直接変更したので、明示的に変更通知を送信
            usersSubject.send(users)
        }
    }
    
    private func handleUserMuteStateChanged(user: User, isMuted: Bool) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index].isMuted = isMuted
            // 配列の要素を直接変更したので、明示的に変更通知を送信
            usersSubject.send(users)
        }
    }
    
    private func handleGameStarted() {
        if (currentScreen != .roleWaiting) {
            print("🎮 Game started!")
            navigate(to: .roleWaiting)
        }
    }
    
    private func handleRolesAssigned(users: [User]) {
        // 各ユーザーにロールを割り当て
        self.users = users
        self.me = users.first(where: { $0.id == me?.id })!
        navigate(to: .roleReveal)
    }
    
    private func handleAnswerSubmitted(_ answer: PlayerAnswer) {
        // 重複チェック（同じユーザーの回答は一度だけ）
        if !allAnswers.contains(where: { $0.answer.id == answer.answer.id }) {
            allAnswers.append(answer)
        }
    }
    
    private func handleError(_ message: String) {
        print("❌ Game error: \(message)")
        // TODO: ユーザーにエラーを表示
    }
    
}

// MARK: - ChannelEvent(Agora)
extension GameCoordinator: ChannelEventDelegate {
    func didJoinChannel(uid: UInt) {
        print("✅ Successfully joined Agora channel with uid: \(uid)")
        completeCallReady()
    }
    
    func didUserJoin(uid: UInt) {
        print("👤 User joined Agora: \(uid)")
    }
    
    func didUserLeave(uid: UInt) {
        print("👋 User left Agora: \(uid)")
    }
    
    func didLeaveChannel() {
        print("📤 Left Agora channel")
        leaveRoom()
    }
    
    func didOccurError(code: AgoraErrorCode) {
        print("❌ Agora error: \(code.rawValue)")
    }
}
