//
//  ContentView.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/28.
//

import SwiftUI

struct ContentView: View {
    @State private var coordinator = GameCoordinator(gameRepository: MockGameRepository())
    @State private var videoCallViewModel: VideoCallViewModel?
    
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
                    viewModel: RoleRevealViewModel(
                        myRole: coordinator.myRole,
                        onStartVideoCall: {
                            // MockRepositoryが自動的にvideoCallStartedイベントを送信
                        }
                    )
                )
                
            case .videoCall:
                if videoCallViewModel == nil {
                    Color.clear.onAppear {
                        videoCallViewModel = VideoCallViewModel(
                            gameRepository: coordinator.gameRepository,
                            users: coordinator.users,
                            swappedUserId: coordinator.swappedUserId
                        )
                    }
                }
                if let vm = videoCallViewModel {
                    VideoCallView(viewModel: vm)
                        .onChange(of: coordinator.users) { _, newUsers in
                            vm.updateUsers(newUsers)
                        }
                }
                
            case .answerInput:
                AnswerInputView(
                    viewModel: AnswerInputViewModel(
                        gameRepository: coordinator.gameRepository,
                        users: coordinator.users,
                        myUserId: coordinator.myUserId
                    )
                )
                
            case .answerReveal:
                AnswerView(
                    viewModel: AnswerRevealViewModel(
                        allAnswers: coordinator.allAnswers,
                        swappedUserId: coordinator.swappedUserId ?? "",
                        users: coordinator.users,
                        myUserId: coordinator.myUserId,
                        onRestart: {
                            coordinator.resetGame()
                        }
                    )
                )
            }
        }
        .animation(.easeInOut, value: coordinator.currentScreen)
    }
}

#Preview {
    ContentView()
}
