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
                    Color(red: 0.35, green: 0.37, blue: 0.41),
                    Color(red: 0.55, green: 0.58, blue: 0.64)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // ヘッダー
                VStack(spacing: 10) {
                    Text("村の集会所")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("村: \(viewModel.users.first?.name ?? "Unknown")")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 50)
                
                // 参加者リスト
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(viewModel.users) { user in
                            HStack(spacing: 15) {
                                // アバター
                                Circle()
                                    .fill(Color.white.opacity(0.22))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.white)
                                    )
                                
                                // 名前
                                Text(user.name)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Spacer()
                                
                                // 準備状態
                                if user.isReady {
                                    HStack(spacing: 5) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color(red: 0.2, green: 0.9, blue: 0.6))
                                        Text("準備完了")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.85))
                                    }
                                } else {
                                    Text("待機中...")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.55))
                                }
                                
                                // マイク状態
                                Image(systemName: user.isMuted ? "mic.slash.fill" : "mic.fill")
                                    .foregroundColor(user.isMuted ? Color.white.opacity(0.5) : Color(red: 0.2, green: 0.9, blue: 0.6))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.22),
                                                Color.white.opacity(0.05),
                                                Color.white.opacity(0.11)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.25),
                                                        Color.white.opacity(0.08)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.06),
                                                        Color.white.opacity(0.0)
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .blendMode(.screen)
                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    )
                            )
                            .shadow(color: Color.white.opacity(0.04), radius: 8, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                
                Spacer()
                
                // コントロール
                VStack(spacing: 20) {
                    HStack(spacing: 24) {
                        Button(action: {
                            viewModel.startGame()
                        }) {
                            ZStack {
                                Image("IconRing")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .offset(y: 6)
                                Image("VideoIcon")
                                    .resizable()
                                    .renderingMode(.original)
                                    .scaledToFit()
                                    .frame(width: 24, height: 20)
                                if !viewModel.canStartGame {
                                    Image("VideoIconSlash")
                                        .resizable()
                                        .renderingMode(.original)
                                        .scaledToFit()
                                        .frame(width: 36, height: 36)
                                }
                            }
                        }
                        .disabled(!viewModel.canStartGame)
                        .opacity(viewModel.canStartGame ? 1.0 : 0.6)
                        
                        Button(action: {
                            viewModel.toggleMic()
                        }) {
                            ZStack {
                                Image("IconRing")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .offset(y: 6)
                                Image("MicIcon")
                                    .resizable()
                                    .renderingMode(.original)
                                    .scaledToFit()
                                    .frame(width: 20, height: 28)
                                if viewModel.isMicMuted {
                                    Image("IconSlash")
                                        .resizable()
                                        .renderingMode(.original)
                                        .scaledToFit()
                                        .frame(width: 36, height: 36)
                                }
                            }
                        }
                        .opacity(viewModel.isMicMuted ? 0.6 : 1.0)
                    }

                    // ゲーム開始できない理由の表示
                    if let reason = viewModel.startGameDisabledReason {
                        Text(reason)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.orange.opacity(0.25))
                            )
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
                        .foregroundColor(.white.opacity(0.95))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: viewModel.canStartGame ? [
                                            Color(red: 0.15, green: 0.8, blue: 0.55),
                                            Color(red: 0.1, green: 0.6, blue: 0.85)
                                        ] : [
                                            Color.white.opacity(0.25),
                                            Color.white.opacity(0.15)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                )
                        )
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
