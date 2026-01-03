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
        onUserJoined: @escaping (User) -> Void,                      // ユーザ(自分含む)がチャンネルに参加した時(Userモデルとして取得できる)
        onUserLeft: @escaping (User) -> Void,                        // ユーザ(自分含む)がチャンネルから離脱された時
        onUserReadyStateChanged: @escaping (User, Bool) -> Void,     // ユーザ(自分含む)がAgoraやAkoolの接続準備状態が更新された時
        onUserMuteStateChanged: @escaping (User, Bool) -> Void,      // ユーザ(自分含む)がミュート状態を更新された時
        onUserAnswerStateChanged: @escaping (User, Bool) -> Void,    // ユーザ(自分含む)の回答状態が更新された時
        onGameStarted: @escaping () -> Void,                         // ゲームが開始された時
        onRolesAssigned: @escaping ([User]) -> Void,                 // 各ユーザにロールがアサインされた時（[User]）
        onAnswerRevealed: @escaping ([PlayerAnswer]) -> Void,        // 全てのユーザの回答が揃った時
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
