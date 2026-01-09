//
//  ContentView.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/28.
//

import SwiftUI

struct ContentView: View {
    @State private var coordinator: GameCoordinator

    init() {
        let coordinator = GameCoordinator(gameRepository: MockGameRepository())
        _coordinator = State(initialValue: coordinator)
    }
    
    var body: some View {
        ZStack {
            switch coordinator.currentScreen {
            case .keywordInput:
                KeywordInputView(
                    onEnterRoom: { keyword, userName in
                        coordinator.joinRoom(keyword: keyword, userName: userName)
                    }
                )

            case .robby:
                if let me = coordinator.me {
                    RobbyView(
                        usersPublisher: coordinator.usersPublisher,
                        me: me,
                        onMuteMic: {
                            coordinator.toggleMute(isMuted: true)
                        },
                        onUnmuteMic: {
                            coordinator.toggleMute(isMuted: false)
                        },
                        onStartGame: {
                            coordinator.startGame()
                        },
                        onBack: {
                            coordinator.leaveRoom()
                            coordinator.navigate(to: .keywordInput)
                        }
                    )
                } else {
                    ProgressView("Loading...")
                }
                
            case .roleWaiting:
                RoleWaitingView()
                
            case .roleReveal:
                if let me = coordinator.me {
                    RoleRevealView(
                        myRole: me.role,
                        onStartVideoCall: {
                            coordinator.startVideoCall()
                        }
                    )
                } else {
                    ProgressView("Loading...")
                }
                
            case .videoCall:
                VideoCallView(
                    usersPublisher: coordinator.usersPublisher,
                    videoViews: coordinator.getVideoViews(),
                    onTimeUp: {
                        coordinator.startAnswerInput()
                    },
                    onBack: {
                        coordinator.leaveRoom()
                        coordinator.navigate(to: .keywordInput)
                    }
                )
                
            case .answerInput:
                if let me = coordinator.me {
                    AnswerInputView(
                        usersPublisher: coordinator.usersPublisher,
                        me: me,
                        onSubmit: { user in
                            coordinator.submitAnswer(selectUser: user)
                        }
                    )
                } else {
                    ProgressView("Loading...")
                }
                
            case .answerWaiting:
                AnswerWaitingView(
                    allAnswersPublisher: coordinator.allAnswersPublisher,
                    usersPublisher: coordinator.usersPublisher
                )
                
            case .answerReveal:
                if let me = coordinator.me, let wolfUser = coordinator.wolfUser {
                    AnswerRevealView(
                        usersPublisher: coordinator.usersPublisher,
                        allAnswers: coordinator.allAnswers,
                        wolfUser: wolfUser,
                        me: me,
                        onRestart: {
                            coordinator.resetGame()
                        }
                    )
                } else {
                    ProgressView("Loading...")
                }
            }
        }
        .animation(.easeInOut, value: coordinator.currentScreen)
    }
}

#Preview {
    ContentView()
}
