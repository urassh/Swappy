//
//  AnswerInputView.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import SwiftUI
import Combine

struct AnswerInputView: View {
    @State private var viewModel: AnswerInputViewModel
    
    init(
        usersPublisher: AnyPublisher<[User], Never>,
        me: User,
        onSubmit: @escaping (User) -> Void
    ) {
        self.viewModel = AnswerInputViewModel(
            usersPublisher: usersPublisher,
            me: me,
            onSubmit: onSubmit
        )
    }
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.indigo,
                    Color.purple
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // タイトル
                VStack(spacing: 15) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("人狼は誰だ？")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("顔が入れ替わっていた人を選んでください")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // ユーザー選択肢
                VStack(spacing: 15) {
                    ForEach(viewModel.selectableUsers) { user in
                        Button(action: {
                            viewModel.selectedUser = user
                        }) {
                            HStack(spacing: 15) {
                                // アバター
                                Circle()
                                    .fill(viewModel.selectedUser?.id == user.id ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(viewModel.selectedUser?.id == user.id ? Color.purple : .white)
                                    )
                                
                                // 名前
                                Text(user.name)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                // チェックマーク
                                if viewModel.selectedUser?.id == user.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(
                                viewModel.selectedUser?.id == user.id
                                    ? Color.white.opacity(0.3)
                                    : Color.white.opacity(0.15)
                            )
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(
                                        viewModel.selectedUser?.id == user.id ? Color.white : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // 回答ボタン
                Button(action: {
                    viewModel.submitAnswer()
                }) {
                    Text("回答する")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            viewModel.canSubmit
                                ? LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                : LinearGradient(
                                    gradient: Gradient(colors: [Color.gray, Color.gray]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                        )
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(!viewModel.canSubmit)
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    let users = [
        User(name: "あなた"),
        User(name: "太郎"),
        User(name: "花子"),
        User(name: "次郎")
    ]
    let usersPublisher = Just(users).eraseToAnyPublisher()
    
    AnswerInputView(
        usersPublisher: usersPublisher,
        me: users.first!,
        onSubmit: { userId in print("Selected user: \(userId)") }
    )
}
