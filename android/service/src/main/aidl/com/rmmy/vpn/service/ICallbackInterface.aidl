// ICallbackInterface.aidl
package com.rmmy.vpn.service;

import com.rmmy.vpn.service.IAckInterface;

interface ICallbackInterface {
    oneway void onResult(in byte[] data,in boolean isSuccess, in IAckInterface ack);
}