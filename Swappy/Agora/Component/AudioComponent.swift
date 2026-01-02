//
//  AudioComponent.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import AgoraRtcKit

// MARK: - Audio Configuration

/// 音声設定
struct AudioConfig {
    let sampleRate: Int
    let channels: Int
    let bufferDurationMs: Int
    
    var samplesPerCall: Int {
        (sampleRate * bufferDurationMs) / 1000
    }
    
    static let `default` = AudioConfig(
        sampleRate: 24000,
        channels: 1,
        bufferDurationMs: 50
    )
}

// MARK: - Audio Coordinator

/// 音声フレームのCoordinator
private class AudioCoordinator: NSObject, AgoraAudioFrameDelegate {
    weak var delegate: AudioEventDelegate?
    private let config: AudioConfig
    
    init(delegate: AudioEventDelegate?, config: AudioConfig) {
        self.delegate = delegate
        self.config = config
        super.init()
    }
    
    // MARK: - AgoraAudioFrameDelegate
    
    func onRecordAudioFrame(_ frame: AgoraAudioFrame, channelId: String) -> Bool {
        delegate?.didReceiveLocalAudioFrame(frame)
        return true
    }
    
    func onPlaybackAudioFrame(_ frame: AgoraAudioFrame, channelId: String) -> Bool {
        delegate?.didReceiveRemoteAudioFrame(frame)
        return true
    }
    
    func getObservedAudioFramePosition() -> AgoraAudioFramePosition {
        return [.record, .playback]
    }
    
    func getRecordAudioParams() -> AgoraAudioParams {
        let params = AgoraAudioParams()
        params.sampleRate = config.sampleRate
        params.channel = config.channels
        params.mode = .readWrite
        params.samplesPerCall = config.samplesPerCall
        return params
    }
    
    func getPlaybackAudioParams() -> AgoraAudioParams {
        let params = AgoraAudioParams()
        params.sampleRate = config.sampleRate
        params.channel = config.channels
        params.mode = .readWrite
        params.samplesPerCall = config.samplesPerCall
        return params
    }
}

// MARK: - Audio Component

/// 音声管理Component
class AudioComponent: AgoraComponent {
    let engineKit: AgoraRtcEngineKit
    let config: AudioConfig
    weak var delegate: AudioEventDelegate?
    
    private var coordinator: AudioCoordinator?
    
    init(engineKit: AgoraRtcEngineKit, config: AudioConfig, delegate: AudioEventDelegate?) {
        self.engineKit = engineKit
        self.config = config
        self.delegate = delegate
    }
    
    func setup() {
        engineKit.enableAudio()
        
        coordinator = AudioCoordinator(delegate: delegate, config: config)
        engineKit.setAudioFrameDelegate(coordinator)
    }
    
    func teardown() {
        engineKit.setAudioFrameDelegate(nil)
        coordinator = nil
    }
    
    func mute() {
        engineKit.muteLocalAudioStream(true)
    }
    
    func unmute() {
        engineKit.muteLocalAudioStream(false)
    }
}
