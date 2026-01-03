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
    let wolfUser: User
    let me: User
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
    
    var myAnswer: PlayerAnswer? {
        allAnswers.first(where: { $0.answer.id == me.id })
    }
    
    func restart() {
        onRestart()
    }
}
