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
    private let onBack: (() -> Void)?
    private let onToggleMic: (Bool) -> Void
    @State private var isMicMuted: Bool
    
    init(
        usersPublisher: AnyPublisher<[User], Never>,
        videoViews: [UUID: UIView],
        me: User,
        onToggleMic: @escaping (Bool) -> Void,
        onTimeUp: @escaping () -> Void,
        onBack: (() -> Void)? = nil
    ) {
        self.viewModel = VideoCallViewModel(
            usersPublisher: usersPublisher,
            videoViews: videoViews,
            onTimeUp: onTimeUp
        )
        self.onToggleMic = onToggleMic
        _isMicMuted = State(initialValue: me.isMuted)
        self.onBack = onBack
    }
    
    var body: some View {
        let currentMeMuted = isMicMuted
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
            
            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.35), lineWidth: 2)
                            .frame(width: 72, height: 72)

                        Circle()
                            .trim(from: 0, to: CGFloat(viewModel.timeRemaining) / 10.0)
                            .stroke(
                                Color(red: 1.0, green: 0.4353, blue: 0.4157),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .frame(width: 72, height: 72)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: viewModel.timeRemaining)
                        
                        Text("\(viewModel.timeRemaining)")
                            .font(.custom("Avenir Next", size: 28).weight(.semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding(.top, 48)
                
                // ビデオグリッド
                GeometryReader { geometry in
                    let columns = [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)]
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(viewModel.users) { user in
                            VideoTileView(
                                user: user,
                                videoView: viewModel.videoViews[user.id]
                            )
                            .aspectRatio(0.8, contentMode: .fit)
                        }
                    }
                    .padding(.horizontal, 0)
                }
                .padding(.top, 24)

                Spacer(minLength: 8)
                
                VStack(spacing: 12) {
                    Text("誰が人狼(顔が変わった人)か見極めよう！")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 18)
                        .background(Color(red: 1.0, green: 0.39, blue: 0.42))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    
                    controlBar(isMuted: currentMeMuted)
                }
                .padding(.bottom, 36)
            }
        }
    }
    
    @ViewBuilder
    private func controlBar(isMuted: Bool) -> some View {
        HStack(spacing: 18) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "video")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    )
                
                Button(action: {
                    let nextMuted = !isMuted
                    isMicMuted = nextMuted
                    onToggleMic(nextMuted)
                }) {
                    Circle()
                        .fill(Color.white.opacity(isMuted ? 0.1 : 0.22))
                        .frame(width: 48, height: 48)
                        .overlay(
                            ZStack {
                                if isMuted {
                                    Image("MicIcon")
                                        .resizable()
                                        .renderingMode(.original)
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                    Image("IconSlash")
                                        .resizable()
                                        .renderingMode(.original)
                                        .scaledToFit()
                                        .frame(width: 22, height: 22)
                                } else {
                                    Image("MicOn")
                                        .resizable()
                                        .renderingMode(.original)
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                }
                            }
                        )
                }
                
                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    )
            }
            
            Circle()
                .fill(Color.clear)
                .frame(width: 80, height: 80)
                .background(
                    Image("CallEnd")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                )
                .overlay(
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .offset(y: -8)
                )
                .offset(y: 6)
                .padding(.leading, 24)
        }
        .padding(.horizontal, 26)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
        )
    }

}

struct VideoTileView: View {
    let user: User
    let videoView: UIView?
    
    var body: some View {
        ZStack {
            // ビデオビューまたは仮のグラデーション
            if let videoView = videoView {
                VideoViewWrapper(view: videoView)
            } else {
                // ビデオプレビュー（仮のグラデーション）
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.18),
                        Color.white.opacity(0.06),
                        Color.white.opacity(0.12)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .background(Color.white.opacity(0.1))
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.2)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.screen)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.55),
                                    Color.white.opacity(0.12)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.6
                        )
                )
                
                // ユーザーアイコン
                VStack {
                    Circle()
                        .fill(Color.white.opacity(0.95))
                        .frame(width: 64, height: 64)
                        .shadow(color: Color(red: 0.22, green: 0.4, blue: 1.0).opacity(0.5), radius: 12, x: 0, y: 6)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.35))
                        )
                }
            }
            
            // ユーザー名
            VStack {
                Spacer()
                
                HStack {
                    micStatusView()
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    Text(user.name)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .padding(.trailing, 8)
                    
                }
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.white.opacity(0.28), lineWidth: 1.8)
        )
        .shadow(color: Color.white.opacity(0.08), radius: 10, x: 0, y: 8)
    }
    
    @ViewBuilder
    private func micStatusView() -> some View {
        if user.isMuted {
            ZStack {
                Image("MicIcon")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                Image("IconSlash")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
        } else {
            Image("MicOn")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 18, height: 18)
        }
    }
}

#Preview {
    let me = PreviewData.users[0]
    VideoCallView(
        usersPublisher: PreviewData.usersPublisher,
        videoViews: [:],
        me: me,
        onToggleMic: { _ in },
        onTimeUp: {},
        onBack: {}
    )
}

// MARK: - VideoViewWrapper

/// UIViewをSwiftUIで表示するためのラッパー
struct VideoViewWrapper: UIViewRepresentable {
    let view: UIView
    
    func makeUIView(context: Context) -> UIView {
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 更新処理は不要
    }
}

// MARK: - Preview

private enum PreviewData {
    static let users: [User] = [
        User(name: "勇者（あなた）", isMuted: false),
        User(name: "村人A"),
        User(name: "魔法使い"),
        User(name: "レンジャー")
    ]

    static let usersPublisher: AnyPublisher<[User], Never> =
    Just(users).eraseToAnyPublisher()
}
