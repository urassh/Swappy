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
        swappedUserId: String,
        myUserId: String,
        onRestart: @escaping () -> Void
    ) {
        self.viewModel = AnswerRevealViewModel(
            usersPublisher: usersPublisher,
            allAnswers: allAnswers,
            swappedUserId: swappedUserId,
            myUserId: myUserId,
            onRestart: onRestart
        )
    }
    
    var correctUser: User? {
        viewModel.correctUser
    }
    
    var myResult: PlayerAnswer? {
        viewModel.myResult
    }
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                gradient: Gradient(colors: [
                    myResult?.isCorrect == true ? Color.green.opacity(0.7) : Color.red.opacity(0.7),
                    myResult?.isCorrect == true ? Color.blue.opacity(0.7) : Color.orange.opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer()
                        .frame(height: 50)
                    
                    // 結果表示
                    VStack(spacing: 20) {
                        if myResult?.isCorrect == true {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                            Text("正解！")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                            Text("残念...")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        // 正解発表
                        VStack(spacing: 10) {
                            Text("人狼(顔が変わった人)は...")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.9))
                            
                            HStack(spacing: 15) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.purple)
                                    )
                                
                                Text(correctUser?.name ?? "不明")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                        }
                    }
                    
                    // 全員の回答
                    VStack(spacing: 15) {
                        Text("みんなの回答")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 30)
                        
                        ForEach(viewModel.answers) { answer in
                            HStack(spacing: 15) {
                                // プレイヤー名
                                HStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 16))
                                        )
                                    
                                    Text(answer.playerName)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white.opacity(0.6))
                                
                                // 回答
                                if let selectedUserId = answer.selectedUserId,
                                   let selectedUser = viewModel.users.first(where: { $0.id == selectedUserId }) {
                                    Text(selectedUser.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                } else {
                                    Text("未回答")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                // 正解/不正解
                                if answer.isCorrect {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(15)
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
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    let users = [
        User(id: "1", name: "あなた"),
        User(id: "2", name: "太郎"),
        User(id: "3", name: "花子"),
        User(id: "4", name: "次郎")
    ]
    
    return AnswerView(viewModel: AnswerRevealViewModel(
        allAnswers: [
            PlayerAnswer(id: "1", playerName: "あなた", selectedUserId: "2", isCorrect: true),
            PlayerAnswer(id: "2", playerName: "太郎", selectedUserId: "3", isCorrect: false),
            PlayerAnswer(id: "3", playerName: "花子", selectedUserId: "2", isCorrect: true),
            PlayerAnswer(id: "4", playerName: "次郎", selectedUserId: "4", isCorrect: false)
        ],
        swappedUserId: "2",
        users: users,
        myUserId: "1",
        onRestart: {}
    ))
}
