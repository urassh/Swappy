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
            
            VStack(spacing: 30) {
                Spacer()
                
                // タイトル
                VStack(spacing: 15) {
                    Image("HatenaNoBg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .shadow(color: .white.opacity(0.4), radius: 12, x: 0, y: 4)
                    
                    Text("人狼は誰だ？")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("顔が入れ替わっていた人を選んでください")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 18)
                .padding(.top, -80)

//                Spacer()
                
                // ユーザー選択肢
                VStack(spacing: 15) {
                    ForEach(viewModel.selectableUsers) { user in
                        Button(action: {
                            viewModel.selectedUser = user
                        }) {
                            HStack(spacing: 15) {
                                // アバター
                                Circle()
                                    .fill(
                                        viewModel.selectedUser?.id == user.id
                                            ? AnyShapeStyle(Color.white)
                                            : AnyShapeStyle(Color.white.opacity(0.25))
                                    )
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundStyle(
                                                viewModel.selectedUser?.id == user.id
                                                    ? AnyShapeStyle(Color.purple)
                                                    : AnyShapeStyle(Color.white)
                                            )
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
                                        .foregroundColor(Color(red: 0.3647, green: 0.3843, blue: 0.9412))
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                viewModel.selectedUser?.id == user.id
                                                    ? AnyShapeStyle(Color(red: 0.3647, green: 0.3843, blue: 0.9412))
                                                    : AnyShapeStyle(
                                                        LinearGradient(
                                                            colors: [
                                                                .white.opacity(0.35),
                                                                .white.opacity(0.1)
                                                            ],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    ),
                                                lineWidth: viewModel.selectedUser?.id == user.id ? 2 : 1
                                            )
                                    )
                            )
                            .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 6)
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
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            ZStack {
                                if viewModel.canSubmit {
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: Color(red: 0.0, green: 0.784, blue: 0.369), location: 0.0),
                                            .init(color: Color(red: 0.0, green: 0.69, blue: 0.741), location: 0.4856),
                                            .init(color: Color(red: 0.0, green: 0.608, blue: 0.906), location: 1.0)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                } else {
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.7)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                }
                                
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(.ultraThinMaterial)
                                    .opacity(viewModel.canSubmit ? 0.12 : 0.6)
                            }
                        )
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(viewModel.canSubmit ? 0.9 : 0.4),
                                            .white.opacity(0.2),
                                            .white.opacity(viewModel.canSubmit ? 0.7 : 0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: viewModel.canSubmit ? 1.6 : 1
                                )
                        )
                        .shadow(
                            color: viewModel.canSubmit
                                ? Color.green.opacity(0.35)
                                : Color.black.opacity(0.3),
                            radius: viewModel.canSubmit ? 10 : 10,
                            x: 0,
                            y: viewModel.canSubmit ? 0 : 5
                        )
                        .shadow(
                            color: viewModel.canSubmit
                                ? Color.green.opacity(0.15)
                                : Color.clear,
                            radius: 18,
                            x: 0,
                            y: 0
                        )
                }
                .disabled(!viewModel.canSubmit)
                .padding(.horizontal, 30)
                .padding(.bottom, 70)
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
