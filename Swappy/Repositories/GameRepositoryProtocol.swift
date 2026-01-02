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
    /// ゲームイベントのストリーム
    var eventPublisher: AnyPublisher<GameEvent, Never> { get }
    
    /// ルームに参加する
    /// - Parameters:
    ///   - keyword: ルームの合言葉
    ///   - userName: ユーザー名
    func joinRoom(keyword: String, userName: String) async throws
    
    /// ルームから退出する
    func leaveRoom() async throws
    
    /// 準備完了状態をトグルする
    func toggleReady() async throws
    
    /// ミュート状態をトグルする
    func toggleMute(isMuted: Bool) async throws
    
    /// ビデオ通話を開始する
    func startVideoCall() async throws
    
    /// 回答フェーズを開始する
    func startAnswerPhase() async throws
    
    /// 回答を送信する
    /// - Parameter userId: 選択したユーザーのID
    func submitAnswer(userId: String) async throws
    
    /// ゲームをリセットする
    func resetGame() async throws
}
