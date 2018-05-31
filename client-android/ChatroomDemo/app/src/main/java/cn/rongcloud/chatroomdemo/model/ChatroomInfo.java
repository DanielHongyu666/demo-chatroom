package cn.rongcloud.chatroomdemo.model;

import android.net.Uri;

/**
 * Created by duanliuyi on 2018/5/9.
 */

public class ChatroomInfo {

    private String chatroomId;
    private String chatroomName;
    private String liveStatus;
    private int onlineNum;
    private Uri chatUri;

    public ChatroomInfo(String chatroomId, String chatroomName, String liveStatus, int onlineNum, Uri chatUri) {
        this.chatroomId = chatroomId;
        this.chatroomName = chatroomName;
        this.liveStatus = liveStatus;
        this.onlineNum = onlineNum;
        this.chatUri = chatUri;
    }

    public String getLiveId() {
        return chatroomId;
    }

    public void setLiveId(String chatroomId) {
        this.chatroomId = chatroomId;
    }

    public String getLiveName() {
        return chatroomName;
    }

    public void setLiveName(String chatroomName) {
        this.chatroomName = chatroomName;
    }

    public String getLiveStatus() {
        return liveStatus;
    }

    public void setLiveStatus(String liveStatus) {
        this.liveStatus = liveStatus;
    }

    public int getOnlineNum() {
        return onlineNum;
    }

    public void setOnlineNum(int onlineNum) {
        this.onlineNum = onlineNum;
    }

    public Uri getChatUri() {
        return chatUri;
    }

    public void setChatUri(Uri chatUri) {
        this.chatUri = chatUri;
    }
}
