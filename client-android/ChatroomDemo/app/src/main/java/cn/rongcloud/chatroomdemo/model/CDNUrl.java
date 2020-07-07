package cn.rongcloud.chatroomdemo.model;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by wangw on 2020/6/1.
 */
public class CDNUrl implements Parcelable {

  public int cdnId;
  public String name;
  public String pushUrl;  //推流地址
  public String pullUrl;  //拉流地址

  public CDNUrl() {
  }

  public CDNUrl(int cdnId, String name) {
    this.cdnId = cdnId;
    this.name = name;
  }

  protected CDNUrl(Parcel in) {
    cdnId = in.readInt();
    name = in.readString();
  }

  @Override
  public void writeToParcel(Parcel dest, int flags) {
    dest.writeInt(cdnId);
    dest.writeString(name);
  }

  @Override
  public int describeContents() {
    return 0;
  }

  public static final Creator<CDNUrl> CREATOR = new Creator<CDNUrl>() {
    @Override
    public CDNUrl createFromParcel(Parcel in) {
      return new CDNUrl(in);
    }

    @Override
    public CDNUrl[] newArray(int size) {
      return new CDNUrl[size];
    }
  };
}
