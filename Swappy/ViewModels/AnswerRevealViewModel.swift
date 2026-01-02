//
//  AnswerRevealViewModel.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import Foundation

/// 結果表示画面のViewModel
@Observable
class AnswerRevealViewModel {
    private let allAnswers: [PlayerAnswer]
    private let swappedUserId: String
    let users: [User]  // public に変更
    private let myUserId: String
    private let onRestart: () -> Void
    
    init(
        allAnswers: [PlayerAnswer],
        swappedUserId: String,
        users: [User],
        myUserId: String,
        onRestart: @escaping () -> Void
    ) {
        self.allAnswers = allAnswers
        self.swappedUserId = swappedUserId
        self.users = users
        self.myUserId = myUserId
        self.onRestart = onRestart
    }
    
    var answers: [PlayerAnswer] {
        allAnswers
    }
    
    var correctUser: User? {
        users.first(where: { $0.id == swappedUserId })
    }
    
    var myResult: PlayerAnswer? {
        allAnswers.first(where: { $0.id == myUserId })
    }
    
    func restart() {
        onRestart()
    }
}
