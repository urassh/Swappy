//
//  GameEvent.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import Foundation

/// ゲームイベントの種類
enum GameEvent {
    /// ユーザーがルームに参加した
    case userJoined(User)
    
    /// ユーザーがルームから退出した
    case userLeft(userId: String)
    
    /// ユーザーの準備状態が変更された
    case userReadyStateChanged(userId: String, isReady: Bool)
    
    /// ユーザーのミュート状態が変更された
    case userMuteStateChanged(userId: String, isMuted: Bool)
    
    /// ゲームが開始され、役職が割り当てられた
    case rolesAssigned(users: [User], swappedUserId: String)
    
    /// ビデオ通話が開始された
    case videoCallStarted
    
    /// ビデオ通話のカウントダウン
    case videoCallCountdown(timeRemaining: Int)
    
    /// 回答フェーズに移行
    case answerPhaseStarted
    
    /// プレイヤーが回答を送信した
    case answerSubmitted(userId: String, selectedUserId: String)
    
    /// 全員の回答が集まり、結果が発表された
    case answerRevealed(answers: [PlayerAnswer], swappedUserId: String)
    
    /// ゲームがリセットされた
    case gameReset
    
    /// エラーが発生した
    case error(message: String)
}
