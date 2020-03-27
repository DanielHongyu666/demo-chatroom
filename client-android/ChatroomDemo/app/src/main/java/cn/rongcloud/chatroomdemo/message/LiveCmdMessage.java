package cn.rongcloud.chatroomdemo.message;

import android.os.Parcel;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;

import io.rong.common.RLog;
import io.rong.imlib.MessageTag;
import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.UserInfo;

import static io.rong.imlib.MessageTag.STATUS;

/**
 * 邀请上麦、接受上麦、拒绝上麦信令
 * Created by wangw on 2019-08-28.
 */
@MessageTag(value = "RC:Chatroom:LiveCmd", flag = STATUS)
public class LiveCmdMessage extends MessageContent {

    public enum LiveCmd{
        INVITE(1),
        ACCEPT(2),
        HANGUP(3),
        DEMOTION(4);

        private int code;

        LiveCmd(int code) {
            this.code = code;
        }

        public int getCode() {
            return code;
        }

        public static LiveCmd valueOf(int code){
            for (LiveCmd cmd : values()) {
                if (cmd.code == code)
                    return cmd;
            }
            return null;
        }
    }


    private LiveCmd cmdType; //1：主播邀请上麦 2：观众接受上麦 3：观众拒绝上麦 4:降级，主播将某上麦着降级为观众
    private String extra;
    private String roomId;


    @Override
    public byte[] encode() {
        JSONObject jsonObj = new JSONObject();
        try {
            jsonObj.putOpt("extra", extra);
            jsonObj.putOpt("roomId", roomId);
            jsonObj.putOpt("cmdType", cmdType.code);
            jsonObj.putOpt("user",getJSONUserInfo());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        try {
            return jsonObj.toString().getBytes("UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(this.cmdType.code);
//        dest.writeString(this.uid);
        dest.writeString(this.extra);
        dest.writeString(this.roomId);
        dest.writeParcelable(getUserInfo(),0);
    }

    public LiveCmdMessage() {
    }

    public LiveCmdMessage(LiveCmd cmdType,String roomId) {
        this.cmdType = cmdType;
        this.roomId = roomId;
    }

    public LiveCmdMessage(byte[] data) {
        String jsonStr = null;
        try {
            jsonStr = new String(data, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        try {
            JSONObject jsonObj = new JSONObject(jsonStr);

            if (jsonObj.has("cmdType")){
                cmdType = LiveCmd.valueOf(jsonObj.optInt("cmdType"));
            }

            if (jsonObj.has("extra")){
                extra = jsonObj.optString("extra");
            }
            if (jsonObj.has("roomId")){
                roomId = jsonObj.optString("roomId");
            }
            if (jsonObj.has("user")){
                setUserInfo(parseJsonToUserInfo(jsonObj.optJSONObject("user")));
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    protected LiveCmdMessage(Parcel in) {
        this.cmdType = LiveCmd.valueOf(in.readInt());
//        this.uid = in.readString();
        this.extra = in.readString();
        this.roomId = in.readString();
        setUserInfo((UserInfo) in.readParcelable(UserInfo.class.getClassLoader()));
    }

    public static final Creator<LiveCmdMessage> CREATOR = new Creator<LiveCmdMessage>() {
        @Override
        public LiveCmdMessage createFromParcel(Parcel source) {
            return new LiveCmdMessage(source);
        }

        @Override
        public LiveCmdMessage[] newArray(int size) {
            return new LiveCmdMessage[size];
        }
    };

    public LiveCmd getCmdType() {
        return cmdType;
    }

    public String getExtra() {
        return extra;
    }

    public String getRoomId() {
        return roomId;
    }
}
