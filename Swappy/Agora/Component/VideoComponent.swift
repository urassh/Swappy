//
//  VideoComponent.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import AgoraRtcKit

// MARK: - Video Component

/// ビデオ管理Component（将来の拡張用）
class VideoComponent: AgoraComponent {
    let engineKit: AgoraRtcEngineKit
    weak var delegate: VideoEventDelegate?
    
    init(engineKit: AgoraRtcEngineKit, delegate: VideoEventDelegate?) {
        self.engineKit = engineKit
        self.delegate = delegate
    }
    
    func setup() {
        engineKit.enableVideo()
        // 将来的にビデオ設定を追加
    }
    
    func teardown() {
        engineKit.disableVideo()
    }
    
    func enableCamera() {
        engineKit.enableLocalVideo(true)
    }
    
    func disableCamera() {
        engineKit.enableLocalVideo(false)
    }
}
