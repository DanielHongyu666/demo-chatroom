
package io.rong.message;

import android.os.Parcel;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;

import io.rong.common.ParcelUtils;
import io.rong.imlib.MessageTag;
import io.rong.imlib.model.MessageContent;

@MessageTag(value = "RC:Chatroom:Follow", flag = 3)
public class ChatroomFollow extends MessageContent {
  public ChatroomFollow() {
  }
  public ChatroomFollow(byte[] data) {
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
        
          if (jsonObj.has("rank")){
            rank = jsonObj.optInt("rank");
          }
        
          if (jsonObj.has("level")){
            level = jsonObj.optInt("level");
          }
        
          if (jsonObj.has("extra")){
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
        
            jsonObj.put("rank", rank);
        
            jsonObj.put("level", level);
        
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
      
    
      
         ParcelUtils.writeToParcel(dest, rank);
      
    
      
         ParcelUtils.writeToParcel(dest, level);
      
    
      
         ParcelUtils.writeToParcel(dest, extra);
      
    
  }
  protected ChatroomFollow(Parcel in) {
    
      
        id = ParcelUtils.readFromParcel(in);
      
    
      
        
          rank = ParcelUtils.readIntFromParcel(in);
        
      
    
      
        
          level = ParcelUtils.readIntFromParcel(in);
        
      
    
      
        extra = ParcelUtils.readFromParcel(in);
      
    
  }
  public static final Creator<ChatroomFollow> CREATOR = new Creator<ChatroomFollow>() {
    @Override
    public ChatroomFollow createFromParcel(Parcel source) {
        return new ChatroomFollow(source);
    }
    @Override
    public ChatroomFollow[] newArray(int size) {
        return new ChatroomFollow[size];
    }
  };
  
    private String id;
    public void setId(   String  id) {
        this.id = id;
    }
    public String getId() {
      return id;
    }
  
    private int rank;
    public void setRank( int    rank) {
        this.rank = rank;
    }
    public  int getRank() {
      return rank;
    }
  
    private int level;
    public void setLevel( int    level) {
        this.level = level;
    }
    public  int getLevel() {
      return level;
    }
  
    private String extra;
    public void setExtra(   String  extra) {
        this.extra = extra;
    }
    public String getExtra() {
      return extra;
    }
  
}
