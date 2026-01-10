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
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import com.swappy.android.R
import com.swappy.android.data.Role

@Composable
fun RoleRevealScreen(
    myRole: Role?,
    onStartVideoCall: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
    ) {
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
            Image(
                painter = painterResource(R.drawable.swappy_arrow),
                contentDescription = null,
                modifier = Modifier
                    .size(28.dp)
                    .align(Alignment.Start)
            )

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

            Column(modifier = Modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                WaitingMemberRow(
                    name = stringResource(R.string.waiting_member_you_name),
                    statusText = stringResource(R.string.waiting_status_wait),
                    statusDotRes = R.drawable.waiting_status_wait,
                    micIconRes = R.drawable.ic_waiting_mic_off,
                    micTint = colorResource(R.color.white_60)
                )
                WaitingMemberRow(
                    name = stringResource(R.string.waiting_member_aa_name),
                    statusText = stringResource(R.string.waiting_status_ready),
                    statusDotRes = R.drawable.waiting_status_ready,
                    micIconRes = R.drawable.ic_waiting_mic,
                    micTint = colorResource(R.color.ready_green)
                )
                WaitingMemberRow(
                    name = stringResource(R.string.waiting_member_mage_name),
                    statusText = stringResource(R.string.waiting_status_ready),
                    statusDotRes = R.drawable.waiting_status_ready,
                    micIconRes = R.drawable.ic_waiting_mic,
                    micTint = colorResource(R.color.ready_green)
                )
                WaitingMemberRow(
                    name = stringResource(R.string.waiting_member_ranger_name),
                    statusText = stringResource(R.string.waiting_status_ready),
                    statusDotRes = R.drawable.waiting_status_ready,
                    micIconRes = R.drawable.ic_waiting_mic,
                    micTint = colorResource(R.color.ready_green)
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            Row(horizontalArrangement = Arrangement.Center, modifier = Modifier.fillMaxWidth()) {
                WaitingControlIcon(resId = R.drawable.ic_waiting_camera_on)
                Spacer(modifier = Modifier.width(2.dp))
                WaitingControlIcon(resId = R.drawable.ic_waiting_mic_off)
            }

            Spacer(modifier = Modifier.height(10.dp))

            JoinWaitingButton(onClick = onStartVideoCall)
        }
    }
}

@Composable
private fun WaitingMemberRow(
    name: String,
    statusText: String,
    statusDotRes: Int,
    micIconRes: Int,
    micTint: Color
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
                    colorFilter = androidx.compose.ui.graphics.ColorFilter.tint(colorResource(R.color.white_70))
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
                XmlDrawableImageTint(
                    resId = micIconRes,
                    contentScale = ContentScale.Fit,
                    tint = micTint,
                    modifier = Modifier.size(28.dp)
                )
            }
        }
    }
}

@Composable
private fun WaitingControlIcon(resId: Int) {
    Box(modifier = Modifier.size(120.dp)) {
        XmlDrawableImage(
            resId = resId,
            contentScale = ContentScale.Fit,
            modifier = Modifier.fillMaxSize()
        )
    }
}

@Composable
private fun JoinWaitingButton(onClick: () -> Unit) {
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
                .clickable(onClick = onClick)
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

@Composable
private fun XmlDrawableImageTint(
    resId: Int,
    contentScale: ContentScale,
    tint: Color,
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
                setColorFilter(tint.toArgb())
            }
        },
        update = {
            it.setImageResource(resId)
            it.setColorFilter(tint.toArgb())
        },
        modifier = modifier
    )
}
