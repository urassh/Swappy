//
//  VideoComponent.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import AgoraRtcKit
import UIKit

// MARK: - Video Component

/// ビデオ管理Component
class VideoComponent: AgoraComponent {
    let engineKit: AgoraRtcEngineKit
    
    init(engineKit: AgoraRtcEngineKit) {
        self.engineKit = engineKit
    }
    
    func setup() {
        engineKit.enableVideo()
        engineKit.setVideoEncoderConfiguration(
            AgoraVideoEncoderConfiguration(
                size: CGSize(width: 640, height: 480),
                frameRate: .fps15,
                bitrate: AgoraVideoBitrateStandard,
                orientationMode: .adaptative,
                mirrorMode: .auto
            )
        )
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
    
    /// ローカルビデオのビューを取得
    func localVideo() -> UIView {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0 // ローカルユーザーは0
        videoCanvas.renderMode = .hidden
        let view = UIView()
        videoCanvas.view = view
        engineKit.setupLocalVideo(videoCanvas)
        return view
    }
    
    /// リモートビデオのビューを取得
    /// - Parameter talkId: リモートユーザーのUID
    /// - Returns: リモートビデオを表示するUIView
    func remoteVideo(with talkId: UInt) -> UIView {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = talkId
        videoCanvas.renderMode = .hidden
        let view = UIView()
        videoCanvas.view = view
        engineKit.setupRemoteVideo(videoCanvas)
        return view
    }
}
