//
//  KeywordView.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import SwiftUI

struct KeywordInputView: View {
    @Bindable private var viewModel: KeywordInputViewModel
    
    init(viewModel: KeywordInputViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
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
            
            VStack {
                Spacer(minLength: 8)
                
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 140, height: 140)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                )
                                .shadow(color: Color(red: 0.36, green: 0.45, blue: 0.96).opacity(0.6), radius: 16, x: 0, y: 8)
                            
                            Image("Swappy")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 140, height: 140)
                                .clipShape(Circle())
                        }
                        
                        ZStack {
                            Text("Swappy人狼")
                                .font(.custom("Avenir Next", size: 28).weight(.semibold))
                                .foregroundColor(Color.white.opacity(0.55))
                                .shadow(color: Color.white.opacity(0.2), radius: 8, x: 0, y: 4)
                            
                            Text("Swappy人狼")
                                .font(.custom("Avenir Next", size: 28).weight(.semibold))
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.9),
                                            Color.white.opacity(0.6),
                                            Color.white.opacity(0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .blur(radius: 0.8)
                                )
                                .mask(
                                    Text("Swappy人狼")
                                        .font(.custom("Avenir Next", size: 28).weight(.semibold))
                                )
                                .shadow(color: Color.white.opacity(0.35), radius: 10, x: 0, y: 6)
                            
                            Text("Swappy人狼")
                                .font(.custom("Avenir Next", size: 28).weight(.semibold))
                                .foregroundColor(Color.white.opacity(0.25))
                                .blur(radius: 1.2)
                        }
                        .compositingGroup()
                        
                        Text("-Face Swap人狼ゲーム-")
                            .font(.custom("Avenir Next", size: 12))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                    
                    VStack(spacing: 8) {
                        Text("ゲームのルール")
                            .font(.custom("Avenir Next", size: 12).weight(.semibold))
                            .foregroundColor(Color.white.opacity(0.75))
                        
                        Text("10秒間のビデオ通話で、1人だけ顔が入れ替わります。\n人狼(顔が変わった人)を見つけ出そう！")
                            .font(.custom("Avenir Next", size: 11))
                            .foregroundColor(Color.white.opacity(0.65))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 12)
                    
                    VStack(spacing: 14) {
                        VStack(spacing: 6) {
                            TextField("", text: $viewModel.userName)
                                .placeholder(when: viewModel.userName.isEmpty) {
                                    Text("あなたの名前を入力")
                                        .foregroundColor(Color.white.opacity(0.5))
                                }
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(.horizontal, 4)
                                .padding(.vertical, 6)
                                .foregroundColor(Color.white.opacity(0.85))
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.45))
                                .frame(height: 1)
                        }
                        
                        TextField("", text: $viewModel.keyword)
                            .placeholder(when: viewModel.keyword.isEmpty) {
                                Text("合言葉を入力")
                                    .foregroundColor(Color.white.opacity(0.5))
                            }
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.28),
                                                    Color.white.opacity(0.04)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                }
                            )
                            .foregroundColor(Color.white.opacity(0.85))
                            .shadow(color: Color.white.opacity(0.12), radius: 12, x: 0, y: 6)
                        
                        Button(action: {
                            viewModel.enterRoom()
                        }) {
                            Text("ルームに参加")
                                .font(.custom("Avenir Next", size: 16).weight(.semibold))
                                .foregroundColor(Color.white.opacity(0.95))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(red: 0.44, green: 0.50, blue: 0.97),
                                                        Color(red: 0.18, green: 0.22, blue: 0.55)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.75),
                                                        Color.white.opacity(0.12),
                                                        Color.white.opacity(0.35)
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .blendMode(.overlay)
                                        
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(color: Color(red: 0.30, green: 0.36, blue: 0.88).opacity(0.7), radius: 18, x: 0, y: 12)
                        }
                        .disabled(!viewModel.canEnterRoom)
                        .opacity(viewModel.canEnterRoom ? 1.0 : 0.55)
                    }
                    .padding(.horizontal, 32)
                }
                .frame(maxWidth: 360)
                
                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// TextField placeholder extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}


#Preview {
    KeywordInputView(
        viewModel: KeywordInputViewModel(onEnterRoom: { _, _ in })
    )
}
