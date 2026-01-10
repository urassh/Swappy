package com.swappy.android.ui

import android.Manifest
import android.content.pm.PackageManager
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext
import androidx.core.content.ContextCompat
import com.swappy.android.GameCoordinator
import com.swappy.android.data.MockGameRepository
import com.swappy.android.data.ScreenState
import com.swappy.android.ui.screens.AnswerInputScreen
import com.swappy.android.ui.screens.AnswerRevealScreen
import com.swappy.android.ui.screens.AnswerWaitingScreen
import com.swappy.android.ui.screens.KeywordInputScreen
import com.swappy.android.ui.screens.RobbyScreen
import com.swappy.android.ui.screens.RoleRevealScreen
import com.swappy.android.ui.screens.RoleWaitingScreen
import com.swappy.android.ui.screens.VideoCallScreen

@Composable
fun SwappyApp() {
    val context = LocalContext.current.applicationContext
    val coordinator = remember { GameCoordinator(context, MockGameRepository()) }
    val screen by coordinator.currentScreen.collectAsState()
    val users by coordinator.users.collectAsState()
    val answers by coordinator.allAnswers.collectAsState()

    EnsurePermissions()

    when (screen) {
        ScreenState.KeywordInput -> {
            KeywordInputScreen(
                onEnterRoom = { keyword, userName ->
                    coordinator.joinRoom(keyword, userName)
                }
            )
        }

        ScreenState.Robby -> {
            val me = coordinator.me
            if (me != null) {
                RobbyScreen(
                    users = users,
                    me = me,
                    onMuteMic = { coordinator.toggleMute(true) },
                    onUnmuteMic = { coordinator.toggleMute(false) },
                    onStartGame = { coordinator.startGame() },
                    onBack = {
                        coordinator.leaveRoom()
                        coordinator.navigate(ScreenState.KeywordInput)
                    }
                )
            }
        }

        ScreenState.RoleWaiting -> {
            RoleWaitingScreen()
        }

        ScreenState.RoleReveal -> {
            RoleRevealScreen(
                myRole = coordinator.me?.role,
                onStartVideoCall = { coordinator.startVideoCall() }
            )
        }

        ScreenState.VideoCall -> {
            VideoCallScreen(
                users = users,
                coordinator = coordinator,
                onTimeUp = { coordinator.startAnswerInput() },
                onBack = {
                    coordinator.leaveRoom()
                    coordinator.navigate(ScreenState.KeywordInput)
                }
            )
        }

        ScreenState.AnswerInput -> {
            val me = coordinator.me
            if (me != null) {
                AnswerInputScreen(
                    users = users,
                    me = me,
                    onSubmit = { selected ->
                        coordinator.submitAnswer(selected)
                    }
                )
            }
        }

        ScreenState.AnswerWaiting -> {
            AnswerWaitingScreen(
                allAnswers = answers,
                users = users
            )
        }

        ScreenState.AnswerReveal -> {
            val me = coordinator.me
            val wolfUser = coordinator.wolfUser
            if (me != null && wolfUser != null) {
                AnswerRevealScreen(
                    users = users,
                    allAnswers = answers,
                    wolfUser = wolfUser,
                    me = me,
                    onRestart = { coordinator.resetGame() }
                )
            }
        }
    }
}

@Composable
private fun EnsurePermissions() {
    val context = LocalContext.current
    val launcher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { }

    val permissions = arrayOf(
        Manifest.permission.RECORD_AUDIO
    )

    val allGranted = permissions.all { permission ->
        ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED
    }

    LaunchedEffect(allGranted) {
        if (!allGranted) {
            launcher.launch(permissions)
        }
    }
}
