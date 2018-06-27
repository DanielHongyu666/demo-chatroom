package cn.rongcloud.chatroomdemo.model;

import android.os.Parcel;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;

import io.rong.common.ParcelUtils;
import io.rong.imlib.MessageTag;
import io.rong.imlib.model.MessageContent;

/**
 * Created by duanliuyi on 2018/6/25.
 */
@MessageTag(value = "app:user:ban:warn", flag = 3)
public class BanWarnMessage extends MessageContent {

    public BanWarnMessage() {
    }

    public BanWarnMessage(byte[] data) {
        String jsonStr = null;
        try {
            jsonStr = new String(data, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        try {
            JSONObject jsonObj = new JSONObject(jsonStr);

            if (jsonObj.has("id")) {
                id = jsonObj.optString("id");
            }

            if (jsonObj.has("duration")) {
                duration = jsonObj.optInt("duration");
            }

            if (jsonObj.has("extra")) {
                extra = jsonObj.optString("extra");
            }

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public byte[] encode() {
        JSONObject jsonObj = new JSONObject();
        try {

            jsonObj.put("id", id);

            jsonObj.put("duration", duration);

            jsonObj.put("extra", extra);

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


        ParcelUtils.writeToParcel(dest, id);


        ParcelUtils.writeToParcel(dest, duration);


        ParcelUtils.writeToParcel(dest, extra);


    }

    protected BanWarnMessage(Parcel in) {


        id = ParcelUtils.readFromParcel(in);


        duration = ParcelUtils.readIntFromParcel(in);


        extra = ParcelUtils.readFromParcel(in);


    }

    public static final Creator<BanWarnMessage> CREATOR = new Creator<BanWarnMessage>() {
        @Override
        public BanWarnMessage createFromParcel(Parcel source) {
            return new BanWarnMessage(source);
        }

        @Override
        public BanWarnMessage[] newArray(int size) {
            return new BanWarnMessage[size];
        }
    };

    private String id;

    public void setId(String id) {
        this.id = id;
    }

    public String getId() {
        return id;
    }

    private int duration;

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public int getDuration() {
        return duration;
    }

    private String extra;

    public void setExtra(String extra) {
        this.extra = extra;
    }

    public String getExtra() {
        return extra;
    }

}
