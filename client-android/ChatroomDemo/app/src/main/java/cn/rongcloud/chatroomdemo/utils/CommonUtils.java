package cn.rongcloud.chatroomdemo.utils;

import cn.rongcloud.chatroomdemo.ChatroomApp;

public class CommonUtils {

    public static int dip2px(float dpValue) {
        float scale = ChatroomApp.getContext().getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }
}
