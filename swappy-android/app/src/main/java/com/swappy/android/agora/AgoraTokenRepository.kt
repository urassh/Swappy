package com.swappy.android.agora

interface AgoraTokenRepository {
    suspend fun getToken(
        channelName: String,
        uid: Int,
        role: String,
        tokenExpirationInSeconds: Int? = null,
        privilegeExpirationInSeconds: Int? = null
    ): String?
}

class AgoraTestTokenRepository : AgoraTokenRepository {
    private val testToken = ""

    override suspend fun getToken(
        channelName: String,
        uid: Int,
        role: String,
        tokenExpirationInSeconds: Int?,
        privilegeExpirationInSeconds: Int?
    ): String? {
        return testToken
    }
}
