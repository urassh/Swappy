//
//  RobbyView.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import SwiftUI
import Combine

struct RobbyView: View {
    @State private var viewModel: RobbyViewModel
    
    init(
        usersPublisher: AnyPublisher<[User], Never>,
        me: User,
        onMuteMic: @escaping () -> Void,
        onUnmuteMic: @escaping () -> Void,
        onStartGame: @escaping () -> Void
    ) {
        self.viewModel = RobbyViewModel(
            usersPublisher: usersPublisher,
            me: me,
            onMuteMic: onMuteMic,
            onUnmuteMic: onUnmuteMic,
            onStartGame: onStartGame
        )
    }
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.8),
                    Color.blue.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // ヘッダー
                VStack(spacing: 10) {
                    Text("村の集会所")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("村: \(viewModel.users.first?.name ?? "Unknown")")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 50)
                
                // 参加者リスト
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(viewModel.users) { user in
                            HStack(spacing: 15) {
                                // アバター
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.white)
                                    )
                                
                                // 名前
                                Text(user.name)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                // 準備状態
                                if user.isReady {
                                    HStack(spacing: 5) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("準備完了")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                    }
                                } else {
                                    Text("待機中...")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                // マイク状態
                                Image(systemName: user.isMuted ? "mic.slash.fill" : "mic.fill")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // コントロール
                VStack(spacing: 20) {
                    // マイクボタン
                    Button(action: {
                        viewModel.toggleMic()
                    }) {
                        HStack {
                            Image(systemName: viewModel.isMicMuted ? "mic.slash.fill" : "mic.fill")
                                .font(.system(size: 20))
                            Text(viewModel.isMicMuted ? "マイクオフ" : "マイクオン")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isMicMuted ? Color.red.opacity(0.7) : Color.white.opacity(0.2))
                        .cornerRadius(15)
                    }
                    .padding(.horizontal, 30)

                    // ゲーム開始できない理由の表示
                    if let reason = viewModel.startGameDisabledReason {
                        Text(reason)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                            .background(Color.orange.opacity(0.3))
                            .cornerRadius(10)
                    }
                    
                    // ゲーム開始ボタン
                    Button(action: {
                        viewModel.startGame()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.system(size: 20))
                            Text("ゲーム開始")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canStartGame ? Color.green.opacity(0.8) : Color.gray.opacity(0.5))
                        .cornerRadius(15)
                    }
                    .disabled(!viewModel.canStartGame)
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    let me = User(name: "あなた")
    let users = [
        me,
        User(name: "太郎", isReady: false),
        User(name: "花子", isReady: true)
    ]
    let usersPublisher = Just(users).eraseToAnyPublisher()
    
    RobbyView(
        usersPublisher: usersPublisher,
        me: me,
        onMuteMic: {},
        onUnmuteMic: {},
        onStartGame: {}
    )
}
