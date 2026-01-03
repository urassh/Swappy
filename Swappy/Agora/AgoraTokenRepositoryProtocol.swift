//
//  AgoraTokenRepositoryProtocol.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2025/12/30.
//

import Foundation

protocol AgoraTokenRepositoryProtocol {
    func getToken(
        channelName: String,
        uid: UInt,
        role: String,
        tokenExpirationInSeconds: Int?,
        privilegeExpirationInSeconds: Int?
    ) async throws -> String?
}

class AgoraTestTokenRepository : AgoraTokenRepositoryProtocol {
    func getToken(
        channelName: String,
        uid: UInt,
        role: String,
        tokenExpirationInSeconds: Int? = nil,
        privilegeExpirationInSeconds: Int? = nil
    ) async throws -> String? {
        nil
    }
}
