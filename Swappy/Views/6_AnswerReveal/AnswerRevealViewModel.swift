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
    private let swappedUserId: String
    private let myUserId: String
    private let onRestart: () -> Void
    private var cancellables = Set<AnyCancellable>()
    
    init(
        usersPublisher: AnyPublisher<[User], Never>,
        allAnswers: [PlayerAnswer],
        swappedUserId: String,
        myUserId: String,
        onRestart: @escaping () -> Void
    ) {
        self.allAnswers = allAnswers
        self.swappedUserId = swappedUserId
        self.myUserId = myUserId
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
