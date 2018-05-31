package cn.rongcloud.chatroomdemo.ui.activity;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentActivity;
import android.util.Log;

import cn.rongcloud.chatroomdemo.ChatroomKit;
import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import io.rong.imlib.RongIMClient;

/**
 * Created by duanliuyi on 2018/5/9.
 */

public class SplashActivity extends FragmentActivity {

    private static String TAG = "SplashActivity";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_splash);

        DataInterface.initUserInfo();
        int random = DataInterface.getRandomNum(50);
        String currentToken = DataInterface.getUserModes().get(random + 51).getToken();


        ChatroomKit.connect(currentToken, new RongIMClient.ConnectCallback() {
            @Override
            public void onTokenIncorrect() {
                Log.i(TAG, "onTokenIncorrect");
            }

            @Override
            public void onSuccess(String s) {
                // Toast.makeText(LiveListActivity.this,"登陆成功",Toast.LENGTH_SHORT).show();
                ChatroomKit.setCurrentUser(DataInterface.getUserInfo(s));
                Log.i(TAG, "connectSuccess");
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                Log.i(TAG, "connect error code = " + e);
            }
        });

        RongIMClient.getInstance().setConnectionStatusListener(new RongIMClient.ConnectionStatusListener() {
            @Override
            public void onChanged(ConnectionStatus status) {
                switch (status) {

                    case CONNECTED://连接成功。
                        Log.i(TAG, "连接成功");
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


        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(SplashActivity.this, LiveListActivity.class);
                startActivity(intent);
                finish();
            }
        }, 3000);
    }
}
