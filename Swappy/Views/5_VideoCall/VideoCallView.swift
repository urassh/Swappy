//
//  VideoCallView.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import SwiftUI
import Combine

struct VideoCallView: View {
    @State private var viewModel: VideoCallViewModel
    
    init(
        usersPublisher: AnyPublisher<[User], Never>,
        onTimeUp: @escaping () -> Void
    ) {
        self.viewModel = VideoCallViewModel(
            usersPublisher: usersPublisher,
            onTimeUp: onTimeUp
        )
    }
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // タイマー
                HStack {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 4)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(viewModel.timeRemaining) / 10.0)
                            .stroke(
                                Color.red,
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: viewModel.timeRemaining)
                        
                        Text("\(viewModel.timeRemaining)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding(.top, 50)
                
                // ビデオグリッド
                GeometryReader { geometry in
                    let columns = 2
                    let rows = Int(ceil(Double(viewModel.users.count) / Double(columns)))
                    
                    VStack(spacing: 2) {
                        ForEach(0..<rows, id: \.self) { row in
                            HStack(spacing: 2) {
                                ForEach(0..<columns, id: \.self) { col in
                                    let index = row * columns + col
                                    if index < viewModel.users.count {
                                        VideoTileView(
                                            user: viewModel.users[index],
                                            isSwapped: viewModel.users[index].isWolf
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 20)

                Text("誰が人狼(顔が変わった人)か見極めよう！")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.bottom, 40)
            }
        }
    }
}

struct VideoTileView: View {
    let user: User
    let isSwapped: Bool
    
    var body: some View {
        ZStack {
            // ビデオプレビュー（仮のグラデーション）
            LinearGradient(
                gradient: Gradient(colors: [
                    isSwapped ? Color.red.opacity(0.6) : Color.purple.opacity(0.6),
                    isSwapped ? Color.orange.opacity(0.6) : Color.pink.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // ユーザーアイコン
            VStack {
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.7))
                
                // 入れ替わりエフェクト（デバッグ用、本番では非表示）
                if isSwapped {
                    Image(systemName: "shuffle")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                        .opacity(0.0) // 本番では見えないようにする
                }
            }
            
            // ユーザー名
            VStack {
                Spacer()
                
                HStack {
                    Text(user.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        .padding(8)
                    
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(8)
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
    
    VideoCallView(
        usersPublisher: usersPublisher, onTimeUp: {})
}
