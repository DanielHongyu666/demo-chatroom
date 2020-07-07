package cn.rongcloud.chatroomdemo.http.callbacks;

import cn.rongcloud.rtc.base.RTCErrorCode;

public interface HttpCallback<T> {

    void onSuccess(T t);

    void onFail(RTCErrorCode errorCode);
}
