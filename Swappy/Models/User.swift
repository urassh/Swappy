//
//  User.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import Foundation

enum Role {
    case werewolf  // 人狼（FaceSwapする人）
    case villager  // 市民（普通の人）
    case undefined // 未設定
}

struct User: Identifiable, Equatable, Hashable {
    let id: UUID = UUID()
    let name: String
    var isMuted: Bool = false
    var isReady: Bool = false
    var role: Role = .undefined
    var hasAnswered: Bool = false
    
    // 通話用のUInt型ID（userIdのハッシュ値から32ビット符号付き整数の範囲内で生成）
    var talkId: UInt {
        let hash = abs(id.hashValue)
        // Int32の最大値（2147483647）内に収める
        let limitedHash = hash % Int(Int32.max)
        return UInt(limitedHash)
    }
    
    var isWolf: Bool {
        role == .werewolf
    }
}

struct PlayerAnswer: Identifiable {
    let id: UUID = UUID()
    let answer: User
    let selectedUser: User
    let isCorrect: Bool
    
    var playerName: String {
        answer.name
    }
    
    var selectedUserId: String {
        selectedUser.id.uuidString
    }
}
