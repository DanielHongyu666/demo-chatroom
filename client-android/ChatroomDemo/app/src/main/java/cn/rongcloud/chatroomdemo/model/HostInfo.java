package cn.rongcloud.chatroomdemo.model;

import android.net.Uri;

/**
 * Created by duanliuyi on 2018/5/29.
 */

public class HostInfo {

    private String userId;
    private Uri avatar;
    private int avatarRes;
    private String name;
    private int fansNum;
    private int likeNum;
    private int giftNum;
    private int focusNum;

    public HostInfo(String userId, String name, Uri avatar, int fansNum, int likeNum, int giftNum, int focusNum) {
        this.userId = userId;
        this.name = name;
        this.avatar = avatar;
        this.fansNum = fansNum;
        this.likeNum = likeNum;
        this.giftNum = giftNum;
        this.focusNum = focusNum;
    }

    public HostInfo(String name, Uri avatar) {
        this.name = name;
        this.avatar = avatar;
    }

    public HostInfo(String name, int avatarRes) {
        this.name = name;
        this.avatarRes = avatarRes;
    }

    public HostInfo() {
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public Uri getAvatar() {
        return avatar;
    }

    public void setAvatar(Uri avatar) {
        this.avatar = avatar;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getFansNum() {
        return fansNum;
    }

    public void setFansNum(int fansNum) {
        this.fansNum = fansNum;
    }

    public int getLikeNum() {
        return likeNum;
    }

    public void setLikeNum(int likeNum) {
        this.likeNum = likeNum;
    }

    public int getGiftNum() {
        return giftNum;
    }

    public void setGiftNum(int giftNum) {
        this.giftNum = giftNum;
    }

    public int getFocusNum() {
        return focusNum;
    }

    public void setFocusNum(int focusNum) {
        this.focusNum = focusNum;
    }

    public int getAvatarRes() {
        return avatarRes;
    }

    public void setAvatarRes(int avatarRes) {
        this.avatarRes = avatarRes;
    }
}
