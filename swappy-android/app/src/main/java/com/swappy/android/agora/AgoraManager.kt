package com.swappy.android.agora

import android.content.Context
import android.util.Log
import android.view.SurfaceView
import java.io.File
import io.agora.rtc2.ChannelMediaOptions
import io.agora.rtc2.Constants
import io.agora.rtc2.IRtcEngineEventHandler
import io.agora.rtc2.RtcEngine
import io.agora.rtc2.RtcEngineConfig
import io.agora.rtc2.video.VideoCanvas
import io.agora.rtc2.video.VideoEncoderConfiguration

class AgoraManagerBuilder(
    private val context: Context,
    private val appId: String,
    private val tokenRepository: AgoraTokenRepository
) {
    private var audioConfig: AudioConfig? = null
    private var channelDelegate: ChannelEventDelegate? = null
    private var enableVideo: Boolean = false

    fun withAudio(config: AudioConfig = AudioConfig.default): AgoraManagerBuilder {
        this.audioConfig = config
        return this
    }

    fun withVideo(): AgoraManagerBuilder {
        enableVideo = true
        return this
    }

    fun withChannelDelegate(delegate: ChannelEventDelegate?): AgoraManagerBuilder {
        channelDelegate = delegate
        return this
    }

    fun build(): AgoraManager? {
        val masterCoordinator = MasterCoordinator(channelDelegate)
        try {
            System.loadLibrary("agora-rtc-sdk")
        } catch (e: UnsatisfiedLinkError) {
            Log.e("Agora", "Failed to load native lib agora-rtc-sdk", e)
            return null
        }
        val logConfig = RtcEngineConfig.LogConfig().apply {
            filePath = File(context.filesDir, "agora.log").absolutePath
            level = Constants.LOG_LEVEL_INFO
        }
        val config = RtcEngineConfig().apply {
            mContext = context
            mAppId = appId
            mEventHandler = masterCoordinator
            mLogConfig = logConfig
        }
        var engine = try {
            RtcEngine.create(config)
        } catch (e: Exception) {
            Log.e("Agora", "RtcEngine.create(config) failed", e)
            null
        }
        if (engine == null) {
            engine = try {
                RtcEngine.create(context, appId, masterCoordinator)
            } catch (e: Exception) {
                Log.e("Agora", "RtcEngine.create(context, appId, handler) failed", e)
                null
            }
        }
        if (engine == null) {
            Log.e("Agora", "RtcEngine.create returned null appId=$appId log=${logConfig.filePath}")
            return null
        }

        val channelComponent = ChannelComponent(engine, tokenRepository)
        val audioComponent = audioConfig?.let { AudioComponent(engine, it) }
        val videoComponent = if (enableVideo) VideoComponent(engine) else null

        channelComponent.setup()
        audioComponent?.setup()
        videoComponent?.setup()

        return AgoraManager(
            engine = engine,
            masterCoordinator = masterCoordinator,
            channelComponent = channelComponent,
            audioComponent = audioComponent,
            videoComponent = videoComponent
        )
    }
}

class MasterCoordinator(private val channelDelegate: ChannelEventDelegate?) : IRtcEngineEventHandler() {
    private val tag = "Agora"

    override fun onJoinChannelSuccess(channel: String?, uid: Int, elapsed: Int) {
        Log.d(tag, "onJoinChannelSuccess channel=$channel uid=$uid elapsed=$elapsed")
        channelDelegate?.didJoinChannel(uid)
    }

    override fun onUserJoined(uid: Int, elapsed: Int) {
        Log.d(tag, "onUserJoined uid=$uid elapsed=$elapsed")
        channelDelegate?.didUserJoin(uid)
    }

    override fun onUserOffline(uid: Int, reason: Int) {
        Log.d(tag, "onUserOffline uid=$uid reason=$reason")
        channelDelegate?.didUserLeave(uid)
    }

