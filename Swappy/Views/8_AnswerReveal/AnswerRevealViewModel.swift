//
//  AnswerRevealViewModel.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import Foundation
import Combine

/// 結果表示画面のViewModel
@Observable
class AnswerRevealViewModel {
    var users: [User] = []
    
    private let allAnswers: [PlayerAnswer]
    private let wolfUser: User
    private let me: User
    private let onRestart: () -> Void
    private var cancellables = Set<AnyCancellable>()
    
    init(
        usersPublisher: AnyPublisher<[User], Never>,
        allAnswers: [PlayerAnswer],
        wolfUser: User,
        me: User,
        onRestart: @escaping () -> Void
    ) {
        self.allAnswers = allAnswers
        self.wolfUser = wolfUser
        self.me = me
        self.onRestart = onRestart
        
        // usersの購読
        usersPublisher
            .assign(to: \AnswerRevealViewModel.users, on: self)
            .store(in: &cancellables)
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
