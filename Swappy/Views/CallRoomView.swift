//
//  CallRoomView.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import SwiftUI

struct CallRoomView: View {
    @Bindable var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // トップバー
                HStack {
                    Button(action: {
                        viewModel.resetGame()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(viewModel.keyword)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // グリッド表示切り替え
                    }) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                // ビデオグリッド
                if viewModel.users.count <= 2 {
                    // 1-2人の場合は縦に並べる
                    VStack(spacing: 2) {
                        ForEach(viewModel.users) { user in
                            CallRoomVideoTileView(user: user)
                        }
                    }
                } else {
                    // 3人以上の場合はグリッド表示
                    GeometryReader { geometry in
                        let columns = 2
                        let rows = Int(ceil(Double(viewModel.users.count) / Double(columns)))
                        
                        VStack(spacing: 2) {
                            ForEach(0..<rows, id: \.self) { row in
                                HStack(spacing: 2) {
                                    ForEach(0..<columns, id: \.self) { col in
                                        let index = row * columns + col
                                        if index < viewModel.users.count {
                                            CallRoomVideoTileView(user: viewModel.users[index])
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // コントロールバー
                HStack(spacing: 30) {
                    // カメラ切り替え
                    Button(action: {
                        // カメラ切り替え
                    }) {
                        Image(systemName: "camera.rotate")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    // マイク
                    Button(action: {
                        viewModel.toggleMic()
                    }) {
                        Image(systemName: viewModel.isMicMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(viewModel.isMicMuted ? Color.red.opacity(0.8) : Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    // 通話終了
                    Button(action: {
                        viewModel.resetGame()
                    }) {
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.red, Color.pink]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: Color.red.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
}

struct CallRoomVideoTileView: View {
    let user: User
    
    var body: some View {
        ZStack {
            // ビデオプレビュー（仮のグラデーション）
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.6),
                    Color.pink.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // ユーザーアイコン
            VStack {
                Image(systemName: "person.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // ユーザー名
            VStack {
                Spacer()
                
                HStack {
                    Text(user.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        .padding(8)
                    
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(8)
    }
}

#Preview {
    CallRoomView(viewModel: {
        let vm = GameViewModel()
        vm.gameState = .robby
        vm.keyword = "AAA"
        vm.users = [
            User(id: "1", name: "あなた"),
            User(id: "2", name: "ユーザー1"),
            User(id: "3", name: "ユーザー2")
        ]
        return vm
    }())
}
