//
//  AnswerRevealView.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import SwiftUI
import Combine

struct AnswerRevealView: View {
    @State private var viewModel: AnswerRevealViewModel
    
    init(
        usersPublisher: AnyPublisher<[User], Never>,
        allAnswers: [PlayerAnswer],
        wolfUser: User,
        me: User,
        onRestart: @escaping () -> Void
    ) {
        self.viewModel = AnswerRevealViewModel(
            usersPublisher: usersPublisher,
            allAnswers: allAnswers,
            wolfUser: wolfUser,
            me: me,
            onRestart: onRestart
        )
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
                            viewModel.myAnswer?.isCorrect == true
                                ? Color.green.opacity(0.35)
                                : Color.red.opacity(0.35),
                            viewModel.myAnswer?.isCorrect == true
                                ? Color.blue.opacity(0.35)
                                : Color.orange.opacity(0.35)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.2),
                            Color.black.opacity(0.3)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            ScrollView {
                VStack(spacing: 5) {

                    // 結果表示
                    VStack(spacing: 10) {
                        if viewModel.myAnswer?.isCorrect == true {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 55))
                                .foregroundStyle(Color(red: 0.0, green: 0.7843, blue: 0.3686))
                                .padding(.top, 20)

                            Text("正解！")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.white)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 55))
                                .foregroundStyle(.red)
                                .padding(.top, 20)

                            Text("残念...")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }

                        // 正解発表
                        VStack(spacing: 10) {
                            Text("人狼(顔が変わった人)は...")
                                .font(.system(size: 18))
                                .foregroundStyle(.white.opacity(0.9))
                            
                            HStack(spacing: 15) {
                                Circle()
                                    .foregroundStyle(.white.opacity(0.6))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(.white)
                                    )
                                
                                Text(viewModel.wolfUser.name)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(
                                                LinearGradient(
                                                    colors: viewModel.myAnswer?.isCorrect == true
                                                        ? [
                                                            Color(red: 0.0, green: 0.7843, blue: 0.3686).opacity(0.28),
                                                            Color(red: 0.0, green: 0.7843, blue: 0.3686).opacity(0.12)
                                                        ]
                                                        : [
                                                            Color(red: 0.95, green: 0.2, blue: 0.25).opacity(0.28),
                                                            Color(red: 0.95, green: 0.2, blue: 0.25).opacity(0.12)
                                                        ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        .white.opacity(0.85),
                                                        .white.opacity(0.2),
                                                        .white.opacity(0.6)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.4
                                            )
                                    )
                            )
                            .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 8)
                        }
                    }
                    .padding(.horizontal, 26)
                    .padding(.vertical, 18)
                    
                    // 全員の回答
                    VStack(spacing: 15) {
                        Text("みんなの回答")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 30)
                        
                        ForEach(viewModel.answers) { answer in
                            let isMe = answer.answer.id == viewModel.me.id
                            HStack(spacing: 15) {
                                // プレイヤー名
                                HStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .foregroundStyle(.white)
                                                .font(.system(size: 16))
                                        )
                                    
                                    Text(answer.answer.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.white)
                                }
                                
                                Image(systemName: "arrow.right")
                                    .foregroundStyle(.white.opacity(0.6))
                                
                                // 回答
                                if let selectedUser = viewModel.users.first(where: { $0.id == answer.selectedUser.id }) {
                                    Text(selectedUser.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.white)
                                } else {
                                    Text("未回答")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                // 正解/不正解
                                if answer.isCorrect {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color(red: 0.0, green: 0.7843, blue: 0.3686))
                                } else {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                isMe
                                                    ? AnyShapeStyle(
                                                        viewModel.myAnswer?.isCorrect == true
                                                            ? Color(red: 0.0, green: 0.7843, blue: 0.3686)
                                                            : Color(red: 0.95, green: 0.2, blue: 0.25)
                                                    )
                                                    : AnyShapeStyle(
                                                        LinearGradient(
                                                            colors: [
                                                                .white.opacity(0.7),
                                                                .white.opacity(0.2),
                                                                .white.opacity(0.6)
                                                            ],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    ),
                                                lineWidth: isMe ? 1.8 : 1.1
                                            )
                                    )
                            )
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 6)
                            .padding(.horizontal, 30)
                        }
                    }
                    .padding(.top, 20)
                    
                    // もう一度遊ぶボタン
                    Button(action: {
                        viewModel.restart()
                    }) {
                        Text("もう一度遊ぶ")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                ZStack {
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: Color(red: 0.34, green: 0.7, blue: 1.0), location: 0.0),
                                            .init(color: Color(red: 0.62, green: 0.46, blue: 1.0), location: 1.0)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.ultraThinMaterial)
                                        .opacity(0.12)
                                }
                            )
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
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
                            .shadow(color: Color(red: 0.2235, green: 0.4, blue: 1.0).opacity(0.45), radius: 14, x: 0, y: 6)
                            .shadow(color: Color(red: 0.2235, green: 0.4, blue: 1.0).opacity(0.25), radius: 24, x: 0, y: 12)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

private func makeUser(name: String, role: Role = .undefined) -> User {
    var user = User(name: name)
    user.role = role
    return user
}

#Preview {
    let user1 = User(name: "あなた")
    let user2 = makeUser(name: "太郎", role: .werewolf)
    let user3 = User(name: "花子")
    let user4 = User(name: "次郎")
    
    let users = [user1, user2, user3, user4]
    
    let answers = [
        PlayerAnswer(answer: user1, selectedUser: user2, isCorrect: true),
        PlayerAnswer(answer: user2, selectedUser: user3, isCorrect: false),
        PlayerAnswer(answer: user3, selectedUser: user2, isCorrect: true),
        PlayerAnswer(answer: user4, selectedUser: user2, isCorrect: true)
    ]
    
    let usersPublisher = Just(users).eraseToAnyPublisher()
    
    AnswerRevealView(
        usersPublisher: usersPublisher,
        allAnswers: answers,
        wolfUser: user2,
        me: user1,
        onRestart: { print("Restart tapped") }
    )
}
