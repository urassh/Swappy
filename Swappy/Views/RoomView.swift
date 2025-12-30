//
//  RoomView.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import SwiftUI

struct RoomView: View {
    @Bindable var viewModel: GameViewModel
    
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
                    Text("待機ロビー")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("ルーム: \(viewModel.keyword)")
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
                    
                    // 準備完了ボタン
                    Button(action: {
                        viewModel.toggleReady()
                    }) {
                        Text(viewModel.users.first?.isReady == true ? "準備完了を取り消す" : "準備完了")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        viewModel.users.first?.isReady == true ? Color.orange : Color.green,
                                        viewModel.users.first?.isReady == true ? Color.red : Color.blue
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 30)
                    
                    // 全員準備完了の表示
                    if viewModel.allUsersReady {
                        Text("まもなくゲーム開始...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    RoomView(viewModel: {
        let vm = GameViewModel()
        vm.gameState = .waitingRoom
        vm.keyword = "TEST123"
        vm.users = [
            User(id: "1", name: "あなた", isReady: true),
            User(id: "2", name: "太郎", isReady: false),
            User(id: "3", name: "花子", isReady: true)
        ]
        return vm
    }())
}
