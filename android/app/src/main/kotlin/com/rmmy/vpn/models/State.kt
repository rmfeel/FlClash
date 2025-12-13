package com.rmmy.vpn.models


data class AppState(
    val crashlytics: Boolean = true,
    val currentProfileName: String = "FlClash",
    val stopText: String = "Stop",
    val onlyStatisticsProxy: Boolean = false,
)
