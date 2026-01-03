//
//  GameState.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import Foundation

enum ScreenState {
    case keywordInput          // 合言葉入力
    case robby                 // 参加待機ロビー（音声通話）
    case roleWaiting           // 役職決定待ち
    case roleReveal            // 役職表示
    case videoCall             // ビデオ通話（10秒間）
    case answerInput           // 回答入力
    case answerWaiting         // 回答待機
    case answerReveal          // 答え合わせ
}
