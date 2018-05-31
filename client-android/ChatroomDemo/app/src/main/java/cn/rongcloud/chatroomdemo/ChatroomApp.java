package cn.rongcloud.chatroomdemo;

import android.app.Application;
import android.content.Context;

import cn.rongcloud.chatroomdemo.utils.DataInterface;

/**
 * Created by duanliuyi on 2018/5/10.
 */

public class ChatroomApp extends Application {

    private static Context context;

    @Override
    public void onCreate() {
        super.onCreate();
        context = this;
        ChatroomKit.init(this, DataInterface.appKey);


    }

    public static Context getContext() {
        return context;
    }
}
