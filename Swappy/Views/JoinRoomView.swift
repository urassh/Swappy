//
//  JoinRoomView.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import SwiftUI

struct JoinRoomView: View {
    @Bindable var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // グラデーション背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.8, green: 0.3, blue: 0.8),
                    Color(red: 1.0, green: 0.4, blue: 0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // アイコンとタイトル
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "video.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    
                    Text("Swappy")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("顔入れ替わりゲーム")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // 入力フォーム
                VStack(spacing: 20) {
                    // ユーザー名入力
                    TextField("", text: $viewModel.userName)
                        .placeholder(when: viewModel.userName.isEmpty) {
                            Text("あなたの名前を入力")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    // 合言葉入力
                    TextField("", text: $viewModel.keyword)
                        .placeholder(when: viewModel.keyword.isEmpty) {
                            Text("ルームの合言葉を入力")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    // 参加ボタン
                    Button(action: {
                        if !viewModel.keyword.isEmpty && !viewModel.userName.isEmpty {
                            viewModel.enterRoom()
                        }
                    }) {
                        Text("ルームに参加")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue,
                                        Color.purple
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .disabled(viewModel.keyword.isEmpty || viewModel.userName.isEmpty)
                    .opacity(viewModel.keyword.isEmpty || viewModel.userName.isEmpty ? 0.6 : 1.0)
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
        }
    }
}

// TextField placeholder extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    JoinRoomView(viewModel: GameViewModel())
}
