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
    private static let keywordKey = "keywordInput.keyword"
    private static let userNameKey = "keywordInput.userName"

    var keyword: String {
        didSet {
            defaults.set(keyword, forKey: Self.keywordKey)
        }
    }
    var userName: String {
        didSet {
            defaults.set(userName, forKey: Self.userNameKey)
        }
    }
    
    private let onEnterRoom: (String, String) -> Void
    private let defaults: UserDefaults
    
    init(onEnterRoom: @escaping (String, String) -> Void, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.onEnterRoom = onEnterRoom
        self.keyword = defaults.string(forKey: Self.keywordKey) ?? ""
        self.userName = defaults.string(forKey: Self.userNameKey) ?? ""
    }
    
    var canEnterRoom: Bool {
        !keyword.isEmpty && !userName.isEmpty
    }
    
    func enterRoom() {
        guard canEnterRoom else { return }
        onEnterRoom(keyword, userName)
    }
}
