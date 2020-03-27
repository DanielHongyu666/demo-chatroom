
package io.rong.message;

import android.os.Parcel;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;

import io.rong.common.ParcelUtils;
import io.rong.imlib.MessageTag;
import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.UserInfo;

@MessageTag(value = "RC:Chatroom:User:Ban", flag = 3)
public class ChatroomUserBan extends MessageContent {
  public ChatroomUserBan() {
  }
  public ChatroomUserBan(byte[] data) {
    String jsonStr = null;
    try {
        jsonStr = new String(data, "UTF-8");
    } catch (UnsupportedEncodingException e) {
        e.printStackTrace();
    }
    try {
        JSONObject jsonObj = new JSONObject(jsonStr);
        
          if (jsonObj.has("id")){
            id = jsonObj.optString("id");
          }
        
          if (jsonObj.has("duration")){
            duration = jsonObj.optInt("duration");
          }
        
          if (jsonObj.has("extra")){
            extra = jsonObj.optString("extra");
          }
        if (jsonObj.has("user")){
            setUserInfo(parseJsonToUserInfo(jsonObj.optJSONObject("user")));
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
    
      
         ParcelUtils.writeToParcel(dest, id);
      
    
      
         ParcelUtils.writeToParcel(dest, duration);
      
    
      
         ParcelUtils.writeToParcel(dest, extra);
      dest.writeParcelable(getUserInfo(),0);
    
  }
  protected ChatroomUserBan(Parcel in) {
        id = ParcelUtils.readFromParcel(in);
          duration = ParcelUtils.readIntFromParcel(in);
        extra = ParcelUtils.readFromParcel(in);
      setUserInfo((UserInfo) in.readParcelable(UserInfo.class.getClassLoader()));
    
  }
  public static final Creator<ChatroomUserBan> CREATOR = new Creator<ChatroomUserBan>() {
    @Override
    public ChatroomUserBan createFromParcel(Parcel source) {
        return new ChatroomUserBan(source);
    }
    @Override
    public ChatroomUserBan[] newArray(int size) {
        return new ChatroomUserBan[size];
    }
  };
  
    private String id;
    public void setId(   String  id) {
        this.id = id;
    }
    public String getId() {
      return id;
    }
  
    private int duration;
    public void setDuration( int    duration) {
        this.duration = duration;
    }
    public  int getDuration() {
      return duration;
    }
  
    private String extra;
    public void setExtra(   String  extra) {
        this.extra = extra;
    }
    public String getExtra() {
      return extra;
    }
  
}
