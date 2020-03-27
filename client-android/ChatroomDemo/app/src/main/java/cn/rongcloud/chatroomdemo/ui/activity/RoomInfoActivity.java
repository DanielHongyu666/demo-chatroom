package cn.rongcloud.chatroomdemo.ui.activity;

import android.Manifest;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.media.AudioManager;
import android.os.Bundle;
import android.os.PowerManager;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.google.gson.Gson;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;

import cn.rongcloud.chatroomdemo.ChatroomKit;
import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.message.ChatroomSyncUserInfo;
import cn.rongcloud.chatroomdemo.message.LiveCmdMessage;
import cn.rongcloud.chatroomdemo.model.BaseResponse;
import cn.rongcloud.chatroomdemo.model.ChatroomInfo;
import cn.rongcloud.chatroomdemo.model.OnlineUserInfo;
import cn.rongcloud.chatroomdemo.model.RoleType;
import cn.rongcloud.chatroomdemo.ui.panel.LayoutConfigDialog;
import cn.rongcloud.chatroomdemo.ui.panel.MixConfigInfoDialog;
import cn.rongcloud.chatroomdemo.ui.panel.OnlineUserPanel;
import cn.rongcloud.chatroomdemo.ui.panel.VideoViewMagr;
import cn.rongcloud.chatroomdemo.utils.CommonUtils;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import cn.rongcloud.chatroomdemo.utils.DialogUtils;
import cn.rongcloud.chatroomdemo.utils.LogUtils;
import cn.rongcloud.chatroomdemo.utils.MixConfigHelper;
import cn.rongcloud.chatroomdemo.utils.RTCNotificationService;
import cn.rongcloud.rtc.CenterManager;
import cn.rongcloud.rtc.RTCErrorCode;
import cn.rongcloud.rtc.RongRTCConfig;
import cn.rongcloud.rtc.RongRTCEngine;
import cn.rongcloud.rtc.callback.JoinLiveUICallBack;
import cn.rongcloud.rtc.callback.JoinRoomUICallBack;
import cn.rongcloud.rtc.callback.RongRTCDataResultCallBack;
import cn.rongcloud.rtc.callback.RongRTCResultUICallBack;
import cn.rongcloud.rtc.engine.view.RongRTCVideoView;
import cn.rongcloud.rtc.events.ILocalVideoFrameListener;
import cn.rongcloud.rtc.events.RTCVideoFrame;
import cn.rongcloud.rtc.events.RongRTCEglEventListener;
import cn.rongcloud.rtc.events.RongRTCEventsListener;
import cn.rongcloud.rtc.media.http.HttpClient;
import cn.rongcloud.rtc.media.http.Request;
import cn.rongcloud.rtc.media.http.RequestMethod;
import cn.rongcloud.rtc.room.RongRTCMixConfig;
import cn.rongcloud.rtc.room.RongRTCLiveInfo;
import cn.rongcloud.rtc.room.RongRTCRoom;
import cn.rongcloud.rtc.room.RongRTCRoomConfig;
import cn.rongcloud.rtc.stream.MediaType;
import cn.rongcloud.rtc.stream.local.RongRTCCapture;
import cn.rongcloud.rtc.stream.local.RongRTCLocalSourceManager;
import cn.rongcloud.rtc.stream.remote.RongRTCAVInputStream;
import cn.rongcloud.rtc.stream.remote.RongRTCLiveAVInputStream;
import cn.rongcloud.rtc.user.RongRTCRemoteUser;
import cn.rongcloud.rtc.user.RongRTCUser;
import cn.rongcloud.rtc.utils.FinLog;
import io.rong.common.fwlog.FwLog;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.UserInfo;

/**
 * 直播页面
 * Created by wangw on 2019-08-21.
 */
public class RoomInfoActivity extends LiveShowActivity implements RongRTCEventsListener, ILocalVideoFrameListener, RongRTCEglEventListener {

    private final String TAG = "RoomInfoActivity";

    /**
     *
     * @param context
     * @param info 房间信息
     * @param type 房间角色类型
     */
    public static void jumpTo(Context context, ChatroomInfo info, RoleType type){
        if (info == null) {
            Toast.makeText(context,"房间信息不能为空",Toast.LENGTH_LONG).show();
            return;
        }
        Intent intent = new Intent(context,RoomInfoActivity.class);
        intent.putExtra("roominfo",info);
        intent.putExtra("roletype",type);
        context.startActivity(intent);

    }

