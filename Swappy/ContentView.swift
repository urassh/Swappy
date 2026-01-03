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
                        coordinator.joinRoom(keyword: keyword, userName: userName)
                    }
                )

            case .robby:
                RobbyView(
                    usersPublisher: coordinator.usersPublisher,
                    me: coordinator.me!,
                    onMuteMic: {
                        coordinator.toggleMute(isMuted: true)
                    },
                    onUnmuteMic: {
                        coordinator.toggleMute(isMuted: false)
                    },
                    onStartGame: {
                        coordinator.startGame()
                    }
                )
                
            case .roleWaiting:
                RoleWaitingView()
                
            case .roleReveal:
                RoleRevealView(
                    myRole: coordinator.me!.role,
                    onStartVideoCall: {
                        coordinator.startVideoCall()
                    }
                )
                
            case .videoCall:
                VideoCallView(
                    usersPublisher: coordinator.usersPublisher,
                    onTimeUp: {
                        coordinator.startAnswerInput()
                    }
                )
                
            case .answerInput:
                AnswerInputView(
                    usersPublisher: coordinator.usersPublisher,
                    me: coordinator.me!,
                    onSubmit: { user in
                        coordinator.submitAnswer(selectUser: user)
                    }
                )
                
            case .answerWaiting:
                AnswerWaitingView(
                    usersPublisher: coordinator.usersPublisher,
                    me: coordinator.me!
                )
                
            case .answerReveal:
                AnswerRevealView(
                    usersPublisher: coordinator.usersPublisher,
                    allAnswers: coordinator.allAnswers,
                    wolfUser: coordinator.wolfUser!,
                    me: coordinator.me!,
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
