//
//  AgoraComponents.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import AgoraRtcKit

// MARK: - Component Protocol

/// 各Componentの共通インターフェース
protocol AgoraComponent {
    var engineKit: AgoraRtcEngineKit { get }
    func setup()
    func teardown()
}