    private RongRTCRoom mRtcRoom;
    private VideoViewMagr mVideoMagr;
    private AtomicReference<RoleType> mRoleType;
    private List<String> unGrantedPermissions;
    private static final String[] MANDATORY_PERMISSIONS = {
            "android.permission.MODIFY_AUDIO_SETTINGS",
            "android.permission.RECORD_AUDIO",
            "android.permission.INTERNET",
            "android.permission.CAMERA",
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.READ_EXTERNAL_STORAGE,
    };
    private PowerManager powerManager;
    private PowerManager.WakeLock wakeLock;
    private MixConfigHelper mConfigHelper;
    private List<String> mAnchorList = new ArrayList<>();
    private boolean mIsQuit = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        showLoading();
        onInit();
        createPowerManager();
    }

    protected void onInit() {
        initData();
        initView();
        if (isViewer()){
            //普通观众
            LogUtils.d(TAG,"观众身份加入：开始订阅资源");
            subscribeLiveAVStream();
        }else if (mRoleType.get() == RoleType.HOST){
            //房主
            LogUtils.d(TAG,"直播身份加入：开始join room");
            joinRtcRoom();
        }else {
            LogUtils.e(TAG,"onInit: 参数异常");
            showToast("参数异常");
        }
    }

    @Override
    protected void initData() {
        super.initData();
        mRoleType = new AtomicReference<>((RoleType) getIntent().getSerializableExtra("roletype"));
    }

    /**
     * 防止直播过程中锁屏
     */
    private void createPowerManager() {
        if (powerManager == null) {
            powerManager = (PowerManager) getSystemService(POWER_SERVICE);
            wakeLock = powerManager.newWakeLock(PowerManager.ACQUIRE_CAUSES_WAKEUP|PowerManager.SCREEN_DIM_WAKE_LOCK, TAG);
            wakeLock.setReferenceCounted(false);
        }
    }

    @Override
    protected void initView() {
        super.initView();
        mVideoMagr = new VideoViewMagr(this);
        mVideoMagr.initView((ViewGroup)findViewById(R.id.fl_largeview),(LinearLayout) findViewById(R.id.ll_smallviews));
        mVideoMagr.setClickLargeViewListener(this);
        onlineUserPanel.setListenr(new OnlineUserPanel.UserPanelItemClickListenr() {
            @Override
            public void onItemClick(UserInfo info) {
                if (mRoleType.get() == RoleType.HOST
                        && info instanceof OnlineUserInfo
                        && ((OnlineUserInfo) info).roleType == RoleType.VIEWER){
                    //TODO 目前MCU暂时最大支持到7人
                    if(mRtcRoom.getRemoteUsers().values().size() >= 6){
                        DialogUtils.showDialog(RoomInfoActivity.this,"最多只能支持7人同时连麦");
                    }else {
                        showOptionDialog((OnlineUserInfo) info);
                    }
                }
            }
        });
        if (mRoleType.get() == RoleType.HOST){
            bottomPanel.setOptionViewIsDisplay(false);
            tvOnlineNum.setVisibility(View.VISIBLE);
         }else {
            tvOnlineNum.setVisibility(View.GONE);
        }
        bottomPanel.setConfigChangeListener(new LayoutConfigDialog.ConfigChangeListener() {
            @Override
            public void onChange(LayoutConfigDialog.ConfigParams params) {
                if (mConfigHelper != null){
                    RongRTCMixConfig mcuConfig = mConfigHelper.onChange(params,mAnchorList);
                    if (params.model == RongRTCMixConfig.MixLayoutMode.CUSTOM) {
                        MixConfigInfoDialog.newInstance(mcuConfig)
                                .show(getFragmentManager(), "MixConfigInfoDialog");
                    }
                }
            }
        });
    }

    @Override
    protected void onClickHlvMember() {
        if (mRoleType.get() == RoleType.HOST)
            super.onClickHlvMember();
    }

    @Override
    public void onBackPressed() {
        if (bottomPanel.onBackAction()) {
            return;
        }
        mIsQuit = true;
        if (mRoleType.get() == RoleType.HOST ){
            DialogUtils.showDialog(this, "确认退出直播吗？", "确认", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    unPublish();
                    dialog.dismiss();
                }
            }, "取消", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    dialog.dismiss();
                }
            });
        }else {
            super.onBackPressed();
        }
    }

    @Override
    public boolean handleMessage(android.os.Message msg) {
        if (msg != null)
            LogUtils.d(TAG,"handleMessage: "+ CommonUtils.toJson(msg.obj));
        boolean flag = super.handleMessage(msg);
        switch (msg.what) {
            case ChatroomKit.MESSAGE_ARRIVED:
                Message msgObj = (Message) msg.obj;
                MessageContent msgContent = msgObj.getContent();
                if (msgContent instanceof LiveCmdMessage && TextUtils.equals(((LiveCmdMessage) msgContent).getRoomId(),roomId)){
                    LiveCmdMessage cmdMsg = (LiveCmdMessage) msgContent;
                    switch (cmdMsg.getCmdType()){
                        case INVITE:
                            showInviteDialog(msgObj.getSenderUserId());
                            break;
                        case DEMOTION:
                            mRoleType.set(RoleType.VIEWER);
                            quitRoom(true);
                            showDemotionDialog();
                            break;
                        case HANGUP:
                            OnlineUserInfo userInfo = onlineUserPanel.getUserInfo(msgObj.getTargetId());
                            if (userInfo != null) {
                                userInfo.roleType = RoleType.VIEWER;
                                onlineUserPanel.notifyDataSetChanged();
                                DialogUtils.showDialog(this, "拒绝了您的邀请上麦");
                            }
                            break;
                        case ACCEPT:
                            userInfo = onlineUserPanel.getUserInfo(msgObj.getTargetId());
                            if (userInfo != null) {
                                userInfo.roleType = RoleType.ANCHOR;
                                onlineUserPanel.notifyDataSetChanged();
                            }
                            Log.d(TAG, "接受上麦");
                            break;

                    }
                }else if (msgContent instanceof ChatroomSyncUserInfo){
                    mVideoMagr.updateUserInfos(((ChatroomSyncUserInfo) msgContent).getUserInfos());
                }
                break;
            case ChatroomKit.MESSAGE_SEND_ERROR:
                msgObj = (Message) msg.obj;
                msgContent = msgObj.getContent();
                if (msgContent instanceof LiveCmdMessage){
                    OnlineUserInfo userInfo = onlineUserPanel.getUserInfo(msgObj.getTargetId());
                    if (userInfo != null) {
                        userInfo.roleType = RoleType.VIEWER;
                        onlineUserPanel.notifyDataSetChanged();
                        showToast("发送邀请："+userInfo.getName()+"连麦失败!");
                    }else {
                        showToast("发送邀请：连麦失败!");
                    }
                }
                break;
                default:
                    break;

        }

        return flag;
    }

    private void showDemotionDialog() {
        DialogUtils.showDialog(this,"您被主播下麦");
    }

    /**
     * 显示受邀请Dialog
     */
    private void showInviteDialog(final String senderUserId) {
        LogUtils.d(TAG,"showInviteDialog");
        DialogUtils.showDialog(this, "邀请您上麦!","接受",
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        if (mRoleType.get() == RoleType.VIEWER) {
                            mRoleType.set(RoleType.ANCHOR);
                            LiveCmdMessage msgContent = new LiveCmdMessage(LiveCmdMessage.LiveCmd.ACCEPT, roomId);
                            Message msg = Message.obtain(senderUserId, Conversation.ConversationType.PRIVATE,msgContent);
                            ChatroomKit.sendMessage(msg);
                            unsubscribeLiveAVStream(new RongRTCResultUICallBack() {
                                @Override
                                public void onUiSuccess() {
                                    if (isFinish())
                                        return;
                                    joinRtcRoom();
                                }

                                @Override
                                public void onUiFailed(RTCErrorCode rtcErrorCode) {
                                    if (isFinish())
                                        return;
                                    showToast("取消订阅Live失败: "+rtcErrorCode.getValue());
                                }
                            });

                        }
                    }
                },"拒绝",
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        mRoleType.set(RoleType.VIEWER);
                        LiveCmdMessage msgContent = new LiveCmdMessage(LiveCmdMessage.LiveCmd.HANGUP, roomId);
                        Message msg = Message.obtain(senderUserId, Conversation.ConversationType.PRIVATE,msgContent);
                        ChatroomKit.sendMessage(msg);
                        dialog.dismiss();
                    }
                });
    }

    /**
     * 显示操作框
     * @param info
     */
    private void showOptionDialog(final OnlineUserInfo info) {
        DialogUtils.showDialog(this, info.roleType == RoleType.VIEWER ? "是否邀请他连麦？" : "取消与他连麦？",
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        LiveCmdMessage.LiveCmd  cmd;
//                        if (info.roleType == RoleType.VIEWER) {
                        info.roleType = RoleType.ANCHOR;
                        cmd = LiveCmdMessage.LiveCmd.INVITE;
                        onlineUserPanel.notifyDataSetChanged();
//                        }else {
                        //TODO 下麦操作信令暂时不可用
//                            info.roleType = RoleType.VIEWER;
//                            cmd = LiveCmdMessage.LiveCmd.DEMOTION;
//                            ChatroomKit.sendMessage(new InviteCallMessage(info.getUserId(), roomId));
//                        }
                        LiveCmdMessage msgContent = new LiveCmdMessage(cmd, roomId);
                        Message msg = Message.obtain(info.getUserId(), Conversation.ConversationType.PRIVATE,msgContent);
                        ChatroomKit.sendMessage(msg);
                    }
                },
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                });
    }

    /**
     * 订阅MCU流
     */
    private void subscribeLiveAVStream(){
        if (mInfo == null || TextUtils.isEmpty(mInfo.getMcuUrl())){
            showToast("数据异常无法观看直播");
            return;
        }
        write("subscribeLiveAVStream-T","RoomId|UserId|McuUrl",roomId,DataInterface.getUserId(),mInfo.getMcuUrl());
        RongRTCEngine.getInstance()
                .subscribeLiveAVStream(mInfo.getMcuUrl(), RongRTCRoomConfig.LiveType.AUDIO_VIDEO, new JoinLiveUICallBack() {

                    @Override
                    public void onUiSuccess() {
                        LogUtils.i(TAG,"订阅直播成功！");
                        RongRTCCapture.getInstance().setEnableSpeakerphone(true);
                    }

                    @Override
                    public void onUiFailed(RTCErrorCode rtcErrorCode) {
                        write("subscribeLiveAVStream-E", "RoomId|UserId|McuUrl|ErroCode", roomId, DataInterface.getUserId(), mInfo.getMcuUrl(), rtcErrorCode.getValue());
                        if (isFinish()) {
                            return;
                        }
                        closeLoading();
                        String msgStr = "观看直播失败:";
                        if (rtcErrorCode == RTCErrorCode.RongRTCCodeNoMatchedRoom) {
                            msgStr = "直播房间已不存在:";
                        }
                        StringBuilder msg = new StringBuilder(msgStr);
                        msg.append("\n")
                                .append("ErrorCode: ")
                                .append(rtcErrorCode.getValue())
                                .append("\n")
                                .append("ClientId: ")
                                .append(RongRTCEngine.getInstance().getClientId())
                                .append("\n")
                                .append("RoomId: ")
                                .append(roomId)
                                .append("\n")
                                .append("LocalUserId: ")
                                .append(DataInterface.getUserId())
                                .append("\n")
                                .append("MCU: ")
                                .append(mInfo.getMcuUrl());
                        DialogUtils.showDialog(RoomInfoActivity.this, msg.toString(), "确定", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                                finish();
                            }
                        });
                    }

                    @Override
                    public void onUiVideoStreamReceived(RongRTCLiveAVInputStream rongRTCLiveAVInputStream) {
                        write("subscribeLiveAVStream-R", "RoomId|UserId|McuUrl", roomId, DataInterface.getUserId(), mInfo.getMcuUrl());
                        if (isFinish()) {
                            return;
                        }
                        closeLoading();
                        joinChatRoom();
                        //创建RongRTCVideoView
                        RongRTCVideoView remoteView = RongRTCEngine.getInstance().createVideoView(RoomInfoActivity.this);
                        //将RongRTCVideoView添加到Layout父容器中
                        mVideoMagr.setLargeView(remoteView, new RongRTCUser(mInfo.getPubUserId(), null), "live");
                        //将RongRTCVideoView对象和RongRTCLiveAVInputStream对象绑定
                        rongRTCLiveAVInputStream.setRongRTCVideoView(remoteView);
                    }

                    @Override
                    public void onUiAudioStreamReceived(RongRTCLiveAVInputStream rongRTCLiveAVInputStream) {

                    }
                });

    }

    /**
     * 取消订阅直播流
     */
    private void unsubscribeLiveAVStream(final RongRTCResultUICallBack callBack){
        write("unsubscribeLiveAVStream-T","LocalUserId",DataInterface.getUserId());
        if (mInfo == null || TextUtils.isEmpty(mInfo.getMcuUrl())) {
            if (callBack != null) {
                write("unsubscribeLiveAVStream-R","LocalUserId",DataInterface.getUserId());
                callBack.onUiSuccess();
            }
            return;
        }
        RongRTCEngine.getInstance()
                .unsubscribeLiveAVStream(mInfo.getMcuUrl(), new RongRTCResultUICallBack() {
                    @Override
                    public void onUiSuccess() {
                        write("unsubscribeLiveAVStream-R","MCU",mInfo.getMcuUrl());
                        if (callBack != null)
                            callBack.onUiSuccess();
                    }

                    @Override
                    public void onUiFailed(RTCErrorCode rtcErrorCode) {
                        write("unsubscribeLiveAVStream-E","MCU",mInfo.getMcuUrl());
                        if (callBack != null)
                            callBack.onUiFailed(rtcErrorCode);
                    }
                });
    }


    /**
     * 加入Rtc房间
     */
    public void joinRtcRoom(){
        if (mRoleType.get() == RoleType.VIEWER)
            return;
        if (!checkPermissions())
            return;
        write("joinRtcRoom-T","RoomId|UserId",roomId,DataInterface.getUserId());
        RongRTCRoomConfig config = new  RongRTCRoomConfig.Builder()
                .setRoomType(RongRTCRoomConfig.RoomType.LIVE) //设置房间类型为直播类型
                .build();
        RongRTCConfig.Builder builder = new RongRTCConfig.Builder();
        builder.setVideoProfile(RongRTCConfig.RongRTCVideoProfile.RONGRTC_VIDEO_PROFILE_480P_15f_1);
        builder.enableTinyStream(false);


        mVideoMagr.resetView();
        RongRTCEngine.getInstance()
                .joinRoom(roomId,config, new JoinRoomUICallBack() {
                    @Override
                    protected void onUiSuccess(RongRTCRoom rongRTCRoom) {
                        write("joinRtcRoom-R","RoomId|UserId",roomId,DataInterface.getUserId());
                        if (isFinish())
                            return;
                        onJoinRtcRoom(rongRTCRoom);
                        closeLoading();
                    }

                    @Override
                    protected void onUiFailed(RTCErrorCode rtcErrorCode) {
                        write("joinRtcRoom-E","RoomId|UserId|ErrorCode",roomId,DataInterface.getUserId(),rtcErrorCode.getValue());
                        StringBuilder msg = new StringBuilder("创建直播间失败: ");
                        msg.append("\n")
                                .append("ErrorCode: ")
                                .append(rtcErrorCode.getValue())
                                .append("\n")
                                .append("ClientId: ")
                                .append(RongRTCEngine.getInstance().getClientId())
                                .append("\n")
                                .append("RoomId: ")
                                .append(roomId)
                                .append("\n")
                                .append("LocalUserId: ")
                                .append(DataInterface.getUserId());
                        DialogUtils.showDialog(RoomInfoActivity.this, msg.toString(), "确定", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                                finish();
                            }
                        });
                    }
                });

    }

    /**
     * 加入Rtc房间成功后发布、订阅资源
     */
    private void onJoinRtcRoom(RongRTCRoom rongRTCRoom) {
        if (mRoleType.get() == RoleType.VIEWER) {
            quitRoom(false);
            subscribeLiveAVStream();
            return;
        }
        mRtcRoom = rongRTCRoom;
        RongRTCVideoView localSurface = RongRTCEngine.getInstance().createVideoView(getApplicationContext());
        mVideoMagr.setLargeView(localSurface,mRtcRoom.getLocalUser(),CenterManager.RONG_TAG);

        rongRTCRoom.registerEventsListener(this);
//        rongRTCRoom.registerStatusReportListener(this);
        rongRTCRoom.registerEglEventsListener(this);
        RongRTCCapture.getInstance().setRongRTCVideoView(localSurface);//设置本地view
        RongRTCCapture.getInstance().muteLocalVideo(false); //是否关闭摄像头

        RongRTCCapture.getInstance().setLocalVideoFrameListener(true,this);
        RongRTCCapture.getInstance().setEnableSpeakerphone(true);
        RongRTCCapture.getInstance().startCameraCapture();
        publishResource();//发布资源
        addAllVideoView();  //添加远端View
        for (final RongRTCRemoteUser remoteUser : rongRTCRoom.getRemoteUsers().values()) {
            List<RongRTCAVInputStream> remoteAVStreams = remoteUser.getRemoteAVStreams();
            if (remoteAVStreams == null || remoteAVStreams.isEmpty()) {
                FwLog.write(FwLog.E,FwLog.RTC,"remoteAVStreams_Empty","RoomId|LocalUserId|remoteUser",roomId,DataInterface.getUserId(),remoteUser.getUserId());
                continue;
            }
            //默认订阅大流
            for (RongRTCAVInputStream stream : remoteAVStreams) {
                if (stream.getMediaType() == MediaType.VIDEO) {
                    stream.setSimulcast("1");
                }
            }
            write("subscribeAVStream-T","RoomId|LocalUserId|remoteUser",roomId,DataInterface.getUserId(),remoteUser.getUserId());
            remoteUser.subscribeAVStream(remoteAVStreams, new RongRTCResultUICallBack() {
                @Override
                public void onUiSuccess() {
                    write("subscribeAVStream-R","RoomId|LocalUserId|remoteUser",roomId,DataInterface.getUserId(),remoteUser.getUserId());
                }

                @Override
                public void onUiFailed(RTCErrorCode errorCode) {
                    write("subscribeAVStream-E","RoomId|LocalUserId|remoteUser|erroCode",roomId,DataInterface.getUserId(),remoteUser.getUserId(),errorCode.getValue());
                    StringBuilder msg = new StringBuilder("订阅资源失败");
                    msg.append("\n")
                            .append("ErrorCode: ")
                            .append(errorCode.getValue())
                            .append("\n")
                            .append("ClientId: ")
                            .append(RongRTCEngine.getInstance().getClientId())
                            .append("\n")
                            .append("RoomId: ")
                            .append(roomId)
                            .append("\n")
                            .append("LocalUserId: ")
                            .append(DataInterface.getUserId())
                            .append("\n")
                            .append("RemoteUserId: ")
                            .append(remoteUser.getUserId());
                    DialogUtils.showDialog(RoomInfoActivity.this, msg.toString(), "确定", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            dialog.dismiss();
//                            finish();
                        }
                    });
                }
            });
        }

    }

    private void addAllVideoView() {
        Map<String, RongRTCRemoteUser> map = mRtcRoom.getRemoteUsers();
        if (map != null) {
            for (RongRTCRemoteUser remoteUser : map.values()) {
                addNewRemoteView(remoteUser);//准备view
            }
        }
    }

    /**
     * 添加远端音视频流View
     * @param remoteUser
     */
    private void addNewRemoteView(RongRTCRemoteUser remoteUser) {
        List<RongRTCAVInputStream> remoteAVStreams = remoteUser.getRemoteAVStreams();
        ArrayList<RongRTCAVInputStream> streams = new ArrayList<>();
        RongRTCAVInputStream audioStream = null;
        for (RongRTCAVInputStream inputStream : remoteAVStreams) {
            if (inputStream.getMediaType() == MediaType.VIDEO) {
                streams.add(inputStream);
            }else if (inputStream.getMediaType() == MediaType.AUDIO){
                audioStream = inputStream;
            }
        }
        if (streams.isEmpty() && audioStream != null){
            streams.add(audioStream);
        }
        for (RongRTCAVInputStream stream : streams) {
            RongRTCVideoView remoteView = RongRTCEngine.getInstance().createVideoView(this);
            mVideoMagr.addSmallView(remoteView, remoteUser, stream.getTag());
            stream.setRongRTCVideoView(remoteView);
        }
        mVideoMagr.updateUserInfos(getAnchorInfos());

    }

    /**
     * 发布音视频资源
     */
    private void publishResource() {
        write("publishDefaultLiveAVStream-T","RoomId|LocalUserId",roomId,DataInterface.getUserId());
        mRtcRoom.getLocalUser().publishDefaultLiveAVStream(new RongRTCDataResultCallBack<RongRTCLiveInfo>() {
            @Override
            public void onSuccess(final RongRTCLiveInfo rongRTCLiveRoom) {
                write("publishDefaultLiveAVStream-R","RoomId|LocalUserId",roomId,DataInterface.getUserId());
                if (isFinish())
                    return;
                onPublishLiveSuccess(rongRTCLiveRoom);
            }

            @Override
            public void onFailed(final RTCErrorCode rtcErrorCode) {
                write("publishDefaultLiveAVStream-E","RoomId|LocalUserId|ErrorCode",roomId,DataInterface.getUserId(),rtcErrorCode.getValue());
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (isFinish())
                            return;
                        closeLoading();
                        StringBuilder msg = new StringBuilder("资源发布失败: ");
                        msg.append("\n")
                                .append("ErrorCode: ")
                                .append(rtcErrorCode.getValue())
                                .append("\n")
                                .append("ClientId: ")
                                .append(RongRTCEngine.getInstance().getClientId())
                                .append("\n")
                                .append("RoomId: ")
                                .append(roomId)
                                .append("\n")
                                .append("LocalUserId: ")
                                .append(DataInterface.getUserId());
                        DialogUtils.showDialog(RoomInfoActivity.this, msg.toString(), "确定", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                                finish();
                            }
                        });
                    }
                });
            }
        });
    }

    /**
     * 发布音视频资源成功
     * @param rongRTCLiveRoom
     */
    private void onPublishLiveSuccess(RongRTCLiveInfo rongRTCLiveRoom) {
        if (!TextUtils.equals(roomId,rongRTCLiveRoom.getRoomId()) || isViewer()) {
            showToast("发布资源失败：数据异常");
            return;
        }
        if (mRoleType.get() == RoleType.HOST) {
            mConfigHelper = new MixConfigHelper(rongRTCLiveRoom,mRtcRoom);
            mConfigHelper.setCallback(new RongRTCResultUICallBack() {
                @Override
                public void onUiSuccess() {
                }

                @Override
                public void onUiFailed(RTCErrorCode rtcErrorCode) {
                    DialogUtils.showDialog(RoomInfoActivity.this,"混流布局设置失败");
                }
            });
            mInfo.setMcuUrl(rongRTCLiveRoom.getLiveUrl());
            mConfigHelper.onChange(new LayoutConfigDialog.ConfigParams(RongRTCMixConfig.MixLayoutMode.SUSPENSION),mAnchorList);
            onSubmitRoomInfo(mInfo);
        }

        bottomPanel.setVideoFrameSize(RongRTCLocalSourceManager.getInstance().getRongRTCConfig().getVideoWidth(),RongRTCLocalSourceManager.getInstance().getRongRTCConfig().getVideoHeight());

    }

    /**
     * 向APPServer提交Live信息更新直播列表
     * @param chatroomInfo
     */
    private void onSubmitRoomInfo(ChatroomInfo chatroomInfo) {
        Request.Builder request = new Request.Builder();
        request.url(DataInterface.APPSERVER+DataInterface.PUBLISH);
        request.method(RequestMethod.POST);
        request.body(new Gson().toJson(chatroomInfo));
        HttpClient.getDefault().request(request.build(), new HttpClient.ResultCallback() {
            @Override
            public void onResponse(final String s) {
                LogUtils.i("DemoServer","onSubmitRoomInfo result = "+s);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (isFinish())
                            return;
                        closeLoading();
                        BaseResponse res = new Gson().fromJson(s, BaseResponse.class);
                        if (res.isSuccess()) {
                            joinChatRoom();
                        }else {
                            DialogUtils.showDialog(RoomInfoActivity.this, "创建直播间失败:" + res.desc, "确定", new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                    dialog.dismiss();
                                    finish();
                                }
                            });
                        }
                    }
                });
            }

            @Override
            public void onFailure(final int i) {
                LogUtils.e("DemoServer","onSubmitRoomInfo failure = "+i);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        closeLoading();
                        showToast("创建直播间失败: "+i);
                    }
                });

            }

            @Override
            public void onError(IOException e) {
                LogUtils.e("DemoServer","onSubmitRoomInfo error = "+e.getMessage());
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (isFinish())
                            return;
                        closeLoading();
                        showToast("网络不可用，请检查网络连接");
                    }
                });
            }
        });
    }

    /**
     * 退出房间
     * @param resubscribe
     */
    private void quitRoom(final boolean resubscribe){
        RongRTCEngine.getInstance()
                .quitRoom(roomId, new RongRTCResultUICallBack() {
                    @Override
                    public void onUiSuccess() {
                        if (!isFinish())
                            return;
//                        if (mRoleType.get() == RoleType.ANCHOR){    //升级为主播
//                            joinRtcRoom();
//                        }else
                        if (resubscribe){ //降级为观众
                            subscribeLiveAVStream();
                        }
                    }

                    @Override
                    public void onUiFailed(RTCErrorCode rtcErrorCode) {
                        FinLog.log(TAG,"quitRoom Faild: "+rtcErrorCode);
                    }
                });
    }

    /**
     * 是否为观众
     * @return
     */
    private boolean isViewer(){
        return mRoleType.get() == RoleType.VIEWER;
    }

    @Override
    protected void onDestroy() {
        LogUtils.d(TAG,"onDestroy");
        super.onDestroy();
        if (isViewer()){
            unsubscribeLiveAVStream(null);
        }else {
            quitRoom(false);
        }
        if (mRtcRoom != null) {
            mRtcRoom.release();
            mRtcRoom = null;
        }
        CenterManager.getInstance()
                .releaseAll();
        AudioManager audioManager = (AudioManager) getSystemService(
                Context.AUDIO_SERVICE);
        audioManager.setMode(AudioManager.MODE_NORMAL);
        if (mConfigHelper != null){
            mConfigHelper.release();
        }
    }

    /**
     * 有远端用户发布了音视频资源
     * @param rongRTCRemoteUser
     * @param list
     */
    @Override
    public void onRemoteUserPublishResource(final RongRTCRemoteUser rongRTCRemoteUser, List<RongRTCAVInputStream> list) {
        FinLog.d(TAG, "onPublishResource remoteUser: " + rongRTCRemoteUser);
        if (rongRTCRemoteUser == null) return;
        write("subscribeAVStream-T","RoomId|LocalUserId|remoteUser",roomId,DataInterface.getUserId(),rongRTCRemoteUser.getUserId());
        addNewRemoteView(rongRTCRemoteUser);
        rongRTCRemoteUser.subscribeAVStream(rongRTCRemoteUser.getRemoteAVStreams(), new RongRTCResultUICallBack() {
            @Override
            public void onUiSuccess() {
                write("subscribeAVStream-R","RoomId|LocalUserId|remoteUser",roomId,DataInterface.getUserId(),rongRTCRemoteUser.getUserId());
            }

            @Override
            public void onUiFailed(RTCErrorCode errorCode) {
                write("subscribeAVStream-E","RoomId|LocalUserId|remoteUserId",roomId,DataInterface.getUserId(),rongRTCRemoteUser.getUserId());
                StringBuilder msg = new StringBuilder("订阅资源失败: ");
                msg.append("\n")
                        .append("ErrorCode: ")
                        .append(errorCode)
                        .append("\n")
                        .append("ClientId: ")
                        .append(RongRTCEngine.getInstance().getClientId())
                        .append("\n")
                        .append("RoomId: ")
                        .append(roomId)
                        .append("\n")
                        .append("LocalUserId: ")
                        .append(DataInterface.getUserId())
                        .append("\n")
                        .append("RemoteUserId: ")
                        .append(rongRTCRemoteUser.getUserId());
                DialogUtils.showDialog(RoomInfoActivity.this, msg.toString(), "确定", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                        finish();
                    }
                });
            }
        });

        updateAnchorList(rongRTCRemoteUser.getUserId(),false);
        if (mConfigHelper != null){
            mConfigHelper.onUserChange(mAnchorList);
        }
    }

    @Override
    public void onRemoteUserAudioStreamMute(RongRTCRemoteUser rongRTCRemoteUser, RongRTCAVInputStream rongRTCAVInputStream, boolean b) {

    }

    @Override
    public void onRemoteUserVideoStreamEnabled(RongRTCRemoteUser rongRTCRemoteUser, RongRTCAVInputStream rongRTCAVInputStream, boolean b) {

    }

    @Override
    public void onRemoteUserUnpublishResource(RongRTCRemoteUser rongRTCRemoteUser, List<RongRTCAVInputStream> list) {

    }

    /**
     * 有用户加入了房间
     * @param rongRTCRemoteUser
     */
    @Override
    public void onUserJoined(RongRTCRemoteUser rongRTCRemoteUser) {
        if (mRoleType.get() != RoleType.HOST)
            return;
        ArrayList<UserInfo> userInfos = getAnchorInfos();
        if (userInfos == null) return;
        ChatroomKit.sendMessage(new ChatroomSyncUserInfo(userInfos));
    }

    private ArrayList<UserInfo> getAnchorInfos() {
        List<OnlineUserInfo> allUsers = onlineUserPanel.getAllUsers();
        if (allUsers == null)
            return null;
        ArrayList<UserInfo> userInfos = new ArrayList<>();
        for (OnlineUserInfo user : allUsers) {
            if (user.roleType != RoleType.VIEWER){
                userInfos.add(user);
            }
        }
        userInfos.add(ChatroomKit.getCurrentUser());
        return userInfos;
    }

    /**
     * 有用户离开
     * @param rongRTCRemoteUser
     */
    @Override
    public void onUserLeft(RongRTCRemoteUser rongRTCRemoteUser) {
        if (!isFinish()){
            mVideoMagr.removeVideoView(rongRTCRemoteUser.getUserId(),null);
        }
        updateAnchorList(rongRTCRemoteUser.getUserId(),true);
        if (mConfigHelper != null){
            mConfigHelper.onUserChange(mAnchorList);
        }
    }

    private void updateAnchorList(String uid,boolean isDel){
        String tmp = "";
        Iterator<String> iterator = mAnchorList.iterator();
        while (iterator.hasNext()) {
            tmp = iterator.next();
            if (TextUtils.equals(uid,tmp)){
                if (isDel){
                    mAnchorList.remove(tmp);
                }
                break;
            }
        }

        if (!isDel && !TextUtils.equals(uid,tmp)){
            mAnchorList.add(uid);
        }
    }

    @Override
    public void onUserOffline(RongRTCRemoteUser rongRTCRemoteUser) {
        if (!isFinish()){
            mVideoMagr.removeVideoView(rongRTCRemoteUser.getUserId(),null);
        }
        updateAnchorList(rongRTCRemoteUser.getUserId(),true);
        if (mConfigHelper != null){
            mConfigHelper.onUserChange(mAnchorList);
        }
    }

    @Override
    public void onVideoTrackAdd(String s, String s1) {

    }

    @Override
    public void onFirstFrameDraw(String s, String s1) {

    }

    /**
     * 网络异常导致离开房间
     */
    @Override
    public void onLeaveRoom() {
        Log.e(TAG, "onLeaveRoom: "+roomId);
        if (isFinish())
            return;
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("网络连接异常，退出房间！").setPositiveButton("确定", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                finish();
            }
        }).show();
    }

    @Override
    public void onReceiveMessage(Message message) {

    }

    @Override
    public void onKickedByServer() {

    }

    @Override
    public void onCreateEglFailed(String s, String s1, Exception e) {
        FinLog.e(TAG,"onCreateEglFailed:"+e.getMessage());
    }

    @Override
    public RTCVideoFrame processVideoFrame(RTCVideoFrame rtcVideoFrame) {
        return null;
    }

    private boolean checkPermissions() {
        unGrantedPermissions = new ArrayList();
        for (String permission : MANDATORY_PERMISSIONS) {
            if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                unGrantedPermissions.add(permission);
            }
        }
        if (unGrantedPermissions.isEmpty()) {//已经获得了所有权限，开始加入聊天室
            return true;
        } else {//部分权限未获得，重新请求获取权限
            String[] array = new String[unGrantedPermissions.size()];
            ActivityCompat.requestPermissions(this, unGrantedPermissions.toArray(array), 0);
            return false;
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (mRtcRoom != null && !isViewer()){
            RongRTCCapture.getInstance().stopCameraCapture();
            if (!mIsQuit)
                startService(new Intent(this, RTCNotificationService.class));
        }
        if (wakeLock != null && wakeLock.isHeld()) {
            wakeLock.release();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        stopService(new Intent(this, RTCNotificationService.class));
        if (mRtcRoom != null && !isViewer()){
            RongRTCCapture.getInstance().startCameraCapture();
        }
        if (wakeLock != null)
            wakeLock.acquire();
        AudioManager audioManager = (AudioManager) getSystemService(
                Context.AUDIO_SERVICE);
        audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        unGrantedPermissions.clear();
        for (int i = 0; i < permissions.length; i++) {
            if (grantResults[i] == PackageManager.PERMISSION_DENIED)
                unGrantedPermissions.add(permissions[i]);
        }
        if (!unGrantedPermissions.isEmpty()) {
            for (String permission : unGrantedPermissions) {
                if (!ActivityCompat.shouldShowRequestPermissionRationale(this, permission)) {
                    Toast.makeText(this, "权限:已被禁止，请手动开启！", Toast.LENGTH_SHORT).show();
                    finish();
                } else ActivityCompat.requestPermissions(this, new String[]{permission}, 0);
            }
        } else {
            if (isViewer())
                subscribeLiveAVStream();
            else
                joinRtcRoom();
        }
    }

    /**
     * 通知APPServer，已结束直播，删除直播入口
     */
    public void unPublish(){
        if (mRoleType.get() != RoleType.HOST)
            return;
        showLoading();
        JSONObject obj = new JSONObject();
        try {
            obj.putOpt("roomId",roomId);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        Request.Builder request = new Request.Builder();
        request.url(DataInterface.APPSERVER+DataInterface.UNPUBLISH);
        request.method(RequestMethod.POST);
        request.body(obj.toString());
        HttpClient.getDefault().request(request.build(), new HttpClient.ResultCallback() {
            @Override
            public void onResponse(final String s) {
                LogUtils.i("DemoServer", "unpublish result: "+s);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (isFinish())
                            return;
                        closeLoading();
                        finish();
                    }
                });
            }

            @Override
            public void onFailure(final int i) {
                LogUtils.e("DemoServer","ubpubilsh failure = "+i);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        closeLoading();
                        showToast("退出房间失败: "+i);
                    }
                });

            }

            @Override
            public void onError(IOException e) {
                LogUtils.e("DemoServer","ubpubilsh error = "+e.getMessage());
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        closeLoading();
                        showToast("网络不可用，请检查网络连接");
                    }
                });
            }
        });
    }

    private static void write(String tag,String keys, Object... values){
        FwLog.write(FwLog.I,FwLog.RTC,"SL-"+tag,keys,values);
    }

}
