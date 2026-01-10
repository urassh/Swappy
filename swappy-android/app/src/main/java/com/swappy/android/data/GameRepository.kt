package com.swappy.android.data

interface GameRepository {
    fun setEventHandlers(
        onUsersChanged: (List<User>) -> Unit,
        onUserLeft: (User) -> Unit,
        onGameStarted: () -> Unit,
        onRolesAssigned: (List<User>) -> Unit,
        onAnswerSubmitted: (PlayerAnswer) -> Unit,
        onError: (String) -> Unit
    )

    fun joinRoom(keyword: String, me: User)
    fun leaveRoom(me: User)
    fun completeCallReady(me: User)
    fun startGame()
    fun toggleMute(me: User, isMuted: Boolean)
    fun submitAnswer(me: User, selectedUser: User)
    fun resetGame()
}
