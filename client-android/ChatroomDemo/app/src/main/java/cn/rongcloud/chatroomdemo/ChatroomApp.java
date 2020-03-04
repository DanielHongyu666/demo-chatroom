package cn.rongcloud.chatroomdemo;

import android.app.Application;
import android.content.Context;
import android.util.Log;

import cn.rongcloud.chatroomdemo.utils.DataInterface;
import io.rong.imlib.RongIMClient;

/**
 * Created by duanliuyi on 2018/5/10.
 */

public class ChatroomApp extends Application {
    private static final String TAG = "ChatroomApp";
    private static Context context;

    @Override
    public void onCreate() {
        super.onCreate();
        context = this;
        ChatroomKit.init(this, DataInterface.appKey);
        RongIMClient.getInstance().setConnectionStatusListener(new RongIMClient.ConnectionStatusListener() {
            @Override
            public void onChanged(ConnectionStatus status) {
                switch (status) {
                    case CONNECTED://连接成功。
                        Log.i(TAG, "连接成功");
                        String currentUserId = RongIMClient.getInstance().getCurrentUserId();
                        ChatroomKit.setCurrentUser(DataInterface.getUserInfo(currentUserId));
                        break;
                    case DISCONNECTED://断开连接。
                        Log.i(TAG, "断开连接");
                        break;
                    case CONNECTING://连接中。
                        Log.i(TAG, "连接中");
                        break;
                    case NETWORK_UNAVAILABLE://网络不可用。
                        Log.i(TAG, "网络不可用");
                        break;
                    case KICKED_OFFLINE_BY_OTHER_CLIENT://用户账户在其他设备登录，本机会被踢掉线
                        Log.i(TAG, "用户账户在其他设备登录");
                        break;
                }
            }
        });

    }

    public static Context getContext() {
        return context;
    }
}
