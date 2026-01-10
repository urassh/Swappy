package com.swappy.android

import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import android.widget.Toast
import androidx.core.content.ContextCompat
import com.swappy.android.agora.AgoraManager
import com.swappy.android.agora.AgoraManagerBuilder
import com.swappy.android.agora.AgoraTestTokenRepository
import com.swappy.android.agora.ChannelEventDelegate
import com.swappy.android.data.GameRepository
import com.swappy.android.data.PlayerAnswer
import com.swappy.android.data.ScreenState
import com.swappy.android.data.User
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.withContext
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.UUID

class GameCoordinator(
    private val context: Context,
    private val gameRepository: GameRepository
) : ChannelEventDelegate {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    private val _currentScreen = MutableStateFlow(ScreenState.KeywordInput)
    val currentScreen: StateFlow<ScreenState> = _currentScreen.asStateFlow()

    private val _users = MutableStateFlow<List<User>>(emptyList())
    val users: StateFlow<List<User>> = _users.asStateFlow()

    private val _allAnswers = MutableStateFlow<List<PlayerAnswer>>(emptyList())
    val allAnswers: StateFlow<List<PlayerAnswer>> = _allAnswers.asStateFlow()

    private var meId: UUID? = null
    private var didSendReady = false

    private var agoraManager: AgoraManager? = null

    private val appId = "test"

    init {
        setupEventHandlers()
    }

    val me: User?
        get() = _users.value.firstOrNull { it.id == meId }

    val wolfUser: User?
        get() = _users.value.firstOrNull { it.isWolf }

    fun navigate(screen: ScreenState) {
        _currentScreen.value = screen
    }

    fun clean() {
        scope.launch {
            withContext(Dispatchers.IO) {
                cleanupAgoraManager()
            }
            _users.value = emptyList()
            _allAnswers.value = emptyList()
            meId = null
            _currentScreen.value = ScreenState.KeywordInput
            didSendReady = false
        }
    }

    private fun setupAgoraManager(): Boolean {
        val tokenRepository = AgoraTestTokenRepository()
        val builder = AgoraManagerBuilder(context, appId, tokenRepository)
        agoraManager = try {
            builder
                .withAudio()
                .withVideo()
                .withChannelDelegate(this)
                .build()
        } catch (e: Exception) {
            Log.e("Swappy", "setupAgoraManager failed", e)
            null
        }
        return agoraManager != null
    }

    private fun cleanupAgoraManager() {
        agoraManager?.leaveChannel()
        agoraManager?.destroy()
        agoraManager = null
    }

    fun joinRoom(keyword: String, userName: String) {
        Log.d("Swappy", "joinRoom keyword=$keyword userName=$userName")
        if (!hasRequiredPermissions()) {
            Log.w("Swappy", "joinRoom blocked: RECORD_AUDIO permission missing")
            showMessage("マイクの権限が必要です")
            return
        }
        val newUser = User(name = userName)
        meId = newUser.id
        _users.value = listOf(newUser)
        if (!setupAgoraManager()) {
            Log.e("Swappy", "joinRoom failed: Agora engine init failed")
            showMessage("Agoraの初期化に失敗しました")
            return
        }
        navigate(ScreenState.Robby)

        scope.launch {
            try {
                agoraManager?.joinChannel(keyword, uid = 0, role = "publisher")
            } catch (_: Exception) {
            }
        }

        gameRepository.joinRoom(keyword, newUser)
    }

    private fun hasRequiredPermissions(): Boolean {
        val permissions = arrayOf(
            android.Manifest.permission.RECORD_AUDIO
        )
        return permissions.all { permission ->
            ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun showMessage(message: String) {
        Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
    }

    fun leaveRoom() {
        val me = me ?: return
        clean()
        gameRepository.leaveRoom(me)
    }

    private fun completeCallReady() {
        val me = me ?: return
        if (didSendReady) return
        didSendReady = true
        _users.value = if (_users.value.any { it.id == me.id }) {
            _users.value.map { user ->
                if (user.id == me.id) user.copy(isReady = true) else user
            }
        } else {
            _users.value + me.copy(isReady = true)
        }
        gameRepository.completeCallReady(me)
    }

    fun toggleMute(isMuted: Boolean) {
        val me = me ?: return
        if (isMuted) {
            agoraManager?.audio?.mute()
        } else {
            agoraManager?.audio?.unmute()
        }

        _users.value = _users.value.map { user ->
            if (user.id == me.id) user.copy(isMuted = isMuted) else user
        }

        gameRepository.toggleMute(me, isMuted)
    }

    fun startGame() {
        gameRepository.startGame()
        navigate(ScreenState.RoleWaiting)
    }

    fun startVideoCall() {
        navigate(ScreenState.VideoCall)
    }

    fun startAnswerInput() {
        navigate(ScreenState.AnswerInput)
    }

    fun submitAnswer(selectedUser: User) {
        val me = me ?: return
        gameRepository.submitAnswer(me, selectedUser)
        navigate(ScreenState.AnswerWaiting)
    }

    fun resetGame() {
        gameRepository.resetGame()
        clean()
    }

    fun getOrCreateVideoView(user: User): android.view.SurfaceView? {
        val videoComponent = agoraManager?.video ?: return null
        return if (user.id == meId) {
            videoComponent.localVideoView(context)
        } else {
            videoComponent.remoteVideoView(context, user.talkId)
        }
    }

    private fun setupEventHandlers() {
        gameRepository.setEventHandlers(
            onUsersChanged = { users ->
                _users.value = users
                val me = meId?.let { id -> users.firstOrNull { it.id == id } }
                if (didSendReady && me != null && !me.isReady) {
                    _users.value = _users.value.map { user ->
                        if (user.id == me.id) user.copy(isReady = true) else user
                    }
                    gameRepository.completeCallReady(me)
                }
            },
            onUserLeft = { user ->
                _users.value = _users.value.filterNot { it.id == user.id }
            },
            onGameStarted = {
                if (_currentScreen.value != ScreenState.RoleWaiting) {
                    navigate(ScreenState.RoleWaiting)
                }
            },
            onRolesAssigned = { users ->
                _users.value = users
                navigate(ScreenState.RoleReveal)
            },
            onAnswerSubmitted = { answer ->
                val current = _allAnswers.value
                if (current.none { it.answer.id == answer.answer.id }) {
                    _allAnswers.value = current + answer
                }
                if (_allAnswers.value.size == _users.value.size && _currentScreen.value == ScreenState.AnswerWaiting) {
                    navigate(ScreenState.AnswerReveal)
                }
            },
            onError = { }
        )
    }

    override fun didJoinChannel(uid: Int) {
        completeCallReady()
    }

    override fun didUserJoin(uid: Int) {
    }

    override fun didUserLeave(uid: Int) {
    }

    override fun didLeaveChannel() {
        leaveRoom()
    }

    override fun didOccurError(code: Int) {
    }
}
