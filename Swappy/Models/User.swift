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
    let id: UUID
    let userId: String  // バックエンド用のuser_id（id.uuidString）
    let name: String
    var isMuted: Bool = false
    var isReady: Bool = false
    var role: Role = .undefined
    
    // 初期化時にidとuserIdを自動設定
    init(name: String, isMuted: Bool = false, isReady: Bool = false, role: Role = .undefined) {
        let uuid = UUID()
        self.id = uuid
        self.userId = uuid.uuidString
        self.name = name
        self.isMuted = isMuted
        self.isReady = isReady
        self.role = role
    }
    
    // バックエンドからのデータを復元する初期化（userId指定あり）
    init(userId: String, name: String, isMuted: Bool = false, isReady: Bool = false, role: Role = .undefined) {
        self.id = UUID(uuidString: userId) ?? UUID()
        self.userId = userId
        self.name = name
        self.isMuted = isMuted
        self.isReady = isReady
        self.role = role
    }
    
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
}
