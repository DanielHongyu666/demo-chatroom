package cn.rongcloud.chatroomdemo.ui.activity;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentActivity;

import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.RongIMClient.ConnectionErrorCode;
import io.rong.imlib.RongIMClient.DatabaseOpenStatus;

/**
 * Created by duanliuyi on 2018/5/9.
 */

public class SplashActivity extends FragmentActivity {

    private static String TAG = "SplashActivity";



    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_splash);

        onConnectIm();

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = null;
                intent = new Intent(SplashActivity.this, LiveListActivity.class);
                startActivity(intent);
                finish();
            }
        }, 3000);
    }

    private void onConnectIm() {
        DataInterface.connectIM(new RongIMClient.ConnectCallback() {

            @Override
            public void onSuccess(String s) {
            }

            @Override
            public void onError(ConnectionErrorCode connectionErrorCode) {

            }

            @Override
            public void onDatabaseOpened(DatabaseOpenStatus databaseOpenStatus) {

            }

        });
    }

}
