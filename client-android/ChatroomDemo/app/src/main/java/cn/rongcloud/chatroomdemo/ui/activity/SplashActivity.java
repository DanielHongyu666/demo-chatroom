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
        String currentToken = DataInterface.getUserModes().get(random + 50).getToken();


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
