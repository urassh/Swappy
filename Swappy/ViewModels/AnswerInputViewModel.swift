//
//  AnswerInputViewModel.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import Foundation

/// 回答入力画面のViewModel
@Observable
class AnswerInputViewModel {
    var selectedUserId: String? = nil
    
    private let gameRepository: GameRepositoryProtocol
    private let myUserId: String
    private(set) var users: [User]
    
    init(
        gameRepository: GameRepositoryProtocol,
        users: [User],
        myUserId: String
    ) {
        self.gameRepository = gameRepository
        self.users = users
        self.myUserId = myUserId
    }
    
    var selectableUsers: [User] {
        users.filter { $0.id != myUserId }
    }
    
    var canSubmit: Bool {
        selectedUserId != nil
    }
    
    func submitAnswer() {
        guard let userId = selectedUserId else { return }
        
        Task {
            do {
                try await gameRepository.submitAnswer(userId: userId)
            } catch {
                print("❌ Failed to submit answer: \(error)")
            }
        }
    }
}
