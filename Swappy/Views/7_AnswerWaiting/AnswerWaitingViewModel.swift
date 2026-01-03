//
//  AnswerWaitingViewModel.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/03.
//

import Foundation
import Combine

/// 回答待機画面のViewModel
@Observable
class AnswerWaitingViewModel {
    var users: [User] = []
    
    private let me: User
    private var cancellables = Set<AnyCancellable>()
    
    init(
        usersPublisher: AnyPublisher<[User], Never>,
        me: User
    ) {
        self.me = me
        
        // usersの購読
        usersPublisher
            .assign(to: \AnswerWaitingViewModel.users, on: self)
            .store(in: &cancellables)
    }
    
    var answeredCount: Int {
        users.filter { $0.hasAnswered }.count
    }
    
    var totalCount: Int {
        users.count
    }
}
