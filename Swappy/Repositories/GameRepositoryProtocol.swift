//
//  GameRepositoryProtocol.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import Foundation
import Combine

/// ゲームのBackend通信を抽象化したプロトコル
protocol GameRepositoryProtocol {
    /// イベントハンドラを設定
    func setEventHandlers(
        onUsersChanged: @escaping ([User]) -> Void,                  // ユーザーリストが変更された時（参加、準備状態変更、ミュート状態変更）
        onUserLeft: @escaping (User) -> Void,                        // ユーザ(自分含む)がチャンネルから離脱された時
        onGameStarted: @escaping () -> Void,                         // ゲームが開始された時
        onRolesAssigned: @escaping ([User]) -> Void,                 // 各ユーザにロールがアサインされた時（[User]）
        onAnswerSubmitted: @escaping (PlayerAnswer) -> Void,         // ユーザが回答を送信した時（個別）
        onError: @escaping (String) -> Void                          // エラーが発生した時
    )
    
    /// ルームに参加する
    func joinRoom(keyword: String, me: User)
    
    /// ルームから退出する
    func leaveRoom(me: User)
    
    /// 準備状態を完了にする
    func completeCallReady(me: User)
    
    /// ゲームを開始する
    func startGame()

    /// ミュート状態をトグルする
    func toggleMute(me: User, isMuted: Bool)
    
    /// 回答を送信する
    func submitAnswer(me: User, selectedUser: User)
    
    /// ゲームをリセットする
    func resetGame()
}
