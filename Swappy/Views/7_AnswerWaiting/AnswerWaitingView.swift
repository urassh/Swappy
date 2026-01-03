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
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.orange.opacity(0.8),
                    Color.pink.opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // アニメーションアイコン
                Image(systemName: "hourglass")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
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
                        .foregroundColor(.white)
                    
                    Text("他のプレイヤーの回答を待っています")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // 回答済みのプレイヤー数
                VStack(spacing: 10) {
                    Text("\(viewModel.answeredCount) / \(viewModel.totalCount)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("人が回答済み")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                
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
