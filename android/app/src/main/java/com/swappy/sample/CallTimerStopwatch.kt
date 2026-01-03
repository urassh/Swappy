package com.swappy.sample

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.State
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

@Composable
fun CallTimerStopwatch(
    totalSeconds: Int = 10,
    size: Dp = 58.dp
) {
    val elapsedMs = rememberStopwatchMillis()
    val totalMs = totalSeconds * 1000L
    val progress = ((elapsedMs.value % totalMs).toFloat() / totalMs.toFloat())
    val remainingSeconds = totalSeconds - ((elapsedMs.value / 1000L) % totalSeconds).toInt()

    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier.size(size)
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val strokeWidth = 6.dp.toPx()
            val inset = strokeWidth / 2f
            val arcSize = Size(this.size.width - strokeWidth, this.size.height - strokeWidth)

            drawArc(
                color = Color(0x33FFFFFF),
                startAngle = 0f,
                sweepAngle = 360f,
                useCenter = false,
                topLeft = Offset(inset, inset),
                size = arcSize,
                style = Stroke(width = strokeWidth)
            )
            drawArc(
                color = Color(0xFFFF5A5A),
                startAngle = -90f,
                sweepAngle = -360f * progress,
                useCenter = false,
                topLeft = Offset(inset, inset),
                size = arcSize,
                style = Stroke(width = strokeWidth, cap = StrokeCap.Round)
            )
        }

        Text(
            text = "%02d".format(remainingSeconds),
            color = Color.White,
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
private fun rememberStopwatchMillis(): State<Long> {
    val elapsed = remember { mutableStateOf(0L) }
    val startTime = remember { System.currentTimeMillis() }

    LaunchedEffect(startTime) {
        while (true) {
            elapsed.value = System.currentTimeMillis() - startTime
            delay(50L)
        }
    }

    return elapsed
}
