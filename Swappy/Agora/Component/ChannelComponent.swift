//
//  ChannelComponent.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import AgoraRtcKit

// MARK: - Channel Component

/// チャンネル管理Component
class ChannelComponent: AgoraComponent {
    let engineKit: AgoraRtcEngineKit
    weak var delegate: ChannelEventDelegate?
    
    private let tokenRepository: AgoraTokenRepositoryProtocol
    
    init(engineKit: AgoraRtcEngineKit, tokenRepository: AgoraTokenRepositoryProtocol, delegate: ChannelEventDelegate?) {
        self.engineKit = engineKit
        self.tokenRepository = tokenRepository
        self.delegate = delegate
    }
    
    func setup() {
        engineKit.setChannelProfile(.communication)
    }
    
    func teardown() {
        // 特に処理なし
    }
    
    func joinChannel(channelName: String, uid: UInt = 0, role: String = "publisher") async throws {
        let token = try await tokenRepository.getToken(
            channelName: channelName,
            uid: uid,
            role: role,
            tokenExpirationInSeconds: nil,
            privilegeExpirationInSeconds: nil
        )
        
        print("Fetched token: \(token)")
        
        let option = AgoraRtcChannelMediaOptions()
        option.channelProfile = .communication
        option.clientRoleType = .broadcaster
        
        engineKit.joinChannel(
            byToken: token,
            channelId: channelName,
            uid: uid,
            mediaOptions: option
        )
    }
    
    func leaveChannel() {
        engineKit.leaveChannel(nil)
    }
}
