package cn.rongcloud.chatroomdemo.ui.panel;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;
import static android.view.ViewGroup.LayoutParams.WRAP_CONTENT;

import android.app.Dialog;
import android.app.DialogFragment;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Parcelable;
import android.support.annotation.Nullable;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.RecyclerView.Adapter;
import android.support.v7.widget.RecyclerView.ViewHolder;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.TextView;
import android.widget.Toast;
import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.model.CDNUrl;
import cn.rongcloud.chatroomdemo.ui.panel.CDNSupplyListDialog.SelectCDNCallback;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import cn.rongcloud.rtc.api.callback.IRCRTCResultDataCallback;
import cn.rongcloud.rtc.api.stream.RCRTCLiveInfo;
import cn.rongcloud.rtc.base.RTCErrorCode;
import cn.rongcloud.rtc.media.http.HttpClient;
import cn.rongcloud.rtc.media.http.Request;
import cn.rongcloud.rtc.media.http.Request.Builder;
import cn.rongcloud.rtc.media.http.RequestMethod;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by wangw on 2020/5/25.
 */
public class SetCDNPushDialog extends DialogFragment implements OnClickListener {
  private final String SPLIT = " -- ";

  public static SetCDNPushDialog newInstance(RCRTCLiveInfo rtcLiveInfo,String sessionId) {

    Bundle args = new Bundle();
    args.putParcelable("liveinfo", (Parcelable) rtcLiveInfo);
    args.putString("sessionId",sessionId);
    SetCDNPushDialog fragment = new SetCDNPushDialog();
    fragment.setArguments(args);
    return fragment;
  }

  private View mRootView;
  private RecyclerView mRecyclerView;
  private TextView mTvCDN;
  private RCRTCLiveInfo mLiveInfo;
  private CDNPushUrlAdapter mAdapter;
  private ArrayList<CDNUrl> mCDNSupplyList;
  private String mSessionId;
  private CDNUrl mSelectedCDN;
  private List<CDNUrl> mCDNUrls;

