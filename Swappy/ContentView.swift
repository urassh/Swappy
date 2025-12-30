//
//  ContentView.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/28.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = GameViewModel()
    
    var body: some View {
        ZStack {
            switch viewModel.gameState {
            case .keywordInput:
                KeywordView(viewModel: viewModel)
                
            case .waitingRoom:
                RoomView(viewModel: viewModel)
                
            case .videoCall:
                VideoCallView(viewModel: viewModel)
                
            case .answerInput:
                AnswerInputView(viewModel: viewModel)
                
            case .answerReveal:
                AnswerView(viewModel: viewModel)
            }
        }
        .animation(.easeInOut, value: viewModel.gameState)
    }
}

#Preview {
    ContentView()
}
