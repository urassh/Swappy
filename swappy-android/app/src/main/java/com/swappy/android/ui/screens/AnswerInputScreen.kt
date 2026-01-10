package com.swappy.android.ui.screens

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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.automirrored.filled.Help
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.swappy.android.data.User

@Composable
fun AnswerInputScreen(
    users: List<User>,
    me: User,
    onSubmit: (User) -> Unit
) {
    val selectedUser = remember { mutableStateOf<User?>(null) }
    val selectableUsers = users.filter { it.id != me.id }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.linearGradient(
                    colors = listOf(Color(0xFF4B37A6), Color(0xFF7B3FA4))
                )
            )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(16.dp))

            Icon(
                imageVector = Icons.AutoMirrored.Filled.Help,
                contentDescription = null,
                tint = Color.White,
                modifier = Modifier.size(60.dp)
            )
            Text(text = "人狼は誰だ？", fontSize = 28.sp, fontWeight = FontWeight.Bold, color = Color.White)
            Text(
                text = "顔が入れ替わっていた人を選んでください",
                fontSize = 16.sp,
                color = Color.White.copy(alpha = 0.8f)
            )

            Spacer(modifier = Modifier.height(24.dp))

            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.weight(1f)
            ) {
                items(selectableUsers) { user ->
                    val isSelected = selectedUser.value?.id == user.id
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(15.dp))
                            .background(
                                if (isSelected) Color.White.copy(alpha = 0.3f) else Color.White.copy(alpha = 0.15f)
                            )
                            .clickable { selectedUser.value = user }
                            .padding(14.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Avatar(name = user.name, selected = isSelected)
                        Spacer(modifier = Modifier.width(12.dp))
                        Text(text = user.name, fontSize = 20.sp, fontWeight = FontWeight.Medium, color = Color.White)
                        Spacer(modifier = Modifier.weight(1f))
                        if (isSelected) {
                            Icon(
                                imageVector = Icons.Default.CheckCircle,
                                contentDescription = null,
                                tint = Color.White
                            )
                        }
                    }
                }
            }

            Button(
                onClick = { selectedUser.value?.let(onSubmit) },
                enabled = selectedUser.value != null,
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFF2BCB80),
                    disabledContainerColor = Color.Gray
                ),
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(text = "回答する", fontSize = 18.sp, fontWeight = FontWeight.SemiBold, color = Color.White)
            }
        }
    }
}

@Composable
private fun Avatar(name: String, selected: Boolean) {
    Box(
        modifier = Modifier
            .clip(CircleShape)
            .background(if (selected) Color.White else Color.White.copy(alpha = 0.3f))
            .size(50.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(text = name.take(1), color = if (selected) Color(0xFF7B3FA4) else Color.White)
    }
}
