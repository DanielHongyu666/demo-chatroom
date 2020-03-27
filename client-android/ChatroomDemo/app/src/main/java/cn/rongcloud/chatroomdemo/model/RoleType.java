package cn.rongcloud.chatroomdemo.model;

/**
 * Created by wangw on 2019-08-21.
 */
public enum RoleType {

    VIEWER(0),  //观众
    ANCHOR(1),  //互动主播
    HOST(2);  //房主

    private int mValue;
    RoleType(int value){
        mValue =value;
    }

    public int getValue() {
        return mValue;
    }

}