    override fun onLeaveChannel(stats: IRtcEngineEventHandler.RtcStats?) {
        Log.d(tag, "onLeaveChannel")
        channelDelegate?.didLeaveChannel()
    }

    override fun onError(err: Int) {
        Log.e(tag, "onError err=$err")
        channelDelegate?.didOccurError(err)
    }
}

class AgoraManager(
    private val engine: RtcEngine,
    private val masterCoordinator: MasterCoordinator,
    private val channelComponent: ChannelComponent,
    private val audioComponent: AudioComponent?,
    private val videoComponent: VideoComponent?
) {
    val audio: AudioComponent? = audioComponent
    val video: VideoComponent? = videoComponent

    suspend fun joinChannel(name: String, uid: Int = 0, role: String = "publisher") {
        channelComponent.joinChannel(name, uid, role)
    }

    fun leaveChannel() {
        channelComponent.leaveChannel()
    }

    fun destroy() {
        audioComponent?.teardown()
        videoComponent?.teardown()
        channelComponent.teardown()
        RtcEngine.destroy()
    }
}

class ChannelComponent(
    private val engine: RtcEngine,
    private val tokenRepository: AgoraTokenRepository
) {
    private val tag = "Agora"

    fun setup() {
        engine.setChannelProfile(Constants.CHANNEL_PROFILE_COMMUNICATION)
    }

    fun teardown() {
        // no-op
    }

    suspend fun joinChannel(channelName: String, uid: Int = 0, role: String = "publisher") {
        val token = tokenRepository.getToken(channelName, uid, role).orEmpty()
        val options = ChannelMediaOptions().apply {
            channelProfile = Constants.CHANNEL_PROFILE_COMMUNICATION
            clientRoleType = Constants.CLIENT_ROLE_BROADCASTER
            publishMicrophoneTrack = true
        }
        val result = engine.joinChannel(token, channelName, uid, options)
        Log.d(tag, "joinChannel result=$result channel=$channelName uid=$uid")
    }

    fun leaveChannel() {
        engine.leaveChannel()
    }
}

data class AudioConfig(
    val sampleRate: Int,
    val channels: Int,
    val bufferDurationMs: Int
) {
    val samplesPerCall: Int
        get() = (sampleRate * bufferDurationMs) / 1000

    companion object {
        val default = AudioConfig(sampleRate = 24000, channels = 1, bufferDurationMs = 50)
    }
}

interface AudioEventDelegate

class AudioComponent(
    private val engine: RtcEngine,
    private val config: AudioConfig
) {
    fun setup() {
        engine.enableAudio()
    }

    fun teardown() {
        // no-op
    }

    fun mute() {
        engine.muteLocalAudioStream(true)
    }

    fun unmute() {
        engine.muteLocalAudioStream(false)
    }
}

class VideoComponent(private val engine: RtcEngine) {
    fun setup() {
        engine.enableVideo()
        engine.setVideoEncoderConfiguration(
            VideoEncoderConfiguration(
                VideoEncoderConfiguration.VideoDimensions(640, 480),
                VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_15,
                VideoEncoderConfiguration.STANDARD_BITRATE,
                VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_ADAPTIVE
            )
        )
    }

    fun teardown() {
        engine.disableVideo()
    }

    fun enableCamera() {
        engine.enableLocalVideo(true)
    }

    fun disableCamera() {
        engine.enableLocalVideo(false)
    }

    fun localVideoView(context: Context): android.view.SurfaceView {
        val view = SurfaceView(context)
        engine.setupLocalVideo(VideoCanvas(view, VideoCanvas.RENDER_MODE_HIDDEN, 0))
        return view
    }

    fun remoteVideoView(context: Context, uid: Int): android.view.SurfaceView {
        val view = SurfaceView(context)
        engine.setupRemoteVideo(VideoCanvas(view, VideoCanvas.RENDER_MODE_HIDDEN, uid))
        return view
    }
}
