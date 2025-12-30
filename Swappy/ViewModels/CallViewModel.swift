//
//  GameViewModel.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import Foundation
import SwiftUI

@Observable
class GameViewModel {
    var gameState: GameState = .keywordInput
    var keyword: String = ""
    var userName: String = ""
    var users: [User] = []
    var isMicMuted: Bool = false
    
    // ゲーム関連
    var swappedUserId: String? = nil  // 入れ替わっているユーザーのID
    var myAnswer: String? = nil       // 自分の回答
    var allAnswers: [PlayerAnswer] = [] // 全員の回答結果
    var videoCallTimeRemaining: Int = 10  // ビデオ通話の残り時間
    
    // 合言葉を入力してロビーへ
    func enterRoom() {
        gameState = .waitingRoom
        
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
            
            // 全員が準備完了したらビデオ通話開始
            if allUsersReady {
                startVideoCall()
            }
        }
    }
    
    var allUsersReady: Bool {
        !users.isEmpty && users.allSatisfy { $0.isReady }
    }
    
    // ビデオ通話開始
    func startVideoCall() {
        gameState = .videoCall
        videoCallTimeRemaining = 10
        
        // ランダムにユーザーを選択（自分以外）
        let otherUsers = users.filter { $0.id != "1" }
        swappedUserId = otherUsers.randomElement()?.id
        
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
        gameState = .keywordInput
        keyword = ""
        users = []
        swappedUserId = nil
        myAnswer = nil
        allAnswers = []
        videoCallTimeRemaining = 10
    }
    
    func toggleMic() {
        isMicMuted.toggle()
    }
}
