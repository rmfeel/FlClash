// IEventInterface.aidl
package com.rmmy.vpn.service;

import com.rmmy.vpn.service.IAckInterface;

interface IEventInterface {
    oneway void onEvent(in String id, in byte[] data,in boolean isSuccess, in IAckInterface ack);
}