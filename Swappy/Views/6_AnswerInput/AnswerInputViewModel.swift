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
    var selectedUser: User? = nil
    var users: [User] = []
    
    private let me: User
    private let onSubmit: (User) -> Void
    private var cancellables = Set<AnyCancellable>()
    
    init(
        usersPublisher: AnyPublisher<[User], Never>,
        me: User,
        onSubmit: @escaping (User) -> Void
    ) {
        self.me = me
        self.onSubmit = onSubmit
        
        // usersの購読
        usersPublisher
            .assign(to: \AnswerInputViewModel.users, on: self)
            .store(in: &cancellables)
    }
    
    var selectableUsers: [User] {
        users.filter { $0.id != me.id }
    }
    
    var canSubmit: Bool {
        selectedUser != nil
    }
    
    func submitAnswer() {
        guard let selectedUser else { return }
        onSubmit(selectedUser)
    }
}
