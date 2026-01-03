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
    
    let me: User
    private let onMuteMic: () -> Void
    private let onUnmuteMic: () -> Void
    private let onStartGame: () -> Void
    private var cancellables = Set<AnyCancellable>()
    
    init(
        usersPublisher: AnyPublisher<[User], Never>,
        me: User,
        onMuteMic: @escaping () -> Void,
        onUnmuteMic: @escaping () -> Void,
        onStartGame: @escaping () -> Void
    ) {
        self.me = me
        self.onMuteMic = onMuteMic
        self.onUnmuteMic = onUnmuteMic
        self.onStartGame = onStartGame
        
        // usersの購読
        usersPublisher
            .assign(to: \RobbyViewModel.users, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    
    var allUsersReady: Bool {
        !users.isEmpty && users.allSatisfy { $0.isReady }
    }
    
    /// ゲーム開始可能かどうか
    var canStartGame: Bool {
        users.count >= 3 && allUsersReady
    }
    
    /// ゲーム開始できない理由
    var startGameDisabledReason: String? {
        if users.count < 3 {
            return "ゲームには3人以上が必要です"
        }
        if !allUsersReady {
            return "プレイヤー全員が準備完了ではありません"
        }
        return nil
    }
    
    // MARK: - Actions
    
    func toggleMic() {
        if isMicMuted {
            onUnmuteMic()
        } else {
            onMuteMic()
        }
        isMicMuted.toggle()
    }
    
    func startGame() {
        guard canStartGame else { return }
        onStartGame()
    }
}
