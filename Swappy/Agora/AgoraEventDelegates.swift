//
//  AgoraEventDelegates.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import AgoraRtcKit

// MARK: - Event Delegates

/// チャンネル関連のイベントデリゲート
protocol ChannelEventDelegate: AnyObject {
    func didJoinChannel(uid: UInt)
    func didUserJoin(uid: UInt)
    func didUserLeave(uid: UInt)
    func didLeaveChannel()
    func didOccurError(code: AgoraErrorCode)
}

/// 音声関連のイベントデリゲート
protocol AudioEventDelegate: AnyObject {
    func didReceiveLocalAudioFrame(_ frame: AgoraAudioFrame)
    func didReceiveRemoteAudioFrame(_ frame: AgoraAudioFrame)
}
