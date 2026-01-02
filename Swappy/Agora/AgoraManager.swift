//
//  AgoraManager.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//  Redesigned by 浦山秀斗 on 2026/01/02.
//

import SwiftUI
import AgoraRtcKit
import Combine

// MARK: - Agora Manager Builder

/// AgoraManagerのBuilderクラス
class AgoraManagerBuilder {
    private let appId: String
    private let tokenRepository: AgoraTokenRepositoryProtocol
    
    private var audioConfig: AudioConfig?
    private var audioDelegate: AudioEventDelegate?
    
    private var videoDelegate: VideoEventDelegate?
    private var channelDelegate: ChannelEventDelegate?
    
    init(appId: String, tokenRepository: AgoraTokenRepositoryProtocol) {
        self.appId = appId
        self.tokenRepository = tokenRepository
    }
    
    /// 音声機能を追加
    @discardableResult
    func withAudio(config: AudioConfig = .default, delegate: AudioEventDelegate?) -> Self {
        self.audioConfig = config
        self.audioDelegate = delegate
        return self
    }
    
    /// ビデオ機能を追加
    @discardableResult
    func withVideo(delegate: VideoEventDelegate?) -> Self {
        self.videoDelegate = delegate
        return self
    }
    
    /// チャンネルイベントデリゲートを設定
    @discardableResult
    func withChannelDelegate(_ delegate: ChannelEventDelegate?) -> Self {
        self.channelDelegate = delegate
        return self
    }
    
    /// AgoraManagerを生成
    func build() -> AgoraManager {
        let config = AgoraRtcEngineConfig()
        config.appId = appId
        
        let masterCoordinator = MasterCoordinator()
        let engineKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: masterCoordinator)
        
        // Componentの生成
        let channelComponent = ChannelComponent(
            engineKit: engineKit,
            tokenRepository: tokenRepository,
            delegate: channelDelegate
        )
        
        var audioComponent: AudioComponent?
        if let audioConfig = audioConfig {
            audioComponent = AudioComponent(
                engineKit: engineKit,
                config: audioConfig,
                delegate: audioDelegate
            )
        }
        
        var videoComponent: VideoComponent?
        if videoDelegate != nil {
            videoComponent = VideoComponent(
                engineKit: engineKit,
                delegate: videoDelegate
            )
        }
        
        // MasterCoordinatorにComponentを設定
        masterCoordinator.channelComponent = channelComponent
        masterCoordinator.videoComponent = videoComponent
        
        let manager = AgoraManager(
            engineKit: engineKit,
            masterCoordinator: masterCoordinator,
            channelComponent: channelComponent,
            audioComponent: audioComponent,
            videoComponent: videoComponent
        )
        
        // 各Componentのセットアップ
        channelComponent.setup()
        audioComponent?.setup()
        videoComponent?.setup()
        
        return manager
    }
}

// MARK: - Master Coordinator

/// 全てのAgoraRtcEngineDelegateイベントを受け取り、各Componentに振り分けるCoordinator
class MasterCoordinator: NSObject, AgoraRtcEngineDelegate {
    weak var channelComponent: ChannelComponent?
    weak var videoComponent: VideoComponent?
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        channelComponent?.delegate?.didJoinChannel(uid: uid)
        print("Successfully joined channel: \(channel) with uid: \(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        channelComponent?.delegate?.didUserJoin(uid: uid)
        print("User joined with uid: \(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        channelComponent?.delegate?.didUserLeave(uid: uid)
        print("User offline with uid: \(uid), reason: \(reason.rawValue)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        channelComponent?.delegate?.didLeaveChannel()
        print("Left channel")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        channelComponent?.delegate?.didOccurError(code: errorCode)
        
        let errorDescription: String
        switch errorCode.rawValue {
        case 110:
            errorDescription = "ERR_OPEN_CHANNEL_TIMEOUT (110): チャンネルへの接続がタイムアウトしました。"
        case 101:
            errorDescription = "ERR_INVALID_APP_ID (101): App IDが無効です。"
        case 109:
            errorDescription = "ERR_TOKEN_EXPIRED (109): トークンの有効期限が切れています。"
        case 2:
            errorDescription = "ERR_INVALID_ARGUMENT (2): 無効な引数が渡されました。"
        case 17:
            errorDescription = "ERR_NOT_INITIALIZED (17): SDKが初期化されていません。"
        default:
            errorDescription = "Unknown error"
        }
        
        print("❌ Agora Error: \(errorCode.rawValue) - \(errorDescription)")
    }
}

// MARK: - Agora Manager (Facade)

/// Agora機能の統一インターフェース
class AgoraManager {
    private(set) var engineKit: AgoraRtcEngineKit
    
    // IMPORTANT: AgoraRtcEngineKitはdelegateを弱参照で保持する(masterCoordinatorを強参照で保持しないとメモリから解放されてイベントが受け取れなくなる)
    private let masterCoordinator: MasterCoordinator
    
    private let channelComponent: ChannelComponent
    private let audioComponent: AudioComponent?
    private let videoComponent: VideoComponent?
    
    /// 音声Component（nilの場合は音声機能が無効）
    var audio: AudioComponent? { audioComponent }
    
    /// ビデオComponent（nilの場合はビデオ機能が無効）
    var video: VideoComponent? { videoComponent }
    
    internal init(
        engineKit: AgoraRtcEngineKit,
        masterCoordinator: MasterCoordinator,
        channelComponent: ChannelComponent,
        audioComponent: AudioComponent?,
        videoComponent: VideoComponent?
    ) {
        self.engineKit = engineKit
        self.masterCoordinator = masterCoordinator
        self.channelComponent = channelComponent
        self.audioComponent = audioComponent
        self.videoComponent = videoComponent
    }
    
    /// チャンネルに参加
    func joinChannel(_ name: String, uid: UInt = 0, role: String = "publisher") async throws {
        try await channelComponent.joinChannel(channelName: name, uid: uid, role: role)
    }
    
    /// チャンネルから退出
    func leaveChannel() {
        channelComponent.leaveChannel()
    }
    
    deinit {
        audioComponent?.teardown()
        videoComponent?.teardown()
        channelComponent.teardown()
        AgoraRtcEngineKit.destroy()
    }
}
