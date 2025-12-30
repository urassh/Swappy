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
}

struct User: Identifiable, Equatable {
    let id: String
    let name: String
    var isMuted: Bool = false
    var isReady: Bool = false
    var role: Role? = nil  // 役職
}

struct PlayerAnswer: Identifiable {
    let id: String
    let playerName: String
    let selectedUserId: String?
    let isCorrect: Bool
}
