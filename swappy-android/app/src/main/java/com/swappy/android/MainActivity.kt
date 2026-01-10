package com.swappy.android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import com.swappy.android.ui.SwappyApp
import com.swappy.android.ui.theme.SwappyTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            SwappyTheme {
                SwappyApp()
            }
        }
    }
}
