package com.rmmy.vpn.service.models

import com.rmmy.vpn.common.GlobalState
import com.rmmy.vpn.common.formatBytes
import com.rmmy.vpn.core.Core
import com.google.gson.Gson

data class Traffic(
    val up: Long,
    val down: Long,
)

val Traffic.speedText: String
    get() = "${up.formatBytes}/sâ†? ${down.formatBytes}/sâ†?

fun Core.getSpeedTrafficText(onlyStatisticsProxy: Boolean): String {
    try {
        val res = getTraffic(onlyStatisticsProxy)
        val traffic = Gson().fromJson(res, Traffic::class.java)
        return traffic.speedText
    } catch (e: Exception) {
        GlobalState.log(e.message + "")
        return ""
    }
}