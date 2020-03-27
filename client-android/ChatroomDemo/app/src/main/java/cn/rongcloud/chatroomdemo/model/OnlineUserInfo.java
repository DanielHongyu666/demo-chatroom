package cn.rongcloud.chatroomdemo.model;

import android.net.Uri;
import android.os.Parcel;

import io.rong.imlib.model.UserInfo;

/**
 * Created by wangw on 2019-08-23.
 */
public class OnlineUserInfo extends UserInfo {

    public RoleType roleType = RoleType.VIEWER;

    public OnlineUserInfo(Parcel in) {
        super(in);
    }

    public OnlineUserInfo(String id, String name, Uri portraitUri) {
        super(id, name, portraitUri);
    }
}
