// IRemoteInterface.aidl
package com.rmmy.vpn.service;

import com.rmmy.vpn.service.ICallbackInterface;
import com.rmmy.vpn.service.IEventInterface;
import com.rmmy.vpn.service.IResultInterface;
import com.rmmy.vpn.service.models.VpnOptions;
import com.rmmy.vpn.service.models.NotificationParams;

interface IRemoteInterface {
    void invokeAction(in String data, in ICallbackInterface callback);
    void updateNotificationParams(in NotificationParams params);
    void startService(in VpnOptions options, in long runTime, in IResultInterface result);
    void stopService(in IResultInterface result);
    void setEventListener(in IEventInterface event);
    void setCrashlytics(in boolean enable);
    long getRunTime();
}