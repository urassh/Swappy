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
            Image("Background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.25),
                            Color.black.opacity(0.35)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 24) {
                    // アニメーションアイコン
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 130, height: 130)
                            .shadow(color: Color(red: 0.22, green: 0.4, blue: 1.0).opacity(0.9), radius: 18, x: 0, y: 0)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.5),
                                                Color.white.opacity(0.12)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                        
                        Image("shuffle")
                            .resizable()
                            .renderingMode(.original)
                            .scaledToFit()
                            .frame(width: 130, height: 130)
                            .scaleEffect(animationScale)
                    }
                    .onAppear {
                        withAnimation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true)
                        ) {
                            animationScale = 1.2
                        }
                    }
                    
                    VStack(spacing: 12) {
                        Text("役職を決定中...")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("あなたの役割が決まるまでお待ちください")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    // ローディングインジケーター
                    ProgressView()
                        .scaleEffect(1.4)
                        .tint(.white)
                        .padding(.top, 6)
                }
                .padding(.vertical, 36)
                .padding(.horizontal, 28)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.35),
                                    Color.white.opacity(0.08),
                                    Color.white.opacity(0.2)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(
                                    Color(red: 0.3647, green: 0.3843, blue: 0.9412),
                                    lineWidth: 1.2
                                )
                        )
                )
                .shadow(color: Color.white.opacity(0.08), radius: 12, x: 0, y: 10)
                
                Spacer()
            }
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    RoleWaitingView()
}
