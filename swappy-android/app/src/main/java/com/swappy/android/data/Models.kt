package com.swappy.android.data

import java.util.UUID
import kotlin.math.abs

enum class Role {
    Werewolf,
    Villager,
    Undefined
}

data class User(
    val id: UUID = UUID.randomUUID(),
    val name: String,
    var isMuted: Boolean = false,
    var isReady: Boolean = false,
    var role: Role = Role.Undefined
) {
    val talkId: Int
        get() {
            val hash = abs(id.hashCode())
            return hash % Int.MAX_VALUE
        }

    val isWolf: Boolean
        get() = role == Role.Werewolf
}

data class PlayerAnswer(
    val id: UUID = UUID.randomUUID(),
    val answer: User,
    val selectedUser: User,
    val isCorrect: Boolean
)

enum class ScreenState {
    KeywordInput,
    Robby,
    RoleWaiting,
    RoleReveal,
    VideoCall,
    AnswerInput,
    AnswerWaiting,
    AnswerReveal
}
