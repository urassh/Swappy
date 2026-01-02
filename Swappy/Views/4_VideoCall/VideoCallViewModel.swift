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
    private var timer: Timer?
    
    private(set) var swappedUserId: String?
    private let onTimeUp: () -> Void
    
    init(
        usersPublisher: AnyPublisher<[User], Never>,
        swappedUserId: String?,
        gameRepository: GameRepositoryProtocol,
        onTimeUp: @escaping () -> Void
    ) {
        self.swappedUserId = swappedUserId
        self.gameRepository = gameRepository
        self.onTimeUp = onTimeUp
        
        // usersの購読
        usersPublisher
            .assign(to: \VideoCallViewModel.users, on: self)
            .store(in: &cancellables)
        
        startCountdown()
    }
    
    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                timer.invalidate()
                self.timer = nil
                self.onTimeUp()
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
