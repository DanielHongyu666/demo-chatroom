package cn.rongcloud.chatroomdemo.message;

import android.os.Parcel;
import android.text.TextUtils;

import com.google.gson.Gson;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

import io.rong.common.RLog;
import io.rong.imlib.MessageTag;
import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.UserInfo;

/**
 * 由于没有用户列表，所以增加一个同步用户信令列表的信令
 * Created by wangw on 2019-09-06.
 */
@MessageTag(value = "RC:Chatroom:SyncUserInfo", flag = 3)
public class ChatroomSyncUserInfo extends MessageContent {

    private String extra;
    private List<UserInfo> userInfos;   //主播信息列表


    public ChatroomSyncUserInfo(byte[] data) {
        String jsonStr = null;
        try {
            jsonStr = new String(data, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        try {
            JSONObject jsonObj = new JSONObject(jsonStr);

            if (jsonObj.has("extra")){
                extra = jsonObj.optString("extra");
            }
            if (jsonObj.has("userInfos")){
                JSONArray arr = jsonObj.optJSONArray("userInfos");
                ArrayList<UserInfo> users = new ArrayList<>();
                for (int i = 0; i < arr.length(); i++) {
                    users.add(parseJsonToUserInfo(arr.optJSONObject(i)));
                }
                userInfos = users;
            }
            if (jsonObj.has("user")){
                setUserInfo(parseJsonToUserInfo(jsonObj.optJSONObject("user")));
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }


    public ChatroomSyncUserInfo(List<UserInfo> userInfos) {
        this.userInfos = userInfos;
    }

    public ChatroomSyncUserInfo(){

    }




    @Override
    public byte[] encode() {
        JSONObject jsonObj = new JSONObject();
        try {
            jsonObj.putOpt("extra", extra);
            if (userInfos != null) {
                JSONArray jArr = new JSONArray();
                for (UserInfo userInfo : userInfos) {
                    jArr.put(getJSONUserInfo(userInfo));
                }
                jsonObj.putOpt("userInfos", jArr);
            }
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

    public JSONObject getJSONUserInfo(UserInfo info) {
        if (info != null && info.getUserId() != null) {
            JSONObject jsonObject = new JSONObject();

            try {
                jsonObject.put("id", info.getUserId());
                if (!TextUtils.isEmpty(info.getName())) {
                    jsonObject.put("name", info.getName());
                }

                if (info.getPortraitUri() != null) {
                    jsonObject.put("portrait", info.getPortraitUri());
                }

                if (!TextUtils.isEmpty(info.getExtra())) {
                    jsonObject.put("extra", info.getExtra());
                }
            } catch (JSONException var3) {
                RLog.e("MessageContent", "JSONException " + var3.getMessage());
            }

            return jsonObject;
        } else {
            return null;
        }
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.extra);
        dest.writeTypedList(this.userInfos);
        dest.writeParcelable(getUserInfo(),0);
    }

    protected ChatroomSyncUserInfo(Parcel in) {
        this.extra = in.readString();
        this.userInfos = in.createTypedArrayList(UserInfo.CREATOR);
        setUserInfo((UserInfo) in.readParcelable(UserInfo.class.getClassLoader()));
    }

    public static final Creator<ChatroomSyncUserInfo> CREATOR = new Creator<ChatroomSyncUserInfo>() {
        @Override
        public ChatroomSyncUserInfo createFromParcel(Parcel source) {
            return new ChatroomSyncUserInfo(source);
        }

        @Override
        public ChatroomSyncUserInfo[] newArray(int size) {
            return new ChatroomSyncUserInfo[size];
        }
    };

    public String getExtra() {
        return extra;
    }

    public List<UserInfo> getUserInfos() {
        return userInfos;
    }
}
