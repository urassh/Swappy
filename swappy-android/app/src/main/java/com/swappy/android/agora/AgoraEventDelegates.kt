package com.swappy.android.agora

interface ChannelEventDelegate {
    fun didJoinChannel(uid: Int)
    fun didUserJoin(uid: Int)
    fun didUserLeave(uid: Int)
    fun didLeaveChannel()
    fun didOccurError(code: Int)
}
