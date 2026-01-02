//
//  RobbyViewModel.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import Foundation
import Combine

/// ロビー画面のViewModel
@Observable
class RobbyViewModel {
    var isMicMuted: Bool = false
    var users: [User] = []
    
    private let myUserId: String
    private let onToggleReady: () -> Void
    private let onMuteMic: () -> Void
    private let onUnmuteMic: () -> Void
    private var cancellables = Set<AnyCancellable>()
    
    init(
        usersPublisher: AnyPublisher<[User], Never>,
        myUserId: String,
        onToggleReady: @escaping () -> Void,
        onMuteMic: @escaping () -> Void,
        onUnmuteMic: @escaping () -> Void
    ) {
        self.myUserId = myUserId
        self.onToggleReady = onToggleReady
        self.onMuteMic = onMuteMic
        self.onUnmuteMic = onUnmuteMic
        
        // usersの購読
        usersPublisher
            .assign(to: \RobbyViewModel.users, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    
    var myUser: User? {
        users.first(where: { $0.id == myUserId })
    }
    
    var allUsersReady: Bool {
        !users.isEmpty && users.allSatisfy { $0.isReady }
    }
    
    // MARK: - Actions
    
    func toggleReady() {
        onToggleReady()
    }
    
    func toggleMic() {
        if isMicMuted {
            onUnmuteMic()
        } else {
            onMuteMic()
        }
        isMicMuted.toggle()
    }
}
