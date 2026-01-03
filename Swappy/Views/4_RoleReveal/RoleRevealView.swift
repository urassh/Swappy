//
//  RoleRevealView.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import SwiftUI

struct RoleRevealView: View {
    @State private var viewModel: RoleRevealViewModel
    @State private var showRole = false
    
    init(myRole: Role?, onStartVideoCall: @escaping () -> Void) {
        self.viewModel = RoleRevealViewModel(
            myRole: myRole,
            onStartVideoCall: onStartVideoCall
        )
    }
    
    var body: some View {
        ZStack {
            // 背景のグラデーション
            LinearGradient(
                gradient: Gradient(colors: getRoleColors()),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // タイトル
                Text("あなたの役職は...")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(showRole ? 0 : 1)
                    .animation(.easeInOut(duration: 0.5), value: showRole)
                
                // 役職カード
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                        .frame(width: 300, height: 400)
                    
                    VStack(spacing: 30) {
                        // 役職アイコン
                        ZStack {
                            Circle()
                                .fill(getRoleIconBackgroundColor())
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: getRoleIcon())
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                        }
                        
                        // 役職名
                        Text(getRoleText())
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(getRoleTextColor())
                        
                        // 説明文
                        Text(getRoleDescription())
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .padding()
                }
                .scaleEffect(showRole ? 1.0 : 0.8)
                .opacity(showRole ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showRole)
                
                // カウントダウン表示
                if showRole {
                    Text("\(viewModel.countdown)秒後にゲーム開始")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .transition(.opacity)
                }
                
                Spacer()
                
                // スキップボタン
                if showRole {
                    Button(action: {
                        viewModel.skipToVideoCall()
                    }) {
                        Text("すぐに始める")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(25)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
            }
        }
        .onAppear {
            // 1秒後に役職を表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showRole = true
            }
        }
    }
    
    // 役職に応じた色を返す
    private func getRoleColors() -> [Color] {
        guard let role = viewModel.role else {
            return [Color.gray, Color.gray.opacity(0.7)]
        }
        
        switch role {
        case .werewolf:
            return [Color.red.opacity(0.8), Color.orange.opacity(0.6)]
        case .villager:
            return [Color.blue.opacity(0.8), Color.cyan.opacity(0.6)]
        }
    }
    
    // 役職アイコンを返す
    private func getRoleIcon() -> String {
        guard let role = viewModel.role else {
            return "questionmark"
        }
        
        switch role {
        case .werewolf:
            return "moon.stars.fill"
        case .villager:
            return "person.3.fill"
        }
    }
    
    // 役職アイコンの背景色を返す
    private func getRoleIconBackgroundColor() -> Color {
        guard let role = viewModel.role else {
            return Color.gray
        }
        
        switch role {
        case .werewolf:
            return Color.red
        case .villager:
            return Color.blue
        }
    }
    
    // 役職名を返す
    private func getRoleText() -> String {
        guard let role = viewModel.role else {
            return "不明"
        }
        
        switch role {
        case .werewolf:
            return "人狼"
        case .villager:
            return "市民"
        }
    }
    
    // 役職のテキスト色を返す
    private func getRoleTextColor() -> Color {
        guard let role = viewModel.role else {
            return Color.gray
        }
        
        switch role {
        case .werewolf:
            return Color.red
        case .villager:
            return Color.blue
        }
    }
    
    // 役職の説明文を返す
    private func getRoleDescription() -> String {
        guard let role = viewModel.role else {
            return ""
        }
        
        switch role {
        case .werewolf:
            return "あなたは顔が入れ替わります。\nバレないように振る舞いましょう！"
        case .villager:
            return "誰が顔が入れ替わったか\n見極めてください！"
        }
    }
}

#Preview {
    RoleRevealView(
        myRole: .werewolf,
        onStartVideoCall: { print("Video call started") }
    )
}
