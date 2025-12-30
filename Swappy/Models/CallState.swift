//
//  GameState.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import Foundation

enum GameState {
    case keywordInput           // 合言葉入力
    case waitingRoom           // 参加待機ロビー（音声通話）
    case roleReveal            // 役職表示
    case videoCall             // ビデオ通話（10秒間）
    case answerInput           // 回答入力
    case answerReveal          // 答え合わせ
}
