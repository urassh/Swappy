//
//  RoleWaitingView.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/03.
//

import SwiftUI

struct RoleWaitingView: View {
    @State private var animationScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.8),
                    Color.indigo.opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // アニメーションアイコン
                Image(systemName: "shuffle.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .scaleEffect(animationScale)
                    .onAppear {
                        withAnimation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true)
                        ) {
                            animationScale = 1.3
                        }
                    }
                
                VStack(spacing: 15) {
                    Text("役職を決定中...")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("あなたの役割が決まるまでお待ちください")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // ローディングインジケーター
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                    .padding(.top, 20)
                
                Spacer()
            }
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    RoleWaitingView()
}
