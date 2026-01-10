@file:Suppress("COMPOSE_APPLIER_CALL_MISMATCH")

package com.swappy.android.ui.screens

import android.view.SurfaceView
import android.widget.ImageView
import androidx.annotation.DrawableRes
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import com.swappy.android.GameCoordinator
import com.swappy.android.R
import com.swappy.android.data.User
import com.swappy.android.ui.theme.SwappyTheme
import kotlinx.coroutines.delay
import java.util.UUID

@Composable
fun VideoCallScreen(
    users: List<User>,
    coordinator: GameCoordinator,
    onTimeUp: () -> Unit,
    onBack: (() -> Unit)? = null
) {
    var timeRemaining by remember { mutableIntStateOf(10) }
    val videoViews = remember { mutableStateMapOf<UUID, SurfaceView>() }

    LaunchedEffect(users) {
        users.forEach { user ->
            if (!videoViews.containsKey(user.id)) {
                coordinator.getOrCreateVideoView(user)?.let { view ->
                    videoViews[user.id] = view
                }
            }
        }
    }

    LaunchedEffect(Unit) {
        while (timeRemaining > 0) {
            delay(1000)
            timeRemaining -= 1
        }
        onTimeUp()
    }

    VideoCallContent(
        users = users,
        timeRemaining = timeRemaining,
        videoViews = videoViews,
        onBack = onBack
    )
}

