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
                gradient: Gradient(colors: [
                    Color(red: 0.35, green: 0.37, blue: 0.41),
                    Color(red: 0.55, green: 0.58, blue: 0.64)
                ]),
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
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.5),
                                                Color.white.opacity(0.15)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .opacity(showRole ? 0 : 1)
                    .animation(.easeInOut(duration: 0.5), value: showRole)
                
                // 役職カード
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    getRoleAccentColor().opacity(0.2),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.18)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.55),
                                            Color.white.opacity(0.18)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color.white.opacity(0.08), radius: 16, x: 0, y: 12)
                        .frame(width: 300, height: 400)
                    
                    VStack(spacing: 30) {
                        // 役職アイコン
                        ZStack {
                            Circle()
                                .fill(getRoleIconBackgroundColor())
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                )
                            
                            Image(getRoleIcon())
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                        }
                        
                        // 役職名
                        roleTitleView()
                        
                        // 説明文
                        Text(getRoleDescription())
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.75))
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
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.5),
                                                        Color.white.opacity(0.15)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
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
    
    private func getRoleAccentColor() -> Color {
        guard let role = viewModel.role else {
            return Color.gray
        }
        
        switch role {
        case .werewolf:
            return Color.red
        case .villager:
            return Color.blue
        case .undefined:
            return Color.gray
        }
    }
    
    // 役職アイコンを返す
    private func getRoleIcon() -> String {
        guard let role = viewModel.role else {
            return "questionmark"
        }
        
        switch role {
        case .werewolf:
            return "wolf"
        case .villager:
            return "citizen"
        case .undefined:
            return "questionmark.circle.fill"
        }
    }
    
    // 役職アイコンの背景色を返す
    private func getRoleIconBackgroundColor() -> Color {
        guard let role = viewModel.role else {
            return Color.gray
        }
        
        switch role {
        case .werewolf:
            return Color.red.opacity(0.9)
        case .villager:
            return Color.blue.opacity(0.9)
        case .undefined:
            return Color.gray
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
        case .undefined:
            return "未設定"
        }
    }

    @ViewBuilder
    private func roleTitleView() -> some View {
        let title = getRoleText()
        switch viewModel.role {
        case .werewolf, .villager:
            let baseColor = getRoleTitleBaseColor()
            ZStack {
                Text(title)
                    .font(.custom("Avenir Next", size: 36).weight(.semibold))
                    .foregroundColor(baseColor.opacity(0.55))
                    .shadow(color: baseColor.opacity(0.25), radius: 8, x: 0, y: 4)

                Text(title)
                    .font(.custom("Avenir Next", size: 36).weight(.semibold))
                    .foregroundColor(Color.white.opacity(0.55))
                    .shadow(color: Color.white.opacity(0.45), radius: 1, x: 0, y: 0)
                    .shadow(color: Color.white.opacity(0.25), radius: 2, x: 0, y: 0)
                    .blendMode(.screen)
                
                Text(title)
                    .font(.custom("Avenir Next", size: 36).weight(.semibold))
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                baseColor.opacity(0.95),
                                Color.white.opacity(0.75),
                                baseColor.opacity(0.85)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .blur(radius: 0.8)
                    )
                    .mask(
                        Text(title)
                            .font(.custom("Avenir Next", size: 36).weight(.semibold))
                    )
                    .shadow(color: baseColor.opacity(0.4), radius: 10, x: 0, y: 6)
                
                Text(title)
                    .font(.custom("Avenir Next", size: 36).weight(.semibold))
                    .foregroundColor(baseColor.opacity(0.3))
                    .blur(radius: 1.2)
            }
            .compositingGroup()
        default:
            Text(title)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(getRoleTextColor())
        }
    }

    private func getRoleTitleBaseColor() -> Color {
        switch viewModel.role {
        case .werewolf:
            return Color(red: 1.0, green: 0.4353, blue: 0.4157) // #FF6F6A
        case .villager:
            return Color(red: 0.2235, green: 0.4, blue: 1.0) // #3966FF
        default:
            return Color.white
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
        case .undefined:
            return Color.gray
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
        case .undefined:
            return "役職が割り当てられていません"
        }
    }
}

#Preview {
    RoleRevealView(
        myRole: .werewolf,
        onStartVideoCall: { print("Video call started") }
    )
}
