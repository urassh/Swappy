//
//  User.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import Foundation

struct User: Identifiable, Equatable {
    let id: String
    let name: String
    var isMuted: Bool = false
    var isReady: Bool = false
}

struct PlayerAnswer: Identifiable {
    let id: String
    let playerName: String
    let selectedUserId: String?
    let isCorrect: Bool
}
