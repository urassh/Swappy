//
//  KeywordInputViewModel.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import Foundation

/// キーワード入力画面のViewModel
@Observable
class KeywordInputViewModel {
    var keyword: String = ""
    var userName: String = ""
    
    private let onEnterRoom: (String, String) -> Void
    
    init(onEnterRoom: @escaping (String, String) -> Void) {
        self.onEnterRoom = onEnterRoom
    }
    
    var canEnterRoom: Bool {
        !keyword.isEmpty && !userName.isEmpty
    }
    
    func enterRoom() {
        guard canEnterRoom else { return }
        onEnterRoom(keyword, userName)
    }
}
