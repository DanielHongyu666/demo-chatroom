package cn.rongcloud.chatroomdemo.ui.activity;

import android.content.Intent;
import android.graphics.Paint;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.View;
import android.widget.AdapterView;
import android.widget.GridView;
import android.widget.TextView;

import cn.rongcloud.chatroomdemo.http.HttpHelper;
import cn.rongcloud.chatroomdemo.http.Request;
import cn.rongcloud.chatroomdemo.http.RequestMethod;
import com.google.gson.Gson;

import io.rong.imlib.RongIMClient.ConnectionErrorCode;
import io.rong.imlib.RongIMClient.DatabaseOpenStatus;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.model.BaseResponse;
import cn.rongcloud.chatroomdemo.model.ChatroomInfo;
import cn.rongcloud.chatroomdemo.model.RoleType;
import cn.rongcloud.chatroomdemo.ui.adapter.LiveListAdapter;
import cn.rongcloud.chatroomdemo.ui.panel.LoginDialog;
import cn.rongcloud.chatroomdemo.updateapk.UpDateApkHelper;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import cn.rongcloud.chatroomdemo.utils.LogUtils;
import cn.rongcloud.rtc.utils.BuildVersion;
import io.rong.imlib.RongIMClient;

/**
 * Created by duanliuyi on 2018/5/9.
 */

public class LiveListActivity extends BaseActivity {

    GridView mGridView;
    LiveListAdapter mAdapter;
    TextView mTvEmpty;
    private final String TAG = "LiveListActivity";


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_live_list);

//        showLoading("IM登录中");

        onInitView();
        new UpDateApkHelper(this)
                .diffVersionFromServer();
    }

    private void onInitView() {
        mGridView = (GridView) findViewById(R.id.gridview_live);
        mTvEmpty = findViewById(R.id.tv_empty);
        mTvEmpty.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);
//        final ArrayList<ChatroomInfo> infos = DataInterface.getChatroomList();
        mAdapter = new LiveListAdapter(LiveListActivity.this, new ArrayList<ChatroomInfo>());
        mGridView.setAdapter(mAdapter);
        mGridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(final AdapterView<?> adapterView, View view, final int i, long l) {
                if (!DataInterface.isImConnected()) {
                    showToast("IM连接中，请稍后再试");
                    onConnectIm();
                } else if (!DataInterface.isLogin()){
                    new LoginDialog()
                            .setListener(new LoginDialog.LoginDialogListener() {
                                @Override
                                public void onLoginSuccess() {
                                    RoomInfoActivity.jumpTo(LiveListActivity.this, (ChatroomInfo) mAdapter.getItem(i), RoleType.VIEWER);
                                }

                                @Override
                                public void onFailed() {

                                }
                            })
                            .show(getSupportFragmentManager(),"loginDialog");
                } else {
                    RoomInfoActivity.jumpTo(LiveListActivity.this,(ChatroomInfo) mAdapter.getItem(i), RoleType.VIEWER);
                }


            }
        });
        findViewById(R.id.createroom).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                createLiveRoom();
            }
        });
        findViewById(R.id.iv_refresh).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showLoading();
                refreshData();
            }
        });
        findViewById(R.id.tv_empty).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                createLiveRoom();
            }
        });
        TextView tvVersion = findViewById(R.id.tv_version);
        tvVersion.setText("SealLive v"+DataInterface.APP_VERSION +" , RTCLib v"+ BuildVersion.SDK_VERSION);
    }

    /**
     * 创建直播房间
     */
    private void createLiveRoom() {
        LogUtils.d(TAG,"createLiveRoom");
        if (DataInterface.isImConnected()){
            startActivity(new Intent(LiveListActivity.this, CreateLiveRoomActivity.class));
        } else {
            showToast("IM连接中，请稍后再试");
            onConnectIm();
        }
    }

    /**
     * 连接IM
     */
    private void onConnectIm() {
        if (DataInterface.isImConnecting() || DataInterface.isImConnected())
            return;
        DataInterface.connectIM(new RongIMClient.ConnectCallback() {
            public void onTokenIncorrect() {
                postShowToast("获取 Token 失败或 Token 无效");
            }

            @Override
            public void onSuccess(String s) {
                postShowToast("Im 连接成功");
            }

            @Override
            public void onError(ConnectionErrorCode connectionErrorCode) {
                if (ConnectionErrorCode.RC_CONN_TOKEN_INCORRECT == connectionErrorCode){
                    onTokenIncorrect();
                }else {
                    postShowToast("Im 连接失败:"+connectionErrorCode.getValue());
                }
            }

            @Override
            public void onDatabaseOpened(DatabaseOpenStatus databaseOpenStatus) {

            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        DataInterface.logout();
    }

    @Override
    protected void onResume() {
        super.onResume();
        refreshData();
    }

    /**
     * 刷新直播列表
     */
    public void refreshData(){
        Request.Builder request = new Request.Builder();
        request.url(DataInterface.APPSERVER+DataInterface.QUERY);
        request.method(RequestMethod.POST);
        request.body(new JSONObject().toString());
        HttpHelper.getDefault().request(request.build(), new HttpHelper.ResultCallback() {
            @Override
            public void onResponse(final String s) {
                LogUtils.i("DemoServer","refreshData result = "+s);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        closeLoading();
                        if (isFinish())
                            return;
                           try {
                               BaseResponse res = new Gson().fromJson(s, BaseResponse.class);
                               if (res.isSuccess()) {
                                   if (res.roomList == null || res.roomList.isEmpty()) {
                                       mTvEmpty.setVisibility(View.VISIBLE);
                                       mGridView.setVisibility(View.INVISIBLE);
                                   } else {
                                       mTvEmpty.setVisibility(View.INVISIBLE);
                                       mGridView.setVisibility(View.VISIBLE);
                                   }
                                   mAdapter.refreshData(res.roomList);
                               } else {
                                   showToast("获取直播列表失败：" + res.desc);
                               }
                           }catch (Exception e){
                               e.printStackTrace();
                               showToast("返回直播列表数据异常：" + e.getMessage());
                           }
                    }
                });
            }

            @Override
            public void onFailure(int i) {
                LogUtils.e("DemoServer","refreshData failure = "+i);
                postCloseLoading();
                postShowToast("获取直播列表失败: "+i);
            }
        });
    }
}
