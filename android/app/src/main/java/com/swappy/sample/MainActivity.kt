package com.swappy.sample

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.swappy.sample.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.helloText.text = getString(R.string.hello_message)
    }
}
