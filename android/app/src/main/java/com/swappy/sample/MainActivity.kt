package com.swappy.sample

import android.os.Bundle
import android.graphics.RenderEffect
import android.graphics.Shader
import android.os.Build
import android.view.View
import android.view.MotionEvent
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.compose.ui.unit.dp
import com.swappy.sample.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val blur = RenderEffect.createBlurEffect(50f, 50f, Shader.TileMode.CLAMP)
            binding.joinGlow.setRenderEffect(blur)
            binding.waitingJoinGlow.setRenderEffect(blur)
        }

        binding.callTimerCompose.setViewCompositionStrategy(
            ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed
        )
        binding.callTimerCompose.setContent {
            CallTimerStopwatch(totalSeconds = 10, size = 90.dp)
        }

        binding.startJoinContainer.setOnClickListener {
            binding.startContent.visibility = View.GONE
            binding.waitingContent.visibility = View.VISIBLE
        }

        setupPressAnimation(binding.startJoinContainer)
        setupPressAnimation(binding.waitingJoinContainer)

        var isCameraOn = true
        var isMicOn = false

        binding.waitingCameraToggle.setOnClickListener {
            isCameraOn = !isCameraOn
            val cameraIcon = if (isCameraOn) {
                R.drawable.ic_waiting_camera_on
            } else {
                R.drawable.ic_waiting_camera_off
            }
            binding.waitingCameraToggle.setImageResource(cameraIcon)
        }

        binding.waitingMicToggle.setOnClickListener {
            isMicOn = !isMicOn
            val micIcon = if (isMicOn) {
                R.drawable.ic_waiting_mic_on
            } else {
                R.drawable.ic_waiting_mic_off
            }
            binding.waitingMicToggle.setImageResource(micIcon)
        }

        binding.waitingJoinContainer.setOnClickListener {
            binding.waitingContent.visibility = View.GONE
            binding.callContent.visibility = View.VISIBLE
        }

        binding.callBack.setOnClickListener {
            binding.callContent.visibility = View.GONE
            binding.waitingContent.visibility = View.VISIBLE
        }

        binding.waitingBack.setOnClickListener {
            binding.waitingContent.visibility = View.GONE
            binding.startContent.visibility = View.VISIBLE
        }
    }

    private fun setupPressAnimation(target: View) {
        target.setOnTouchListener { view, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    view.animate()
                        .scaleX(0.96f)
                        .scaleY(0.96f)
                        .setDuration(90)
                        .start()
                }
                MotionEvent.ACTION_UP,
                MotionEvent.ACTION_CANCEL -> {
                    view.animate()
                        .scaleX(1f)
                        .scaleY(1f)
                        .setDuration(120)
                        .start()
                }
            }
            false
        }
    }
}
