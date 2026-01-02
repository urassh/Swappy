//
//  AnswerInputViewModel.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import Foundation
import Combine

/// 回答入力画面のViewModel
@Observable
class AnswerInputViewModel {
    var selectedUserId: String? = nil
    var users: [User] = []
    
    private let myUserId: String
    private let onSubmit: (String) -> Void
    private var cancellables = Set<AnyCancellable>()
    
    init(
        usersPublisher: AnyPublisher<[User], Never>,
        myUserId: String,
        onSubmit: @escaping (String) -> Void
    ) {
        self.myUserId = myUserId
        self.onSubmit = onSubmit
        
        // usersの購読
        usersPublisher
            .assign(to: \AnswerInputViewModel.users, on: self)
            .store(in: &cancellables)
    }
    
    var selectableUsers: [User] {
        users.filter { $0.id != myUserId }
    }
    
    var canSubmit: Bool {
        selectedUserId != nil
    }
    
    func submitAnswer() {
        guard let userId = selectedUserId else { return }
        onSubmit(userId)
    }
}
