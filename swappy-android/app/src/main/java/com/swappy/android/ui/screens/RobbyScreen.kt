package com.swappy.android.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.MicOff
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import com.swappy.android.R
import com.swappy.android.data.User

@Composable
fun RobbyScreen(
    users: List<User>,
    me: User,
    onMuteMic: () -> Unit,
    onUnmuteMic: () -> Unit,
    onStartGame: () -> Unit,
    onBack: () -> Unit
) {
    val isMicMuted = remember { mutableStateOf(false) }
    val allUsersReady = users.isNotEmpty() && users.all { it.isReady }
    val canStartGame = users.size >= 3 && allUsersReady

    Box(modifier = Modifier.fillMaxSize()) {
        Image(
            painter = painterResource(R.drawable.background),
            contentDescription = null,
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 24.dp)
                .padding(top = 12.dp, bottom = 8.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .align(Alignment.Start)
                    .clickable { onBack() },
                contentAlignment = Alignment.Center
            ) {
                Image(
                    painter = painterResource(R.drawable.swappy_arrow),
                    contentDescription = null,
                    modifier = Modifier.size(28.dp)
                )
            }

            Text(
                text = stringResource(R.string.waiting_room_name),
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold,
                color = colorResource(R.color.white)
            )
            Text(
                text = stringResource(R.string.waiting_room_subtitle),
                fontSize = 20.sp,
                color = colorResource(R.color.white_70)
            )

            Spacer(modifier = Modifier.height(60.dp))

            LazyColumn(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                items(users) { user ->
                    val isReady = user.isReady
                    val statusRes = if (isReady) R.drawable.waiting_status_ready else R.drawable.waiting_status_wait
                    val statusText = if (isReady) {
                        stringResource(R.string.waiting_status_ready)
                    } else {
                        stringResource(R.string.waiting_status_wait)
                    }
                    val micTint = if (user.isMuted) {
                        colorResource(R.color.white_60)
                    } else {
                        colorResource(R.color.ready_green)
                    }
                    WaitingMemberRow(
                        name = if (user.id == me.id) {
                            "${user.name}（あなた）"
                        } else {
                            user.name
                        },
                        statusText = statusText,
                        statusDotRes = statusRes,
                        micTint = micTint,
                        isMuted = user.isMuted
                    )
                }
            }

            Row(horizontalArrangement = Arrangement.Center, modifier = Modifier.fillMaxWidth()) {
                WaitingControlIcon(resId = R.drawable.ic_waiting_camera_on)
                Spacer(modifier = Modifier.width(2.dp))
                WaitingControlIcon(
                    resId = if (isMicMuted.value) {
                        R.drawable.ic_waiting_mic_off
                    } else {
                        R.drawable.ic_waiting_mic_on
                    },
                    onClick = {
                        if (isMicMuted.value) {
                            onUnmuteMic()
                        } else {
                            onMuteMic()
                        }
                        isMicMuted.value = !isMicMuted.value
                    }
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            JoinWaitingButton(
                enabled = canStartGame,
                onClick = onStartGame
            )
        }
    }
}

@Composable
private fun WaitingMemberRow(
    name: String,
    statusText: String,
    statusDotRes: Int,
    micTint: Color,
    isMuted: Boolean
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(74.dp)
    ) {
        XmlDrawableImage(
            resId = R.drawable.waiting_member_bg,
            contentScale = ContentScale.FillBounds,
            modifier = Modifier.fillMaxSize()
        )
        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier.size(54.dp),
                contentAlignment = Alignment.Center
            ) {
                XmlDrawableImage(
                    resId = R.drawable.waiting_avatar_bg,
                    contentScale = ContentScale.FillBounds,
                    modifier = Modifier.fillMaxSize()
                )
                Image(
                    painter = painterResource(R.drawable.swappy_member_icon),
                    contentDescription = null,
                    modifier = Modifier.size(22.dp),
                    colorFilter = ColorFilter.tint(colorResource(R.color.white_70))
                )
            }

            Spacer(modifier = Modifier.width(14.dp))

            Text(
                text = name,
                fontSize = 15.sp,
                fontWeight = FontWeight.Bold,
                color = colorResource(R.color.white),
                modifier = Modifier.weight(1f)
            )

            Row(verticalAlignment = Alignment.CenterVertically) {
                XmlDrawableImage(
                    resId = statusDotRes,
                    contentScale = ContentScale.FillBounds,
                    modifier = Modifier.size(8.dp)
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = statusText,
                    fontSize = 13.sp,
                    color = colorResource(R.color.white_80)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Icon(
                    imageVector = if (isMuted) Icons.Default.MicOff else Icons.Default.Mic,
                    contentDescription = null,
                    tint = micTint,
                    modifier = Modifier.size(28.dp)
                )
            }
        }
    }
}

@Composable
private fun WaitingControlIcon(resId: Int, onClick: (() -> Unit)? = null) {
    Box(
        modifier = Modifier
            .size(120.dp)
            .then(if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier)
    ) {
        XmlDrawableImage(
            resId = resId,
            contentScale = ContentScale.Fit,
            modifier = Modifier.fillMaxSize()
        )
    }
}

@Composable
private fun JoinWaitingButton(enabled: Boolean, onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(80.dp)
    ) {
        XmlDrawableImage(
            resId = R.drawable.waiting_join_glow_solid,
            contentScale = ContentScale.FillBounds,
            modifier = Modifier.fillMaxSize()
        )
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp)
                .align(Alignment.Center)
                .background(Color.Transparent)
                .clickable(enabled = enabled, onClick = onClick)
        ) {
            XmlDrawableImage(
                resId = R.drawable.waiting_join_button_body,
                contentScale = ContentScale.FillBounds,
                modifier = Modifier.fillMaxSize()
            )
            Text(
                text = stringResource(R.string.start_join_button),
                color = colorResource(R.color.white),
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.align(Alignment.Center)
            )
        }
    }
}

@Composable
private fun XmlDrawableImage(
    resId: Int,
    contentScale: ContentScale,
    modifier: Modifier = Modifier
) {
    AndroidView(
        factory = { context ->
            android.widget.ImageView(context).apply {
                scaleType = when (contentScale) {
                    ContentScale.Crop -> android.widget.ImageView.ScaleType.CENTER_CROP
                    ContentScale.FillBounds -> android.widget.ImageView.ScaleType.FIT_XY
                    ContentScale.Inside -> android.widget.ImageView.ScaleType.CENTER_INSIDE
                    else -> android.widget.ImageView.ScaleType.FIT_CENTER
                }
                setImageResource(resId)
            }
        },
        update = { it.setImageResource(resId) },
        modifier = modifier
    )
}
