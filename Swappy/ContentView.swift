//
//  ContentView.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/28.
//

import SwiftUI

struct ContentView: View {
    @State private var coordinator = GameCoordinator(gameRepository: MockGameRepository())
    
    var body: some View {
        ZStack {
            switch coordinator.currentScreen {
            case .keywordInput:
                KeywordInputView(
                    onEnterRoom: { keyword, userName in
                        coordinator.enterRoom(keyword: keyword, userName: userName)
                    }
                )

            case .robby:
                RobbyView(
                    usersPublisher: coordinator.$users.eraseToAnyPublisher(),
                    myUserId: coordinator.myUserId,
                    onToggleReady: {
                        Task {
                            try? await coordinator.gameRepository.toggleReady()
                        }
                    },
                    onMuteMic: {
                        coordinator.agoraManager?.audio?.mute()
                        Task {
                            try? await coordinator.gameRepository.toggleMute(isMuted: true)
                        }
                    },
                    onUnmuteMic: {
                        coordinator.agoraManager?.audio?.unmute()
                        Task {
                            try? await coordinator.gameRepository.toggleMute(isMuted: false)
                        }
                    }
                )
                
            case .roleReveal:
                RoleRevealView(
                    myRole: coordinator.myRole,
                    onStartVideoCall: {
                        Task {
                            try? await coordinator.gameRepository.startVideoCall()
                        }
                    }
                )
                
            case .videoCall:
                VideoCallView(
                    usersPublisher: coordinator.$users.eraseToAnyPublisher(),
                    swappedUserId: coordinator.swappedUserId,
                    gameRepository: coordinator.gameRepository,
                    onTimeUp: {
                        Task {
                            try? await coordinator.gameRepository.startAnswerPhase()
                        }
                    }
                )
                
            case .answerInput:
                AnswerInputView(
                    usersPublisher: coordinator.$users.eraseToAnyPublisher(),
                    myUserId: coordinator.myUserId,
                    onSubmit: { userId in
                        Task {
                            try? await coordinator.gameRepository.submitAnswer(userId: userId)
                        }
                    }
                )
                
            case .answerReveal:
                AnswerRevealView(
                    usersPublisher: coordinator.$users.eraseToAnyPublisher(),
                    allAnswers: coordinator.allAnswers,
                    swappedUserId: coordinator.swappedUserId ?? "",
                    myUserId: coordinator.myUserId,
                    onRestart: {
                        coordinator.resetGame()
                    }
                )
            }
        }
        .animation(.easeInOut, value: coordinator.currentScreen)
    }
}

#Preview {
    ContentView()
}
