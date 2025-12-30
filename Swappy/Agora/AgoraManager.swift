//
//  AgoraManager.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import SwiftUI
import AgoraRtcKit
import Combine

// コールバック(delegate)を定義するインターフェース(protocol)
// 理由: 直接ViewModelにAgoraRtcEngineDelegateが適用できないため、Coordinatorを挟んでいる。
protocol AgoraEngineCoordinatorDelegate: AnyObject {
    func didJoined(uid: UInt)
    func didOtherJoined(uid: UInt)
    func didOtherLeave(uid: UInt)
    func didLeaveChannel()
    func didOccurError()
    func didReceiveOtherAudioFrame(_ frame: AgoraAudioFrame)
    func didReceiveMyAudioFrame(_ frame: AgoraAudioFrame)
}

// MARK: - Agora Manager
class AgoraManager: NSObject {
    var agoraKit: AgoraRtcEngineKit!
    private let tokenRepository: AgoraTokenRepositoryProtocol
    
    init(delegate: AgoraRtcEngineDelegate, audioFrameDelegate: AgoraAudioFrameDelegate, tokenRepository: AgoraTokenRepositoryProtocol = DummyToken()) {
        // Info.plistからAgoraAppIdを取得
        guard let appId = Bundle.main.object(forInfoDictionaryKey: "AgoraAppId") as? String else {
            fatalError("AgoraAppId not found in Info.plist")
        }
        
        self.tokenRepository = tokenRepository
        
        super.init()
        
        let config = AgoraRtcEngineConfig()
        config.appId = appId
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: delegate)
        
        agoraKit.enableAudio()
        agoraKit.setChannelProfile(.communication)
        
        // オーディオフレームデリゲートを設定
        agoraKit.setAudioFrameDelegate(audioFrameDelegate)
    }
    
    func joinChannel(channelName: String, uid: UInt = 0, role: String = "publisher") async throws {
        // トークンを取得
        let token = try await tokenRepository.getToken(
            channelName: channelName,
            uid: uid,
            role: role,
            tokenExpirationInSeconds: nil,
            privilegeExpirationInSeconds: nil
        )
        
        print("fetched token: \(token)")
        
        let option = AgoraRtcChannelMediaOptions()
        option.channelProfile = .communication
        option.clientRoleType = .broadcaster
        
        agoraKit.joinChannel(
            byToken: token,
            channelId: channelName,
            uid: uid,
            mediaOptions: option
        )
    }
    
    func leaveChannel() {
        agoraKit.leaveChannel(nil)
    }
    
    func onMute() {
        agoraKit.muteLocalAudioStream(true)
    }
    
    func offMute() {
        agoraKit.muteLocalAudioStream(false)
    }
    
    deinit {
        AgoraRtcEngineKit.destroy()
    }
}

class AgoraEngineCoordinator: NSObject, AgoraRtcEngineDelegate, AgoraAudioFrameDelegate {
    weak var delegate: AgoraEngineCoordinatorDelegate?
    
    // 音声設定
    private let SAMPLING_RATE = 24000 // サンプルレート (Hz)
    private let BUFFER_DURATION_MS = 50 // バッファリング時間 (ミリ秒) - リアルタイム通話用に50msに設定
    
    private var samplesPerCall: Int {
        (SAMPLING_RATE * BUFFER_DURATION_MS) / 1000
    }
    
    init(delegate: AgoraEngineCoordinatorDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    // MARK: - AgoraAudioFrameDelegate
    func onRecordAudioFrame(_ frame: AgoraAudioFrame, channelId: String) -> Bool {
        // ローカルマイクからの音声フレーム（自分の音声）
        delegate?.didReceiveMyAudioFrame(frame)
        return true
    }
    
    func onPlaybackAudioFrame(_ frame: AgoraAudioFrame, channelId: String) -> Bool {
        // リモートユーザーからの音声フレーム(再生前)（相手の音声）
        delegate?.didReceiveOtherAudioFrame(frame)
        return true
    }
    
    func getObservedAudioFramePosition() -> AgoraAudioFramePosition {
        // 自分と相手両方の音声を取得
        return [.record, .playback]
    }
    
    func getRecordAudioParams() -> AgoraAudioParams {
        let params = AgoraAudioParams()
        params.sampleRate = SAMPLING_RATE
        params.channel = 1
        params.mode = .readWrite
        params.samplesPerCall = samplesPerCall
        return params
    }
    
    func getPlaybackAudioParams() -> AgoraAudioParams {
        let params = AgoraAudioParams()
        params.sampleRate = SAMPLING_RATE
        params.channel = 1
        params.mode = .readWrite
        params.samplesPerCall = samplesPerCall
        return params
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        delegate?.didJoined(uid: uid)
        print("Successfully joined channel: \(channel) with uid: \(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        delegate?.didOtherJoined(uid: uid)
        print("User joined with uid: \(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        delegate?.didOtherLeave(uid: uid)
        print("User offline with uid: \(uid), reason: \(reason.rawValue)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        delegate?.didLeaveChannel()
        print("Left channel")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        delegate?.didOccurError()
        
        // エラーコードの詳細を表示
        let errorDescription: String
        switch errorCode.rawValue {
        case 110:
            errorDescription = "ERR_OPEN_CHANNEL_TIMEOUT (110): チャンネルへの接続がタイムアウトしました。ネットワーク接続を確認してください。"
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
        
        print("❌ Agora Error occurred: \(errorCode.rawValue) - \(errorDescription)")
    }
}
