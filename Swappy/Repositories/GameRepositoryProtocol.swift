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
        onUserMuteStateChanged: @escaping (String, Bool) -> Void,    // ユーザ(自分含む)がミュート状態を更新された時
        onRolesAssigned: @escaping ([String: Role], String) -> Void, // 各ユーザにロールがアサインされた時（userId: Role, swappedUserId）
        onAnswerRevealed: @escaping ([PlayerAnswer]) -> Void,        // 全てのユーザの回答が揃った時
        onError: @escaping (String) -> Void                          // エラーが発生した時
    )
    
    /// ルームに参加する
    func joinRoom(keyword: String, me: User) async throws
    
    /// ルームから退出する
    func leaveRoom() async throws
    
    /// 準備完了状態をトグルする
    func completeCallReady(me: User) async throws
    
    /// ミュート状態をトグルする
    func toggleMute(me: User, isMuted: Bool) async throws
    
    /// 回答を送信する
    func submitAnswer(me: User, selectUserId: String) async throws
    
    /// ゲームをリセットする
    func resetGame() async throws
}
