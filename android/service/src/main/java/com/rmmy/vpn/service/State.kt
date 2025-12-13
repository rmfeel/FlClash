package com.rmmy.vpn.service

import android.content.Intent
import com.rmmy.vpn.common.ServiceDelegate
import com.rmmy.vpn.service.models.NotificationParams
import com.rmmy.vpn.service.models.VpnOptions
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.sync.Mutex

object State {
    var options: VpnOptions? = null
    var notificationParamsFlow: MutableStateFlow<NotificationParams?> = MutableStateFlow(
        NotificationParams()
    )

    val runLock = Mutex()
    var runTime: Long = 0L

    var delegate: ServiceDelegate<IBaseService>? = null

    var intent: Intent? = null
}