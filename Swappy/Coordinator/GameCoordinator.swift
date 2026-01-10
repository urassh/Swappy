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
    
    /// 自分のユーザーID
    private(set) var meId: UUID?
    
    /// 自分のユーザー情報（computed property）
    var me: User? {
        guard let meId = meId else { return nil }
        return users.first(where: { $0.id == meId })
    }
    
    var wolfUser: User? {
        users.first(where: { $0.role == .werewolf })
    }
    
    /// 全ユーザー（自分を含む）
    var users: [User] = [] {
        didSet {
            usersSubject.send(users)
        }
    }
    var allAnswers: [PlayerAnswer] = [] {
        didSet {
            allAnswersSubject.send(allAnswers)
        }
    }
    
    private let usersSubject = CurrentValueSubject<[User], Never>([])
    private let allAnswersSubject = CurrentValueSubject<[PlayerAnswer], Never>([])
    
    var usersPublisher: AnyPublisher<[User], Never> {
        usersSubject.eraseToAnyPublisher()
    }
    var allAnswersPublisher: AnyPublisher<[PlayerAnswer], Never> {
        allAnswersSubject.eraseToAnyPublisher()
    }

    let gameRepository: GameRepositoryProtocol
    private(set) var agoraManager: AgoraManager?
    private var didSendReady: Bool = false
    
    private let appId = "test-mode"
    
    
    init(gameRepository: GameRepositoryProtocol = MockGameRepository()) {
        self.gameRepository = gameRepository
        setupEventHandlers()
    }
    
    func navigate(to screen: ScreenState) {
        currentScreen = screen
    }
    
    /// GameCoordinatorの状態を完全にクリーン（Agora含む）
    func clean() {
        // Agoraをクリーンアップ
        cleanupAgoraManager()
        
        // 状態をリセット
        users = []
        allAnswers = []
        meId = nil
        currentScreen = .keywordInput
        didSendReady = false
        
        print("🧹 GameCoordinator cleaned")
    }
    
    // MARK: - Agora Management
    
    private func setupAgoraManager() {
        let tokenRepository = AgoraTestTokenRepository()
        
        let builder = AgoraManagerBuilder(appId: appId, tokenRepository: tokenRepository)
        agoraManager = builder
            .withAudio(delegate: nil)
            .withVideo()
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
        
        let newUser = User(name: userName)
        self.meId = newUser.id
        
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
        gameRepository.joinRoom(keyword: keyword, me: newUser)
    }
    
    func leaveRoom() {
        guard let me = me else { return }
        clean()
        gameRepository.leaveRoom(me: me)
    }
    
    /// 準備状態を完了状態にする
    private func completeCallReady() {
        guard let me = self.me else { return }
        
        // Repositoryに送信（イベントハンドラで状態を受け取る）
        gameRepository.completeCallReady(me: me)
    }

    /// ミュート状態をトグル
    func toggleMute(isMuted: Bool) {
        guard let me = me, let meId = meId else { return }
        
        // Agoraのミュート状態を変更
        if isMuted {
            agoraManager?.audio?.mute()
        } else {
            agoraManager?.audio?.unmute()
        }
        
        // 楽観的更新: users内の自分の状態を即座に更新（UX向上）
        if let index = users.firstIndex(where: { $0.id == meId }) {
            users[index].isMuted = isMuted
        }
        
        // Repositoryに送信（handleUsersChangedで最終的な状態を受け取る）
        gameRepository.toggleMute(me: me, isMuted: isMuted)
    }

    /// ローカル音声だけをミュート/解除（ユーザー配列やRepositoryは更新しない）
    func setLocalAudioMuted(_ isMuted: Bool) {
        if isMuted {
            agoraManager?.audio?.mute()
        } else {
            agoraManager?.audio?.unmute()
        }
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
            onUsersChanged: { [weak self] users in
                DispatchQueue.main.async {
                    self?.handleUsersChanged(users)
                }
            },
            onUserLeft: { [weak self] userId in
                DispatchQueue.main.async {
                    self?.handleUserLeft(userId: userId)
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
            onAnswerSubmitted: { [weak self] userId, answerUserId in
                DispatchQueue.main.async {
                    self?.handleAnswerSubmitted(userId: userId, answerUserId: answerUserId)
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
    
    private func handleUsersChanged(_ allUsers: [User]) {
        users = allUsers
    }
    
    private func handleUserLeft(userId: String) {
        // userIdでユーザーを検索して削除
        if let index = users.firstIndex(where: { $0.userId == userId }) {
            let removedUser = users[index]
            users.remove(at: index)
            print("👋 User left: \(removedUser.name) (userId: \(userId))")
        } else {
            print("⚠️ 警告: 離脱したユーザーが見つかりませんでした (userId: \(userId))")
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
        navigate(to: .roleReveal)
    }
    
    private func handleAnswerSubmitted(userId: String, answerUserId: String) {
        // userIdで回答したユーザーを検索
        guard let answerUser = users.first(where: { $0.userId == userId }) else {
            print("⚠️ 警告: 回答したユーザーが見つかりません (userId: \(userId))")
            return
        }
        
        // answerUserIdで選択されたユーザーを検索
        var selectedUser = users.first(where: { $0.userId == answerUserId })
        
        // 見つからない場合はフォールバック: 他のユーザーを自動選択
        if selectedUser == nil {
            print("⚠️ 警告: 選択されたユーザーが見つかりません (answerUserId: \(answerUserId))")
            // 回答者以外のユーザーを自動選択
            selectedUser = users.first(where: { $0.userId != userId })
            
            if let fallbackUser = selectedUser {
                print("ℹ️ フォールバック: \(fallbackUser.name) を自動選択しました")
            } else {
                print("❌ エラー: フォールバック用のユーザーも見つかりません")
                return
            }
        }
        
        guard let finalSelectedUser = selectedUser else { return }
        
        // 正解判定: 選択したユーザーが人狼かどうか
        let isCorrect = finalSelectedUser.isWolf
        
        let playerAnswer = PlayerAnswer(
            answer: answerUser,
            selectedUser: finalSelectedUser,
            isCorrect: isCorrect
        )
        
        // 重複チェック（同じユーザーの回答は一度だけ）
        if !allAnswers.contains(where: { $0.answer.id == answerUser.id }) {
            allAnswers.append(playerAnswer)
            print("✅ 回答追加: \(answerUser.name) → \(finalSelectedUser.name) (isCorrect: \(isCorrect))")
        }
        
        // 全員の回答が揃ったらAnswerRevealに遷移
        if allAnswers.count == users.count && currentScreen == .answerWaiting {
            navigate(to: .answerReveal)
        }
    }
    
    private func handleGameReset() {
        print("🔄 Game reset received")
        // 状態を完全にクリーン
        clean()
        // キーワード入力画面に戻る
        navigate(to: .keywordInput)
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

// MARK: - Video Views
extension GameCoordinator {
    /// 各ユーザーのビデオビューを生成
    func getVideoViews() -> [UUID: UIView] {
        guard let agoraManager = agoraManager,
              let videoComponent = agoraManager.video else {
            return [:]
        }
        
        var videoViews: [UUID: UIView] = [:]
        
        for user in users {
            let view: UIView
            if user.id == meId {
                // 自分の場合はローカルビデオ
                view = videoComponent.localVideo()
            } else {
                // 他のユーザーの場合はリモートビデオ
                view = videoComponent.remoteVideo(with: user.talkId)
            }
            videoViews[user.id] = view
        }
        
        return videoViews
    }
}
