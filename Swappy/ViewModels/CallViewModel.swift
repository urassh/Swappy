//
//  GameViewModel.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import Foundation
import SwiftUI
import AgoraRtcKit

@Observable
class GameViewModel {
    var gameState: GameState = .keywordInput
    var keyword: String = ""
    var userName: String = ""
    var users: [User] = []
    var isMicMuted: Bool = false
    
    // Agora Manager
    private var agoraManager: AgoraManager?
    private let appId = "test-mode"
    
    // ゲーム関連
    var swappedUserId: String? = nil  // 入れ替わっているユーザーのID
    var myAnswer: String? = nil       // 自分の回答
    var allAnswers: [PlayerAnswer] = [] // 全員の回答結果
    var videoCallTimeRemaining: Int = 10  // ビデオ通話の残り時間
    
    // 合言葉を入力してロビーへ
    func enterRoom() {
        gameState = .waitingRoom
        
        // Agora Managerをセットアップ
        setupAgoraManager()
        
        // チャンネルに参加（keywordをchannelIdとして使用）
        Task {
            do {
                try await agoraManager?.joinChannel(keyword, uid: 0, role: "publisher")
                print("🎤 Joined voice channel: \(keyword)")
            } catch {
                print("❌ Failed to join channel: \(error)")
            }
        }
        
        // シミュレーション: 他のユーザーを追加
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.users = [
                User(id: "1", name: self.userName, isReady: false),
                User(id: "2", name: "太郎", isReady: true),
                User(id: "3", name: "花子", isReady: true),
                User(id: "4", name: "次郎", isReady: true)
            ]
        }
    }
    
    // 準備完了を切り替え
    func toggleReady() {
        if let index = users.firstIndex(where: { $0.id == "1" }) {
            users[index].isReady.toggle()
            
            // 全員が準備完了したら役職を割り当てて役職表示画面へ
            if allUsersReady {
                assignRoles()
                gameState = .roleReveal
            }
        }
    }
    
    var allUsersReady: Bool {
        !users.isEmpty && users.allSatisfy { $0.isReady }
    }
    
    // 役職を割り当てる
    func assignRoles() {
        // ランダムに1人を人狼に、他を市民にする
        let werewolfIndex = Int.random(in: 0..<users.count)
        
        for (index, user) in users.enumerated() {
            let role: Role = (index == werewolfIndex) ? .werewolf : .villager
            users[index].role = role
            
            // 人狼のIDを記録（FaceSwapに使用）
            if role == .werewolf {
                swappedUserId = user.id
            }
        }
    }
    
    // ビデオ通話開始
    func startVideoCall() {
        gameState = .videoCall
        videoCallTimeRemaining = 10
        
        // 10秒のカウントダウン
        startCountdown()
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.videoCallTimeRemaining > 0 {
                self.videoCallTimeRemaining -= 1
            } else {
                timer.invalidate()
                self.gameState = .answerInput
            }
        }
    }
    
    // 回答を送信
    func submitAnswer(userId: String) {
        myAnswer = userId
        gameState = .answerReveal
        
        // シミュレーション: 他のユーザーの回答を生成
        generateMockAnswers()
    }
    
    private func generateMockAnswers() {
        allAnswers = users.map { user in
            if user.id == "1" {
                // 自分の回答
                return PlayerAnswer(
                    id: user.id,
                    playerName: user.name,
                    selectedUserId: myAnswer,
                    isCorrect: myAnswer == swappedUserId
                )
            } else {
                // ダミーの回答（ランダム）
                let randomAnswer = users.filter { $0.id != user.id }.randomElement()?.id
                return PlayerAnswer(
                    id: user.id,
                    playerName: user.name,
                    selectedUserId: randomAnswer,
                    isCorrect: randomAnswer == swappedUserId
                )
            }
        }
    }
    
    // ゲームをリセット
    func resetGame() {
        // Agoraチャンネルから退出
        cleanupAgoraManager()
        
        gameState = .keywordInput
        keyword = ""
        userName = ""
        users = []
        swappedUserId = nil
        myAnswer = nil
        allAnswers = []
        videoCallTimeRemaining = 10
    }
    
    func toggleMic() {
        if isMicMuted {
            agoraManager?.audio?.unmute()
        } else {
            agoraManager?.audio?.mute()
        }
        isMicMuted.toggle()
    }
    
    // Agora Managerをセットアップ
    func setupAgoraManager() {
        let tokenRepository = AgoraTestTokenRepository()
        
        let builder = AgoraManagerBuilder(appId: appId, tokenRepository: tokenRepository)
        agoraManager = builder
            .withAudio(delegate: nil)
            .withChannelDelegate(self)
            .build()
    }
    
    // Agora Managerのクリーンアップ
    func cleanupAgoraManager() {
        agoraManager?.leaveChannel()
        agoraManager = nil
    }
}

// MARK: - ChannelEventDelegate

extension GameViewModel: ChannelEventDelegate {
    func didJoinChannel(uid: UInt) {
        print("✅ Successfully joined channel with uid: \(uid)")
    }
    
    func didUserJoin(uid: UInt) {
        print("👤 User joined: \(uid)")
        // Note: 実際の実装では、ユーザー情報を取得してusers配列に追加する
    }
    
    func didUserLeave(uid: UInt) {
        print("👋 User left: \(uid)")
        // Note: 実際の実装では、users配列から該当ユーザーを削除する
    }
    
    func didLeaveChannel() {
        print("📤 Left channel")
    }
    
    func didOccurError(code: AgoraErrorCode) {
        print("❌ Agora error occurred: \(code.rawValue)")
        // Note: 必要に応じてエラーをユーザーに通知
    }
}
