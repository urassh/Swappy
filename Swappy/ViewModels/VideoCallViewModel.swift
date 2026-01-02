//
//  VideoCallViewModel.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import Foundation
import Combine

/// ビデオ通話画面のViewModel
@Observable
class VideoCallViewModel {
    var timeRemaining: Int = 10
    var users: [User] = []
    
    private let gameRepository: GameRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var swappedUserId: String?
    
    init(
        usersPublisher: AnyPublisher<[User], Never>,
        swappedUserId: String?,
        gameRepository: GameRepositoryProtocol
    ) {
        self.swappedUserId = swappedUserId
        self.gameRepository = gameRepository
        
        // usersの購読
        usersPublisher
            .assign(to: \VideoCallViewModel.users, on: self)
            .store(in: &cancellables)
        
        setupEventSubscription()
    }
    
    private func setupEventSubscription() {
        gameRepository.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                if case .videoCallCountdown(let time) = event {
                    self?.timeRemaining = time
                }
            }
            .store(in: &cancellables)
    }
}
