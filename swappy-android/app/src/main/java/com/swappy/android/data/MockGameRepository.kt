package com.swappy.android.data

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.random.Random

class MockGameRepository : GameRepository {
    private var onUsersChanged: ((List<User>) -> Unit)? = null
    private var onUserLeft: ((User) -> Unit)? = null
    private var onGameStarted: (() -> Unit)? = null
    private var onRolesAssigned: ((List<User>) -> Unit)? = null
    private var onAnswerSubmitted: ((PlayerAnswer) -> Unit)? = null
    private var onError: ((String) -> Unit)? = null

    private var currentKeyword: String = ""
    private var joinJob: Job? = null
    private val scope = CoroutineScope(Dispatchers.Main.immediate)

    private var users: MutableList<User>
        get() = rooms[currentKeyword] ?: mutableListOf()
        set(value) {
            rooms[currentKeyword] = value
        }

    override fun setEventHandlers(
        onUsersChanged: (List<User>) -> Unit,
        onUserLeft: (User) -> Unit,
        onGameStarted: () -> Unit,
        onRolesAssigned: (List<User>) -> Unit,
        onAnswerSubmitted: (PlayerAnswer) -> Unit,
        onError: (String) -> Unit
    ) {
        this.onUsersChanged = onUsersChanged
        this.onUserLeft = onUserLeft
        this.onGameStarted = onGameStarted
        this.onRolesAssigned = onRolesAssigned
        this.onAnswerSubmitted = onAnswerSubmitted
        this.onError = onError
    }

    override fun joinRoom(keyword: String, me: User) {
        currentKeyword = keyword
        if (!rooms.containsKey(keyword)) {
            rooms[keyword] = mutableListOf()
        }
        simulateJoinRoom(me)
    }

    override fun leaveRoom(me: User) {
        simulateLeaveRoom(me)
    }

    override fun completeCallReady(me: User) {
        simulateCompleteCallReady(me)
    }

    override fun startGame() {
        simulateStartGame()
    }

    override fun toggleMute(me: User, isMuted: Boolean) {
        scope.launch {
            delay(100)
            val index = users.indexOfFirst { it.id == me.id }
            if (index >= 0) {
                users[index] = users[index].copy(isMuted = isMuted)
                onUsersChanged?.invoke(users.toList())
            }
        }
    }

    override fun submitAnswer(me: User, selectedUser: User) {
        simulateSubmitAnswer(me, selectedUser)
    }

    override fun resetGame() {
        simulateResetGame()
    }

    private fun assignRoles() {
        if (users.isEmpty()) return
        val werewolfIndex = Random.nextInt(users.size)
        users = users.mapIndexed { index, user ->
            user.copy(role = if (index == werewolfIndex) Role.Werewolf else Role.Villager)
        }.toMutableList()
        onRolesAssigned?.invoke(users.toList())
    }

    private fun simulateJoinRoom(me: User) {
        joinJob?.cancel()
        joinJob = scope.launch {
            delay(500)
            users = (users + me).toMutableList()
            onUsersChanged?.invoke(users.toList())

            delay(2500)
            val mockUsers = listOf(
                User(name = "太郎", isReady = true),
                User(name = "花子", isReady = true),
                User(name = "次郎", isReady = true)
            )
            for (user in mockUsers) {
                users = (users + user).toMutableList()
                onUsersChanged?.invoke(users.toList())
            }
        }
    }

    private fun simulateLeaveRoom(me: User) {
        scope.launch {
            delay(300)
            val keyword = currentKeyword
            currentKeyword = ""
            joinJob?.cancel()
            joinJob = null
            if (keyword.isNotEmpty()) {
                rooms.remove(keyword)
            }
            onUserLeft?.invoke(me)
        }
    }

    private fun simulateCompleteCallReady(me: User) {
        scope.launch {
            delay(200)
            val index = users.indexOfFirst { it.id == me.id }
            if (index >= 0) {
                users[index] = users[index].copy(isReady = true)
                onUsersChanged?.invoke(users.toList())
            }
        }
    }

    private fun simulateStartGame() {
        scope.launch {
            delay(300)
            onGameStarted?.invoke()
            delay(500)
            assignRoles()
        }
    }

    private fun simulateSubmitAnswer(me: User, selectedUser: User) {
        scope.launch {
            val werewolf = users.firstOrNull { it.role == Role.Werewolf } ?: return@launch
            val myAnswer = PlayerAnswer(
                answer = me,
                selectedUser = selectedUser,
                isCorrect = selectedUser.id == werewolf.id
            )
            onAnswerSubmitted?.invoke(myAnswer)

            users.filter { it.id != me.id }.forEach { otherUser ->
                delay(Random.nextLong(1_000, 3_000))
                val otherUsers = users.filter { it.id != otherUser.id }
                val randomSelected = otherUsers.random()
                val answer = PlayerAnswer(
                    answer = otherUser,
                    selectedUser = randomSelected,
                    isCorrect = randomSelected.id == werewolf.id
                )
                onAnswerSubmitted?.invoke(answer)
            }
        }
    }

    private fun simulateResetGame() {
        scope.launch {
            delay(300)
            if (currentKeyword.isNotEmpty()) {
                rooms.remove(currentKeyword)
            }
        }
    }

    companion object {
        private val rooms: MutableMap<String, MutableList<User>> = mutableMapOf()
    }
}
