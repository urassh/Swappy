package com.swappy.android.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val SwappyColorScheme = darkColorScheme()

@Composable
fun SwappyTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = SwappyColorScheme,
        content = content
    )
}
