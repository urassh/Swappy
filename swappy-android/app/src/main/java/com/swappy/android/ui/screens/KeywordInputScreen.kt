package com.swappy.android.ui.screens

import android.content.Context
import android.view.ViewGroup
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.ui.viewinterop.AndroidView
import com.swappy.android.R
import com.swappy.android.ui.theme.SwappyTheme
import kotlinx.coroutines.launch

private const val KeywordKey = "keywordInput.keyword"
private const val UserNameKey = "keywordInput.userName"

@Composable
fun KeywordInputScreen(onEnterRoom: (String, String) -> Unit) {
    val context = LocalContext.current
    val preferences = remember { context.getSharedPreferences("swappy_prefs", Context.MODE_PRIVATE) }
    val scope = rememberCoroutineScope()

    val savedKeyword = preferences.getString(KeywordKey, "") ?: ""
    val savedUserName = preferences.getString(UserNameKey, "") ?: ""

    val keywordState = rememberSaveable { mutableStateOf(savedKeyword) }
    val userNameState = rememberSaveable { mutableStateOf(savedUserName) }

    LaunchedEffect(keywordState.value) {
        scope.launch {
            preferences.edit().putString(KeywordKey, keywordState.value).apply()
        }
    }

    LaunchedEffect(userNameState.value) {
        scope.launch {
            preferences.edit().putString(UserNameKey, userNameState.value).apply()
        }
    }

    val canEnter = keywordState.value.isNotBlank() && userNameState.value.isNotBlank()

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
                .padding(horizontal = 32.dp)
                .padding(top = 40.dp, bottom = 32.dp),
            verticalArrangement = Arrangement.SpaceBetween,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Box(
                    modifier = Modifier.size(260.dp),
                    contentAlignment = Alignment.Center
                ) {
                    XmlDrawableImage(
                        resId = R.drawable.logo_glow,
                        contentScale = ContentScale.FillBounds,
                        modifier = Modifier.fillMaxSize()
                    )
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(12.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        XmlDrawableImage(
                            resId = R.drawable.logo_circle,
                            contentScale = ContentScale.FillBounds,
                            modifier = Modifier
                                .fillMaxSize()
                                .padding(30.dp)
                        )
                        Image(
                            painter = painterResource(R.drawable.image_2),
                            contentDescription = stringResource(R.string.start_logo_desc),
                            contentScale = ContentScale.FillBounds,
                            modifier = Modifier
                                .fillMaxSize()
                                .padding(30.dp)
                        )
                    }
                }

                StrokeTitleText(
                    text = stringResource(R.string.start_title),
                    strokeColor = colorResource(R.color.white_50),
                    fillColor = colorResource(R.color.white_40)
                )
                Text(
                    text = stringResource(R.string.start_subtitle),
                    fontSize = 12.sp,
                    color = colorResource(R.color.white_80)
                )

                Spacer(modifier = Modifier.height(40.dp))

                Text(
                    text = stringResource(R.string.start_rules_title),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = colorResource(R.color.white)
                )
                Text(
                    text = stringResource(R.string.start_rules_body),
                    fontSize = 13.sp,
                    color = colorResource(R.color.white_80),
                    textAlign = TextAlign.Center
                )
            }

            Column(verticalArrangement = Arrangement.spacedBy(18.dp)) {
                LabeledInput(
                    label = "",
                    content = {
                        NameInputField(
                            value = userNameState.value,
                            placeholder = stringResource(R.string.start_name_label),
                            onValueChange = { userNameState.value = it }
                        )
                    }
                )

                LabeledInput(
                    label = "",
                    content = {
                        RoundedInputField(
                            value = keywordState.value,
                            placeholder = stringResource(R.string.start_room_code_hint),
                            onValueChange = { keywordState.value = it }
                        )
                    }
                )

                JoinRoomButton(
                    enabled = canEnter,
                    onClick = { onEnterRoom(keywordState.value, userNameState.value) }
                )

                Spacer(modifier = Modifier.height(12.dp))
            }
        }
    }
}

@Composable
private fun LabeledInput(label: String, content: @Composable () -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
        if (label.isNotBlank()) {
            Text(
                text = label,
                fontSize = 12.sp,
                color = colorResource(R.color.white_80)
            )
        }
        content()
    }
}

@Composable
private fun StrokeTitleText(text: String, strokeColor: Color, fillColor: Color) {
    Box(contentAlignment = Alignment.Center) {
        Text(
            text = text,
            fontSize = 32.sp,
            fontWeight = FontWeight.SemiBold,
            fontFamily = FontFamily.Monospace,
            style = TextStyle(drawStyle = Stroke(width = 1.5f)),
            color = strokeColor
        )
        Text(
            text = text,
            fontSize = 32.sp,
            fontWeight = FontWeight.SemiBold,
            fontFamily = FontFamily.Monospace,
            color = fillColor
        )
    }
}

@Composable
private fun NameInputField(
    value: String,
    placeholder: String,
    onValueChange: (String) -> Unit
) {
    Column(modifier = Modifier.fillMaxWidth()) {
        BasicTextField(
            value = value,
            onValueChange = onValueChange,
            textStyle = TextStyle(color = colorResource(R.color.white), fontSize = 15.sp),
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 4.dp),
            decorationBox = { innerTextField ->
                Box {
                    if (value.isBlank()) {
                        Text(
                            text = placeholder,
                            color = colorResource(R.color.white_80),
                            fontSize = 15.sp
                        )
                    }
                    innerTextField()
                }
            }
        )
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(2.dp)
                .background(colorResource(R.color.white_80))
        )
    }
}

@Composable
private fun RoundedInputField(
    value: String,
    placeholder: String,
    onValueChange: (String) -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
    ) {
        XmlDrawableImage(
            resId = R.drawable.input_rounded,
            contentScale = ContentScale.FillBounds,
            modifier = Modifier.fillMaxSize()
        )
        BasicTextField(
            value = value,
            onValueChange = onValueChange,
            textStyle = TextStyle(color = colorResource(R.color.white), fontSize = 15.sp),
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp, vertical = 14.dp),
            decorationBox = { innerTextField ->
                Box(contentAlignment = Alignment.CenterStart) {
                    if (value.isBlank()) {
                        Text(
                            text = placeholder,
                            color = colorResource(R.color.white_80),
                            fontSize = 15.sp
                        )
                    }
                    innerTextField()
                }
            }
        )
    }
}

@Composable
private fun JoinRoomButton(enabled: Boolean, onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(80.dp)
    ) {
        XmlDrawableImage(
            resId = R.drawable.join_glow_solid,
            contentScale = ContentScale.FillBounds,
            modifier = Modifier.fillMaxSize()
        )
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp)
                .align(Alignment.Center)
                .alpha(if (enabled) 1f else 0.5f)
                .clickable(enabled = enabled, onClick = onClick)
        ) {
            XmlDrawableImage(
                resId = R.drawable.join_button_body,
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
                layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                )
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

@Preview(showBackground = true)
@Composable
private fun KeywordInputScreenPreview() {
    SwappyTheme {
        KeywordInputScreen(onEnterRoom = { _, _ -> })
    }
}
