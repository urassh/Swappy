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
    var allAnswers: [PlayerAnswer] = []
    var totalUserCount: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        allAnswersPublisher: AnyPublisher<[PlayerAnswer], Never>,
        usersPublisher: AnyPublisher<[User], Never>
    ) {
        // allAnswersの購読
        allAnswersPublisher
            .assign(to: \AnswerWaitingViewModel.allAnswers, on: self)
            .store(in: &cancellables)
        
        // usersの購読（ユーザー数のみ）
        usersPublisher
            .map { $0.count }
            .assign(to: \AnswerWaitingViewModel.totalUserCount, on: self)
            .store(in: &cancellables)
    }
    
    var answeredCount: Int {
        allAnswers.count
    }
    
    var totalCount: Int {
        totalUserCount
    }
}
