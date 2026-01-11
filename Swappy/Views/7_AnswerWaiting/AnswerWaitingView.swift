//
//  AnswerWaitingView.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/03.
//

import SwiftUI
import Combine

struct AnswerWaitingView: View {
    @State private var viewModel: AnswerWaitingViewModel
    
    init(
        allAnswersPublisher: AnyPublisher<[PlayerAnswer], Never>,
        usersPublisher: AnyPublisher<[User], Never>
    ) {
        self.viewModel = AnswerWaitingViewModel(
            allAnswersPublisher: allAnswersPublisher,
            usersPublisher: usersPublisher
        )
    }
    
    @State private var animationScale: CGFloat = 1.0
    
    private var progressValue: Double {
        let total = max(viewModel.totalCount, 1)
        return Double(viewModel.answeredCount) / Double(total)
    }
    
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
                
                // アニメーションアイコン
                Image("Hourglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .scaleEffect(animationScale)
                    .rotationEffect(.degrees(animationScale > 1 ? 180 : 0))
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                    ) {
                        animationScale = 1.2
                    }
                }
                
                VStack(spacing: 15) {
                    Text("回答を集計中...")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("他のプレイヤーの回答を待っています")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                // 回答済みのプレイヤー数
                VStack(spacing: 14) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(viewModel.answeredCount)")
                            .font(.system(size: 52, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .monospacedDigit()
                        
                        Text("/ \(viewModel.totalCount)")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                            .monospacedDigit()
                    }
                    
                    Text("人が回答済み")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                    
                    GeometryReader { proxy in
                        let width = max(0, min(1, progressValue)) * proxy.size.width
                        
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.white.opacity(0.18))
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        stops: [
                                            .init(color: Color(red: 0.0, green: 0.784, blue: 0.369), location: 0.0),
                                            .init(color: Color(red: 0.0, green: 0.69, blue: 0.741), location: 0.4856),
                                            .init(color: Color(red: 0.0, green: 0.608, blue: 0.906), location: 1.0)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: width)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 22)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.9),
                                            .white.opacity(0.2),
                                            .white.opacity(0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.4
                                )
                        )
                )
                .shadow(color: .black.opacity(0.22), radius: 14, x: 0, y: 8)
                
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
    let user1 = User(name: "あなた")
    let user2 = User(name: "太郎")
    let user3 = User(name: "花子")
    let user4 = User(name: "次郎")
    
    let users = [user1, user2, user3, user4]
    let usersPublisher = Just(users).eraseToAnyPublisher()
    
    // 2人が既に回答済み
    let answers = [
        PlayerAnswer(answer: user1, selectedUser: user2, isCorrect: false),
        PlayerAnswer(answer: user2, selectedUser: user3, isCorrect: false)
    ]
    let allAnswersPublisher = Just(answers).eraseToAnyPublisher()
    
    AnswerWaitingView(
        allAnswersPublisher: allAnswersPublisher,
        usersPublisher: usersPublisher
    )
}
