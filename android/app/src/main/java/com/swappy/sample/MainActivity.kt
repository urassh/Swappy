package com.swappy.sample

import android.os.Bundle
import android.graphics.RenderEffect
import android.graphics.Shader
import android.os.Build
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
        }

        binding.startJoinContainer.setOnClickListener {
            // TODO: join flow
        }
    }
}
