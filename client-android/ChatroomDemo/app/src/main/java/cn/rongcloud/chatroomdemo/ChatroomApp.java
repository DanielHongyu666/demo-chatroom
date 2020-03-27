package cn.rongcloud.chatroomdemo;

import android.app.Application;
import android.content.Context;
import android.os.Build;
import android.support.multidex.MultiDexApplication;

import com.tencent.bugly.crashreport.CrashReport;

import java.lang.reflect.Field;
import java.lang.reflect.Method;

import cn.rongcloud.chatroomdemo.utils.CommonUtils;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import cn.rongcloud.rtc.media.RongMediaSignalClient;

/**
 * Created by duanliuyi on 2018/5/10.
 */

public class ChatroomApp extends MultiDexApplication {

    private static Context context;

    @Override
    public void onCreate() {
        super.onCreate();
        context = this;

        DataInterface.init(this);
        ChatroomKit.init(this, DataInterface.APP_KEY);

        //bugly 配置，查看对应崩溃日志。
        String processName = CommonUtils.getCurProcessName(this);
        // 设置是否为上报进程
        CrashReport.UserStrategy strategy = new CrashReport.UserStrategy(this);
        strategy.setUploadProcess(processName.equals(getPackageName()));
        // 初始化Bugly
        CrashReport.initCrashReport(this, DataInterface.BuglyKey, true, strategy);

        disableAPIDialog();


    }

    public static Context getContext() {
        return context;
    }

    /**
     * 反射 禁止弹窗
     */
    private void disableAPIDialog() {
        if (Build.VERSION.SDK_INT < 28)
            return;
        try {
            Class clazz = Class.forName("android.app.ActivityThread");
            Method currentActivityThread = clazz.getDeclaredMethod("currentActivityThread");
            currentActivityThread.setAccessible(true);
            Object activityThread = currentActivityThread.invoke(null);
            Field mHiddenApiWarningShown = clazz.getDeclaredField("mHiddenApiWarningShown");
            mHiddenApiWarningShown.setAccessible(true);
            mHiddenApiWarningShown.setBoolean(activityThread, true);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