  @Nullable
  @Override
  public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container,
      Bundle savedInstanceState) {
    if (mRootView == null) {
      mRootView = inflater.inflate(R.layout.widget_layout_set_cdnpush_panel, container, false);
      mRootView.findViewById(R.id.btn_add).setOnClickListener(this);
      mRootView.findViewById(R.id.iv_close).setOnClickListener(this);
      mTvCDN = mRootView.findViewById(R.id.tv_cdn);
      mTvCDN.setOnClickListener(this);
      mRecyclerView = mRootView.findViewById(R.id.recyclerview);
    }else if (mRootView.getParent() != null){
      ((ViewGroup)mRootView.getParent()).removeView(mRootView);
    }
    return mRootView;
  }

  @Override
  public void onStart() {
    super.onStart();
    Dialog dialog = getDialog();
    if (dialog == null)
      return;
    dialog.setCancelable(false);
    dialog.setCanceledOnTouchOutside(false);
    Window window = dialog.getWindow();
    window.setLayout(MATCH_PARENT,WRAP_CONTENT);
    window.setGravity(Gravity.BOTTOM);
    window.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
  }

  @Override
  public void onActivityCreated(Bundle savedInstanceState) {
    super.onActivityCreated(savedInstanceState);
    mLiveInfo = getArguments().getParcelable("liveinfo");
    mSessionId = getArguments().getString("sessionId");
    try {
      if (mCDNSupplyList == null)
        onGetCDNSupplyList();
    } catch (JSONException e) {
      e.printStackTrace();
    }
    if (mAdapter == null)
      initCDNPushUrlView();
  }

  private void initCDNPushUrlView() {
    mCDNUrls = new ArrayList<>();
    mRecyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
    mAdapter = new CDNPushUrlAdapter(mCDNUrls);
    mRecyclerView.setAdapter(mAdapter);
  }

  @Override
  public void onClick(View v) {
    switch (v.getId()){
      case R.id.btn_add:
        if (mSelectedCDN != null) {
          try {
            onGeneratorCDNUrl(mSelectedCDN);
          } catch (JSONException e) {
            e.printStackTrace();
          }
        }
        break;
      case R.id.iv_close:
        dismiss();
        break;
      case R.id.tv_cdn:
        if (mCDNSupplyList != null) {
          CDNSupplyListDialog dialog = CDNSupplyListDialog.newInstance(mCDNSupplyList);
          dialog.setSelectCDNCallback(new SelectCDNCallback() {
            @Override
            public void onSelected(CDNUrl cdn) {
              mSelectedCDN = cdn;
              mTvCDN.setText(mSelectedCDN.name);
            }
          });
          dialog.show(getFragmentManager(),"CDNSupplyListDialog");
        } else {
          showToast("正在获取 CDNSupply List。。。");
        }
        break;
    }

  }

  private void onGeneratorCDNUrl(final CDNUrl cdn) throws JSONException {
    JSONObject body = new JSONObject();
    body.put("roomId",mLiveInfo.getRoomId());
    body.put("appName","sealLive");
    body.put("streamName",mSessionId);
    body.put("cdnId",cdn.cdnId);
    Request request = new Builder()
        .url(DataInterface.APPSERVER_CDN + DataInterface.CDNURL)
        .method(RequestMethod.POST)
        .body(body.toString())
        .build();

    HttpClient.getDefault()
        .request(
            request,
            new HttpClient.ResultCallback() {
              @Override
              public void onResponse(String s) {
                try {
                  final JSONObject obj = new JSONObject(s);
                  if (obj.optInt("code") == 0) {
                    JSONArray cdnList = obj.optJSONArray("cdnList");
                    if (cdnList != null && cdnList.length() > 0) {
                      JSONObject jsonObject = cdnList.getJSONObject(0);
                      String url = jsonObject.optString("hlsPlay");

                      if (!TextUtils.isEmpty(url)){
                        cdn.pullUrl = url;
                      }
                      url = jsonObject.optString("rtmpPlay");
                      if (!TextUtils.isEmpty(url)){
                        cdn.pullUrl += SPLIT + url;
                      }
                      url = jsonObject.optString("flvPlay");
                      if (!TextUtils.isEmpty(url)){
                        cdn.pullUrl += SPLIT + url;
                      }

                      cdn.pushUrl = jsonObject.optString("pushUrl");
                      onAddCDNPushUrl(cdn);
                    }else {
                      postShowToast("生成CDN推流地址失败, 返回数据中没有 cdnList 节点");
                    }
                  }else {
                    postShowToast("生成CDN推流地址失败："+obj.optString("desc"));
                  }
                } catch (JSONException e) {
                  e.printStackTrace();
                }
              }

              @Override
              public void onFailure(final int i) {
                postShowToast("生成CDN推流地址失败："+i);
              }

            });
  }


  class CDNPushUrlAdapter extends Adapter<CDNSupplyVH>{

    private List<CDNUrl> mUrls;

    public CDNPushUrlAdapter(List<CDNUrl> urls) {
      mUrls = urls;
    }

    @Override
    public CDNSupplyVH onCreateViewHolder(ViewGroup parent, int viewType) {
      return new CDNSupplyVH(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_cdn_pushurl,parent,false));
    }

    @Override
    public void onBindViewHolder(CDNSupplyVH holder, int position) {
      holder.onBindData(mUrls.get(position));
    }

    @Override
    public int getItemCount() {
      return mUrls.size();
    }
  }


  class CDNSupplyVH extends ViewHolder implements OnClickListener {

    private CDNUrl mData;
    private TextView mTvUrl;

    public CDNSupplyVH(View itemView) {
      super(itemView);
      itemView.findViewById(R.id.btn_remove).setOnClickListener(this);
      itemView.findViewById(R.id.btn_copy).setOnClickListener(this);
      mTvUrl = itemView.findViewById(R.id.tv_url);
    }

    public void onBindData(CDNUrl data) {
      mData = data;
      mTvUrl.setText(mData.pushUrl);
    }

    @Override
    public void onClick(View v) {
      switch (v.getId()){
        case R.id.btn_remove:
          onRemoveCDNPushUrl(mData);
          break;
        case R.id.btn_copy:
          ClipboardManager cm = (ClipboardManager) getActivity().getSystemService(Context.CLIPBOARD_SERVICE);
          ClipData mClipData = ClipData.newPlainText("Label", mData.pullUrl);
          cm.setPrimaryClip(mClipData);
          showToast("已复制");
          break;
      }
    }
  }

  private boolean isCancel(){
    return getActivity() == null || isDetached();
  }

  private void onRemoveCDNPushUrl(final CDNUrl url) {
    mLiveInfo.removePublishStreamUrl(url.pushUrl, new IRCRTCResultDataCallback<String[]>() {
      @Override
      public void onSuccess(final String[] strings) {
        if (isCancel()){
          return;
        }
        getActivity().runOnUiThread(new Runnable() {
          @Override
          public void run() {
            if (isCancel())
              return;
            if (mCDNUrls.contains(url)) {
              mCDNUrls.remove(url);
              mAdapter.notifyDataSetChanged();
            }
          }
        });
      }

      @Override
      public void onFailed(RTCErrorCode rtcErrorCode) {
      }

      @Override
      public void onFailed(String[] strings, final RTCErrorCode rtcErrorCode) {
        postShowToast("删除推流地址失败: "+rtcErrorCode.getReason());
      }
    });
  }

  private void showToast(String msg){
    if (isCancel())
      return;
    Toast.makeText(getActivity(),msg,Toast.LENGTH_LONG).show();
  }

  private void postShowToast(final String msg){
    if (isCancel())
      return;
    getActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        showToast(msg);
      }
    });
  }

  private void onAddCDNPushUrl(final CDNUrl url){
    mLiveInfo.addPublishStreamUrl(url.pushUrl, new IRCRTCResultDataCallback<String[]>() {
      @Override
      public void onSuccess(final String[] strings) {
        if (isCancel())
          return;
        getActivity().runOnUiThread(new Runnable() {
          @Override
          public void run() {
            if (isCancel())
              return;
            if (!mCDNUrls.contains(url)) {
              mCDNUrls.add(url);
              mAdapter.notifyDataSetChanged();
            }
          }
        });
      }

      @Override
      public void onFailed(RTCErrorCode rtcErrorCode) {

      }

      @Override
      public void onFailed(String[] strings, final RTCErrorCode rtcErrorCode) {
        postShowToast("添加推流地址失败: "+rtcErrorCode.getReason());
      }
    });
  }

  private void onGetCDNSupplyList() throws JSONException {
    JSONObject body = new JSONObject();
    body.put("roomId",mLiveInfo.getRoomId());
    Request request = new Builder()
        .url(DataInterface.APPSERVER_CDN+DataInterface.CDNSUPPLY)
        .method(RequestMethod.POST)
        .body(body.toString())
        .build();

    HttpClient.getDefault()
        .request(
            request,
            new HttpClient.ResultCallback() {
              @Override
              public void onResponse(String s) {
                try {
                  final JSONObject obj = new JSONObject(s);
                  if (obj.optInt("code") == 0){
                    JSONArray jsonArray = obj.optJSONArray("cdnSupplyList");
                    mCDNSupplyList = new ArrayList<>();
                    JSONObject cdn;
                    for (int i = 0; i < jsonArray.length(); i++) {
                      cdn = jsonArray.optJSONObject(i);
                      mCDNSupplyList.add(new CDNUrl(cdn.optInt("cdnId"),cdn.optString("name")));
                    }
                  }else {
                    postShowToast("获取 CDN 支持列表失败: "+obj.optString("desc"));
                  }
                } catch (JSONException e) {
                  e.printStackTrace();
                }
              }

              @Override
              public void onFailure(final int i) {
                postShowToast("获取 CDN 支持列表失败: "+i);
              }
            });

  }


}