@Composable
private fun VideoCallContent(
    users: List<User>,
    timeRemaining: Int,
    videoViews: Map<UUID, SurfaceView?>,
    onBack: (() -> Unit)?,
    modifier: Modifier = Modifier
) {
    val fallbackNames = listOf(
        stringResource(id = R.string.waiting_member_you_name),
        stringResource(id = R.string.waiting_member_aa_name),
        stringResource(id = R.string.waiting_member_mage_name),
        stringResource(id = R.string.waiting_member_ranger_name)
    )
    val defaultStatusIcons = listOf(
        R.drawable.swappy_vector,
        R.drawable.ic_waiting_mic,
        R.drawable.ic_waiting_mic,
        R.drawable.swappy_vector
    )
    val avatarGlows = listOf(
        R.drawable.call_avatar_glow_blue,
        R.drawable.call_avatar_glow_green,
        R.drawable.call_avatar_glow_green,
        R.drawable.call_avatar_glow_blue
    )
    val avatarIcons = listOf(
        R.drawable.swappy_call_icon_1,
        R.drawable.swappy_call_icon_2,
        R.drawable.swappy_call_icon_1,
        R.drawable.swappy_call_icon_2
    )
    val memberSlots = List(4) { index ->
        val user = users.getOrNull(index)
        val name = user?.name ?: fallbackNames[index]
        val statusIconRes = user?.let {
            if (it.isMuted) R.drawable.ic_waiting_mic else R.drawable.swappy_vector
        } ?: defaultStatusIcons[index]
        MemberSlot(
            name = name,
            avatarGlowRes = avatarGlows[index],
            avatarIconRes = avatarIcons[index],
            statusIconRes = statusIconRes,
            videoView = user?.let { videoViews[it.id] }
        )
    }

    Box(
        modifier = modifier.fillMaxSize()
    ) {
        DrawableImage(
            resId = R.drawable.background,
            scaleType = ImageView.ScaleType.CENTER_CROP,
            modifier = Modifier.matchParentSize()
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 24.dp, vertical = 20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(modifier = Modifier.fillMaxWidth()) {
                if (onBack != null) {
                    DrawableImage(
                        resId = R.drawable.swappy_arrow,
                        modifier = Modifier
                            .size(24.dp)
                            .align(Alignment.CenterStart)
                            .clickable { onBack() }
                    )
                }
                Box(modifier = Modifier.align(Alignment.Center)) {
                    CallTimerStopwatch(
                        timeRemaining = timeRemaining,
                        size = 90.dp
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            Column(modifier = Modifier.fillMaxWidth()) {
                Row(modifier = Modifier.fillMaxWidth()) {
                    CallMemberCard(
                        avatarGlowRes = memberSlots[0].avatarGlowRes,
                        avatarIconRes = memberSlots[0].avatarIconRes,
                        statusIconRes = memberSlots[0].statusIconRes,
                        name = memberSlots[0].name,
                        videoView = memberSlots[0].videoView,
                        modifier = Modifier.weight(1f)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    CallMemberCard(
                        avatarGlowRes = memberSlots[1].avatarGlowRes,
                        avatarIconRes = memberSlots[1].avatarIconRes,
                        statusIconRes = memberSlots[1].statusIconRes,
                        name = memberSlots[1].name,
                        videoView = memberSlots[1].videoView,
                        modifier = Modifier.weight(1f)
                    )
                }

                Spacer(modifier = Modifier.height(6.dp))

                Row(modifier = Modifier.fillMaxWidth()) {
                    CallMemberCard(
                        avatarGlowRes = memberSlots[2].avatarGlowRes,
                        avatarIconRes = memberSlots[2].avatarIconRes,
                        statusIconRes = memberSlots[2].statusIconRes,
                        name = memberSlots[2].name,
                        videoView = memberSlots[2].videoView,
                        modifier = Modifier.weight(1f)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    CallMemberCard(
                        avatarGlowRes = memberSlots[3].avatarGlowRes,
                        avatarIconRes = memberSlots[3].avatarIconRes,
                        statusIconRes = memberSlots[3].statusIconRes,
                        name = memberSlots[3].name,
                        videoView = memberSlots[3].videoView,
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            ReactionBar()

            Spacer(modifier = Modifier.height(20.dp))

            CallTip()

            Spacer(modifier = Modifier.height(10.dp))

            CallControls()
        }
    }
}

@Composable
private fun CallTimerStopwatch(
    timeRemaining: Int,
    size: Dp
) {
    val ringRes = if (timeRemaining <= 3) {
        R.drawable.call_timer_ring_red
    } else {
        R.drawable.call_timer_ring
    }
    DrawableBox(
        backgroundRes = ringRes,
        modifier = Modifier.size(size)
    ) {
        Text(
            text = timeRemaining.toString(),
            color = Color.White,
            fontSize = 28.sp,
            fontWeight = FontWeight.SemiBold,
            modifier = Modifier.align(Alignment.Center)
        )
    }
}

@Composable
private fun CallMemberCard(
    @DrawableRes avatarGlowRes: Int,
    @DrawableRes avatarIconRes: Int,
    @DrawableRes statusIconRes: Int,
    name: String,
    videoView: SurfaceView?,
    modifier: Modifier = Modifier
) {
    DrawableBox(
        backgroundRes = R.drawable.call_card_bg,
        modifier = modifier.height(220.dp)
    ) {
        Box(modifier = Modifier.fillMaxSize().padding(12.dp)) {
            DrawableBox(
                backgroundRes = avatarGlowRes,
                modifier = Modifier
                    .size(117.dp)
                    .align(Alignment.Center)
            ) {
                DrawableBox(
                    backgroundRes = R.drawable.call_avatar_inner,
                    modifier = Modifier
                        .size(78.dp)
                        .align(Alignment.Center)
                ) {
                    if (videoView != null) {
                        AndroidView(
                            factory = { videoView },
                            modifier = Modifier
                                .fillMaxSize()
                                .clip(androidx.compose.foundation.shape.CircleShape)
                        )
                    } else {
                        DrawableImage(
                            resId = avatarIconRes,
                            modifier = Modifier
                                .fillMaxSize()
                                .padding(15.dp)
                        )
                    }
                }
            }

            Row(
                modifier = Modifier
                    .align(Alignment.BottomStart),
                verticalAlignment = Alignment.CenterVertically
            ) {
                DrawableImage(
                    resId = statusIconRes,
                    modifier = Modifier.size(20.dp)
                )
                NameChip(
                    text = name,
                    modifier = Modifier.padding(start = 6.dp)
                )
            }
        }
    }
}

@Composable
private fun NameChip(
    text: String,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier.wrapContentSize()
    ) {
        DrawableImage(
            resId = R.drawable.call_name_chip,
            scaleType = ImageView.ScaleType.FIT_XY,
            modifier = Modifier.matchParentSize()
        )
        Text(
            text = text,
            color = Color.White,
            fontSize = 12.sp,
            modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
        )
    }
}

@Composable
private fun ReactionBar() {
    DrawableBox(
        backgroundRes = R.drawable.call_reaction_bar_bg,
        modifier = Modifier.wrapContentSize()
    ) {
        Row(
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            modifier = Modifier.padding(horizontal = 15.dp, vertical = 10.dp)
        ) {
            ReactionItem(text = "\uD83E\uDD29")
            ReactionItem(text = "\uD83D\uDC4B")
            ReactionItem(text = "\uD83D\uDC4D")
            ReactionItem(text = "\uD83D\uDC97")
        }
    }
}

@Composable
private fun ReactionItem(text: String) {
    DrawableBox(
        backgroundRes = R.drawable.call_reaction_item_bg,
        modifier = Modifier.size(42.dp)
    ) {
        Text(
            text = text,
            fontSize = 20.sp,
            modifier = Modifier.align(Alignment.Center)
        )
    }
}

@Composable
private fun CallTip() {
    Box(modifier = Modifier.fillMaxWidth()) {
        DrawableBox(
            backgroundRes = R.drawable.call_tip_bg,
            modifier = Modifier
                .align(Alignment.Center)
                .width(340.dp)
        ) {
            Text(
                text = stringResource(id = R.string.call_tip_text),
                color = Color.White,
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier
                    .align(Alignment.Center)
                    .padding(vertical = 14.dp)
            )
        }

        Text(
            text = "?",
            color = colorResource(id = R.color.muted_red),
            fontSize = 44.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier
                .align(Alignment.TopStart)
                .offset(x = 6.dp, y = (-56).dp)
                .rotate(-28f)
        )

        Text(
            text = "?",
            color = colorResource(id = R.color.muted_red),
            fontSize = 44.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier
                .align(Alignment.TopEnd)
                .offset(x = (-6).dp, y = 36.dp)
                .rotate(28f)
        )
    }
}

@Composable
private fun CallControls() {
    DrawableBox(
        backgroundRes = R.drawable.call_control_bar_bg,
        modifier = Modifier
            .fillMaxWidth()
            .height(68.dp)
    ) {
        Row(
            modifier = Modifier
                .align(Alignment.Center)
                .fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(-20.dp)
            ) {
                DrawableImage(
                    resId = R.drawable.swappy_tab_camera_combo,
                    modifier = Modifier.size(90.dp)
                )
                DrawableImage(
                    resId = R.drawable.swappy_tab_mic_combo,
                    modifier = Modifier.size(90.dp)
                )
                DrawableImage(
                    resId = R.drawable.swappy_tab_switch_camera_combo,
                    modifier = Modifier.size(90.dp)
                )
            }
            DrawableImage(
                resId = R.drawable.swappy_end_call_combo,
                modifier = Modifier.size(100.dp)
            )
        }
    }
}

@Composable
private fun DrawableBox(
    @DrawableRes backgroundRes: Int,
    modifier: Modifier = Modifier,
    content: @Composable BoxScope.() -> Unit
) {
    Box(modifier = modifier) {
        DrawableImage(
            resId = backgroundRes,
            scaleType = ImageView.ScaleType.FIT_XY,
            modifier = Modifier.matchParentSize()
        )
        content()
    }
}

@Composable
private fun DrawableImage(
    @DrawableRes resId: Int,
    modifier: Modifier = Modifier,
    scaleType: ImageView.ScaleType = ImageView.ScaleType.FIT_CENTER
) {
    AndroidView(
        factory = { context ->
            ImageView(context).apply {
                this.scaleType = scaleType
                setImageResource(resId)
            }
        },
        update = { it.setImageResource(resId) },
        modifier = modifier
    )
}

@Preview(showBackground = true)
@Composable
private fun VideoCallScreenPreview() {
    val users = listOf(
        User(id = UUID(0L, 1L), name = "あなた", isMuted = false),
        User(id = UUID(0L, 2L), name = "Sora", isMuted = true),
        User(id = UUID(0L, 3L), name = "Mika", isMuted = true),
        User(id = UUID(0L, 4L), name = "Ken", isMuted = false)
    )

    SwappyTheme {
        VideoCallContent(
            users = users,
            timeRemaining = 8,
            videoViews = emptyMap(),
            onBack = {}
        )
    }
}

private data class MemberSlot(
    val name: String,
    @field:DrawableRes val avatarGlowRes: Int,
    @field:DrawableRes val avatarIconRes: Int,
    @field:DrawableRes val statusIconRes: Int,
    val videoView: SurfaceView?
)
