package com.swappy.sample

import android.os.Bundle
import android.graphics.RenderEffect
import android.graphics.Shader
import android.os.Build
import android.view.View
import androidx.appcompat.app.AppCompatActivity
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

        binding.startJoinContainer.setOnClickListener {
            binding.startContent.visibility = View.GONE
            binding.waitingContent.visibility = View.VISIBLE
        }

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
    }
}
