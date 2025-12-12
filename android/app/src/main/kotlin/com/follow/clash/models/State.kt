package com.surfboard.app.models


data class AppState(
    val crashlytics: Boolean = true,
    val currentProfileName: String = "Surfboard",
    val stopText: String = "Stop",
    val onlyStatisticsProxy: Boolean = false,
)
