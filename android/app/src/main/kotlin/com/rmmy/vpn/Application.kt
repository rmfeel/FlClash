package com.rmmy.vpn

import android.app.Application
import android.content.Context
import com.rmmy.vpn.common.GlobalState

class Application : Application() {

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        GlobalState.init(this)
    }
}
