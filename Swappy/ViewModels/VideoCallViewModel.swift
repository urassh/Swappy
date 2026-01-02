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
    
    private let gameRepository: GameRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var users: [User]
    private(set) var swappedUserId: String?
    
    init(
        gameRepository: GameRepositoryProtocol,
        users: [User],
        swappedUserId: String?
    ) {
        self.gameRepository = gameRepository
        self.users = users
        self.swappedUserId = swappedUserId
        
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
    
    // Coordinatorからの更新を受け取る
    func updateUsers(_ users: [User]) {
        self.users = users
    }
}
