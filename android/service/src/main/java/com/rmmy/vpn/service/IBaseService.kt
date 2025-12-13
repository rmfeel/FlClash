package com.rmmy.vpn.service

import com.rmmy.vpn.common.BroadcastAction
import com.rmmy.vpn.common.GlobalState
import com.rmmy.vpn.common.sendBroadcast

interface IBaseService {
    fun handleCreate() {
        GlobalState.log("Service create")
        BroadcastAction.SERVICE_CREATED.sendBroadcast()
    }

    fun handleDestroy() {
        GlobalState.log("Service destroy")
        BroadcastAction.SERVICE_DESTROYED.sendBroadcast()
    }

    fun start()

    fun stop()
}