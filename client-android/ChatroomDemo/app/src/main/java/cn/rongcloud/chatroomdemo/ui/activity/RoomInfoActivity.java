package cn.rongcloud.chatroomdemo.ui.activity;

import android.Manifest;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.media.AudioManager;
import android.os.Bundle;
import android.os.PowerManager;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.AppCompatCheckBox;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.LinearLayout;
import android.widget.Toast;

import cn.rongcloud.chatroomdemo.ui.panel.SetCDNPushDialog;
import cn.rongcloud.chatroomdemo.utils.HeadsetReceiver;
import cn.rongcloud.chatroomdemo.utils.HeadsetReceiver.HeadsetListener;
import cn.rongcloud.rtc.api.RCRTCConfig;
import cn.rongcloud.rtc.api.RCRTCEngine;
import cn.rongcloud.rtc.api.RCRTCLocalUser;
import cn.rongcloud.rtc.api.RCRTCMixConfig;
import cn.rongcloud.rtc.api.RCRTCRemoteUser;
import cn.rongcloud.rtc.api.RCRTCRoom;
import cn.rongcloud.rtc.api.callback.IRCRTCOnStreamSendListener;
import cn.rongcloud.rtc.api.callback.IRCRTCResultCallback;
import cn.rongcloud.rtc.api.callback.IRCRTCResultDataCallback;
import cn.rongcloud.rtc.api.callback.IRCRTCRoomEventsListener;
import cn.rongcloud.rtc.api.stream.RCRTCCameraOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCFileVideoOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCInputStream;
import cn.rongcloud.rtc.api.stream.RCRTCLiveInfo;
import cn.rongcloud.rtc.api.stream.RCRTCVideoInputStream;
import cn.rongcloud.rtc.api.stream.RCRTCVideoOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCVideoStreamConfig;
import cn.rongcloud.rtc.api.stream.RCRTCVideoStreamConfig.Builder;
import cn.rongcloud.rtc.api.stream.RCRTCVideoView;
import cn.rongcloud.rtc.base.RCRTCMediaType;
import cn.rongcloud.rtc.base.RCRTCParamsType.RCRTCVideoFps;
import cn.rongcloud.rtc.base.RCRTCParamsType.RCRTCVideoResolution;
import cn.rongcloud.rtc.base.RCRTCRoomType;
import cn.rongcloud.rtc.base.RCRTCStream;
import cn.rongcloud.rtc.base.RCRTCStreamType;
import cn.rongcloud.rtc.base.RTCErrorCode;
import cn.rongcloud.rtc.custom.OnSendListener;
import cn.rongcloud.rtc.stream.local.RongRTCAVOutputStream;
import com.google.gson.Gson;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
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
import cn.rongcloud.rtc.utils.FinLog;
import cn.rongcloud.rtc.media.http.HttpClient;
import cn.rongcloud.rtc.media.http.Request;
import cn.rongcloud.rtc.media.http.RequestMethod;
import io.rong.common.fwlog.FwLog;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.UserInfo;

/**
 * 直播页面
 * Created by wangw on 2019-08-21.
 */
public class RoomInfoActivity extends LiveShowActivity {

    private static final String TAG = "RoomInfoActivity";

    /**
     * @param context
     * @param info    房间信息
     * @param type    房间角色类型
     */
    public static void jumpTo(Context context, ChatroomInfo info, RoleType type) {
        if (info == null) {
            Toast.makeText(context, "房间信息不能为空", Toast.LENGTH_LONG).show();
            return;
        }
        Intent intent = new Intent(context, RoomInfoActivity.class);
        intent.putExtra("roominfo", info);
        intent.putExtra("roletype", type);
        context.startActivity(intent);

    }

    private HeadsetReceiver mReceiver;
    private RCRTCRoom mRtcRoom;
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
    private boolean mIsQuit = false;
    private AppCompatCheckBox mMicView;
    private AppCompatCheckBox mCameraView;
    private AppCompatCheckBox mSpeakerView;
    private AppCompatCheckBox mCustomView;
    private RCRTCLiveInfo mLiveInfo;
    private SetCDNPushDialog mSetCDNPushDialog;
    private RCRTCFileVideoOutputStream mFileVideoOutputStream;
    private View mMenuView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getIntent().getParcelableExtra("roominfo") == null) {
            DialogUtils.showDialog(this, "数据异常");
            finish();
            return;
        }
        showLoading();
        onInitRTC();
        createPowerManager();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        if (danmuContainerView != null)
            danmuContainerView.requestLayout();
    }

    protected void onInitRTC() {
        initData();
        AudioManager am = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
        mReceiver = new HeadsetReceiver(am);
        initView();
        mReceiver.setListener(new HeadsetListener() {
            @Override
            public void onHeadsetStateChange(boolean headsetEnable) {
                if (!isViewer() && mSpeakerView != null) {
                    mSpeakerView.setEnabled(!headsetEnable);
                }
            }
        });
        mReceiver.registerReceiver(this);
        RCRTCConfig config = RCRTCConfig.Builder.create()
            .build();
        RCRTCEngine.getInstance().init(this,config);
        if (isViewer()) {
            //普通观众
            LogUtils.d(TAG, "观众身份加入：开始订阅资源");
            subscribeLiveAVStream();
        } else if (mRoleType.get() == RoleType.HOST) {
            //房主
            LogUtils.d(TAG, "直播身份加入：开始join room");
            joinRtcRoom();
        } else {
            LogUtils.e(TAG, "onInit: 参数异常");
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
            wakeLock = powerManager
                .newWakeLock(PowerManager.ACQUIRE_CAUSES_WAKEUP | PowerManager.SCREEN_DIM_WAKE_LOCK, TAG);
            wakeLock.setReferenceCounted(false);
        }
    }

    @Override
    protected void initView() {
        super.initView();
        mVideoMagr = new VideoViewMagr(this);
        mVideoMagr
            .initView((ViewGroup) findViewById(R.id.fl_largeview), (LinearLayout) findViewById(R.id.ll_smallviews));
        mVideoMagr.setClickLargeViewListener(this);
        onlineUserPanel.setListenr(new OnlineUserPanel.UserPanelItemClickListenr() {
            @Override
            public void onItemClick(UserInfo info) {
                if (mRoleType.get() == RoleType.HOST
                    && info instanceof OnlineUserInfo
                    && ((OnlineUserInfo) info).roleType == RoleType.VIEWER) {
                    //TODO 目前MCU暂时最大支持到7人
//                    if(mRtcRoom.getRemoteUsers().values().size() >= 6){
//                        DialogUtils.showDialog(RoomInfoActivity.this,"最多只能支持7人同时连麦");
//                    }else {
                    showOptionDialog((OnlineUserInfo) info);
//                    }
                }
            }
        });
        if (mRoleType.get() == RoleType.HOST) {
            bottomPanel.setOptionViewIsDisplay(false);
            tvOnlineNum.setVisibility(View.VISIBLE);
        } else {
            tvOnlineNum.setVisibility(View.GONE);
        }
        bottomPanel.setConfigChangeListener(new LayoutConfigDialog.ConfigChangeListener() {
            @Override
            public void onChange(LayoutConfigDialog.ConfigParams params) {
                if (mConfigHelper != null) {
                    RCRTCMixConfig mcuConfig = mConfigHelper.changeMixConfig(params);
                    if (params.model == RCRTCMixConfig.MixLayoutMode.CUSTOM) {
                        MixConfigInfoDialog.newInstance(mcuConfig)
                            .show(getFragmentManager(), "MixConfigInfoDialog");
                    }
                }
            }
        });

        mMenuView = findViewById(R.id.ll_menu);
        mCameraView = findViewById(R.id.menu_switch_camera);
        mMicView = findViewById(R.id.menu_mic);
        mSpeakerView = findViewById(R.id.menu_speaker);
        mCameraView.setOnClickListener(this);
        mSpeakerView.setOnClickListener(this);
        mMicView.setOnClickListener(this);
        mSpeakerView.setEnabled(!(mReceiver.isWiredHeadsetOn() || mReceiver.hasBluetoothA2dpConnected()));
        mCustomView = findViewById(R.id.menu_custom_stream);
        mCustomView.setOnClickListener(this);
    }

    private void resetView() {
        boolean isDebug = (getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;

        mSpeakerView.setVisibility(isDebug || !isViewer() ? View.VISIBLE : View.GONE);
        mMenuView.setVisibility(isViewer() ? View.GONE : View.VISIBLE);

    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.menu_mic:
                boolean isMute = !mMicView.isSelected();
                RCRTCEngine.getInstance().getDefaultAudioStream().setMicrophoneDisable(isMute);
                mMicView.setSelected(isMute);
                showToast(isMute ? "已静音" : "已解除静音");
                break;
            case R.id.menu_speaker:
                boolean enable = mSpeakerView.isSelected();
                RCRTCEngine.getInstance().enableSpeaker(enable);
                mSpeakerView.setSelected(!enable);
                showToast(enable ? "已开启扬声器模式" : "已开启听筒模式");
                break;
            case R.id.menu_switch_camera:
                RCRTCEngine.getInstance().getDefaultVideoStream().switchCamera(null);
                break;
            case R.id.menu_custom_stream:
                if (mCustomView.isSelected()) {
                    unPublishCustomStream(mCustomView);
                } else {
                    publishCustomStream("file:///android_asset/video_2.mp4", mCustomView);
                }
                break;
            default:
                super.onClick(v);
                break;
        }

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
        if (mRoleType.get() == RoleType.HOST) {
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
        } else {
            super.onBackPressed();
        }
    }

    @Override
    public boolean handleMessage(android.os.Message msg) {
        if (msg != null)
            LogUtils.d(TAG, "handleMessage: " + CommonUtils.toJson(msg.obj));
        boolean flag = super.handleMessage(msg);
        switch (msg.what) {
            case ChatroomKit.MESSAGE_ARRIVED:
                Message msgObj = (Message) msg.obj;
                MessageContent msgContent = msgObj.getContent();
                if (msgContent instanceof LiveCmdMessage && TextUtils
                    .equals(((LiveCmdMessage) msgContent).getRoomId(), roomId)) {
                    LiveCmdMessage cmdMsg = (LiveCmdMessage) msgContent;
                    switch (cmdMsg.getCmdType()) {
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
                } else if (msgContent instanceof ChatroomSyncUserInfo) {
                    mVideoMagr.updateUserInfos(((ChatroomSyncUserInfo) msgContent).getUserInfos());
                }
                break;
            case ChatroomKit.MESSAGE_SEND_ERROR:
                msgObj = (Message) msg.obj;
                msgContent = msgObj.getContent();
                if (msgContent instanceof LiveCmdMessage) {
                    OnlineUserInfo userInfo = onlineUserPanel.getUserInfo(msgObj.getTargetId());
                    if (userInfo != null) {
                        userInfo.roleType = RoleType.VIEWER;
                        onlineUserPanel.notifyDataSetChanged();
                        showToast("发送邀请：" + userInfo.getName() + "连麦失败!");
                    } else {
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
        DialogUtils.showDialog(this, "您被主播下麦");
    }

    /**
     * 显示受邀请Dialog
     */
    private void showInviteDialog(final String senderUserId) {
        LogUtils.d(TAG, "showInviteDialog");
        DialogUtils.showDialog(this, "邀请您上麦!", "接受",
            new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    if (mRoleType.get() == RoleType.VIEWER) {
                        mRoleType.set(RoleType.ANCHOR);
                        LiveCmdMessage msgContent = new LiveCmdMessage(LiveCmdMessage.LiveCmd.ACCEPT, roomId);
                        Message msg = Message.obtain(senderUserId, Conversation.ConversationType.PRIVATE, msgContent);
                        ChatroomKit.sendMessage(msg);
                        unsubscribeLiveAVStream(new IRCRTCResultCallback() {
                            @Override
                            public void onSuccess() {
                                postUIThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        joinRtcRoom();
                                    }
                                });
                            }

                            @Override
                            public void onFailed(final RTCErrorCode rtcErrorCode) {
                                postUIThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        showToast("取消订阅Live失败: " + rtcErrorCode.getValue());
                                    }
                                });
                            }
                        });

                    }
                }
            }, "拒绝",
            new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    mRoleType.set(RoleType.VIEWER);
                    LiveCmdMessage msgContent = new LiveCmdMessage(LiveCmdMessage.LiveCmd.HANGUP, roomId);
                    Message msg = Message.obtain(senderUserId, Conversation.ConversationType.PRIVATE, msgContent);
                    ChatroomKit.sendMessage(msg);
                    dialog.dismiss();
                }
            });
    }

    /**
     * 显示操作框
     *
     * @param info
     */
    private void showOptionDialog(final OnlineUserInfo info) {
        DialogUtils.showDialog(this, info.roleType == RoleType.VIEWER ? "是否邀请他连麦？" : "取消与他连麦？",
            new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    LiveCmdMessage.LiveCmd cmd;
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
                    Message msg = Message.obtain(info.getUserId(), Conversation.ConversationType.PRIVATE, msgContent);
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
    private void subscribeLiveAVStream() {
        if (mInfo == null || TextUtils.isEmpty(mInfo.getMcuUrl())) {
            showToast("数据异常无法观看直播");
            return;
        }
        write("subscribeLiveAVStream-T", "RoomId|UserId|McuUrl", roomId, DataInterface.getUserId(), mInfo.getMcuUrl());
        resetView();
        RCRTCEngine.getInstance()
            .subscribeLiveStream(mInfo.getMcuUrl(), RCRTCRoomType.LIVE_AUDIO_VIDEO,
                new IRCRTCResultDataCallback<List<RCRTCInputStream>>() {

                    @Override
                    public void onSuccess(final List<RCRTCInputStream> streams) {
                        LogUtils.i(TAG, "订阅直播成功！");
                        write("subscribeLiveAVStream-R", "RoomId|UserId|McuUrl", roomId, DataInterface.getUserId(),
                            mInfo.getMcuUrl());
                        postUIThread(new Runnable() {
                            @Override
                            public void run() {
                                closeLoading();
                                joinChatRoom();
                                for (RCRTCInputStream stream : streams) {
                                    if (stream instanceof RCRTCVideoInputStream) {
                                        //创建RongRTCVideoView
                                        RCRTCVideoView remoteView = new RCRTCVideoView(RoomInfoActivity.this);
                                        //将RongRTCVideoView添加到Layout父容器中
                                        mVideoMagr.setLargeView(remoteView, mInfo.getPubUserId(), "live");
                                        //将RongRTCVideoView对象和RongRTCLiveAVInputStream对象绑定
                                        ((RCRTCVideoInputStream) stream).setVideoView(remoteView);
                                    }
                                }
                            }
                        });
                    }

                    @Override
                    public void onFailed(RTCErrorCode rtcErrorCode) {
                        write("subscribeLiveAVStream-E", "RoomId|UserId|McuUrl|ErroCode", roomId,
                            DataInterface.getUserId(), mInfo.getMcuUrl(), rtcErrorCode.getValue());
                        if (isFinish() || rtcErrorCode == RTCErrorCode.RongRTCCodeJoinRepeatedRoom) {
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
                            .append(RCRTCEngine.getInstance().getClientId())
                            .append("\n")
                            .append("RoomId: ")
                            .append(roomId)
                            .append("\n")
                            .append("LocalUserId: ")
                            .append(DataInterface.getUserId())
                            .append("\n")
                            .append("MCU: ")
                            .append(mInfo.getMcuUrl());
                        DialogUtils.showDialog(RoomInfoActivity.this, msg.toString(), "确定",
                            new DialogInterface.OnClickListener() {
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
     * 取消订阅直播流
     */
    private void unsubscribeLiveAVStream(final IRCRTCResultCallback callBack) {
        write("unsubscribeLiveAVStream-T", "LocalUserId", DataInterface.getUserId());
        if (mInfo == null || TextUtils.isEmpty(mInfo.getMcuUrl())) {
            if (callBack != null) {
                write("unsubscribeLiveAVStream-R", "LocalUserId", DataInterface.getUserId());
                callBack.onSuccess();
            }
            return;
        }
        RCRTCEngine.getInstance()
            .unsubscribeLiveStream(mInfo.getMcuUrl(), new IRCRTCResultCallback() {
                @Override
                public void onSuccess() {
                    write("unsubscribeLiveAVStream-R", "MCU", mInfo.getMcuUrl());
                    if (callBack != null)
                        callBack.onSuccess();
                }

                @Override
                public void onFailed(RTCErrorCode rtcErrorCode) {
                    write("unsubscribeLiveAVStream-E", "MCU", mInfo.getMcuUrl());
                    if (callBack != null)
                        callBack.onFailed(rtcErrorCode);
                }
            });
    }


    /**
     * 加入Rtc房间
     */
    public void joinRtcRoom() {
        if (mRoleType.get() == RoleType.VIEWER)
            return;
        if (!checkPermissions())
            return;
        write("joinRtcRoom-T", "RoomId|UserId", roomId, DataInterface.getUserId());

        RCRTCVideoStreamConfig vc = Builder.create()
            .setVideoResolution(RCRTCVideoResolution.RESOLUTION_360_640)
            .setVideoFps(RCRTCVideoFps.Fps_24)
            .build();

        RCRTCCameraOutputStream defaultVideoStream = RCRTCEngine.getInstance().getDefaultVideoStream();
        defaultVideoStream.setVideoConfig(vc);

        resetView();
        mVideoMagr.resetView();
        RCRTCEngine.getInstance()
            .joinRoom(roomId, RCRTCRoomType.LIVE_AUDIO_VIDEO, new IRCRTCResultDataCallback<RCRTCRoom>() {
                @Override
                public void onSuccess(final RCRTCRoom rongRTCRoom) {
                    write("joinRtcRoom-R", "RoomId|UserId", roomId, DataInterface.getUserId());
                    postUIThread(new Runnable() {
                        @Override
                        public void run() {
                            onJoinRtcRoom(rongRTCRoom);
                            closeLoading();
                        }
                    });

                }

                @Override
                public void onFailed(final RTCErrorCode rtcErrorCode) {
                    write("joinRtcRoom-E", "RoomId|UserId|ErrorCode", roomId, DataInterface.getUserId(),
                        rtcErrorCode.getValue());
                    postUIThread(new Runnable() {
                        @Override
                        public void run() {
                            StringBuilder msg = new StringBuilder("创建直播间失败: ");
                            msg.append("\n")
                                .append("ErrorCode: ")
                                .append(rtcErrorCode.getValue())
                                .append("\n")
                                .append("ClientId: ")
                                .append(RCRTCEngine.getInstance().getClientId())
                                .append("\n")
                                .append("RoomId: ")
                                .append(roomId)
                                .append("\n")
                                .append("LocalUserId: ")
                                .append(DataInterface.getUserId());
                            DialogUtils.showDialog(RoomInfoActivity.this, msg.toString(), "确定",
                                new DialogInterface.OnClickListener() {
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

    protected void postUIThread(final Runnable run) {
        if (isFinish())
            return;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (isFinish())
                    return;
                run.run();
            }
        });

    }

    /**
     * 加入Rtc房间成功后发布、订阅资源
     */
    private void onJoinRtcRoom(RCRTCRoom rongRTCRoom) {
        if (mRoleType.get() == RoleType.VIEWER) {
            quitRoom(false);
            subscribeLiveAVStream();
            return;
        }
        mRtcRoom = rongRTCRoom;
        RCRTCVideoView localSurface = new RCRTCVideoView(RoomInfoActivity.this);
        RCRTCLocalUser localUser = mRtcRoom.getLocalUser();
        mVideoMagr.setLargeView(localSurface, localUser.getUserId(), RCRTCStream.RONG_TAG);

        rongRTCRoom.registerRoomListener(mRoomEventsListener);
//        rongRTCRoom.registerStatusReportListener(this);

        RCRTCVideoOutputStream videoStream = localUser.getDefaultVideoStream();
        videoStream.setVideoView(localSurface);//设置本地view
        RCRTCEngine.getInstance().getDefaultVideoStream().startCamera(null);

        publishResource();//发布资源
        addAllVideoView();  //添加远端View
        List<RCRTCRemoteUser> remoteUsers = rongRTCRoom.getRemoteUsers();
        for (final RCRTCRemoteUser remoteUser : remoteUsers) {
            List<RCRTCInputStream> remoteAVStreams = remoteUser.getStreams();
            if (remoteAVStreams == null || remoteAVStreams.isEmpty()) {
                FwLog.write(FwLog.E, FwLog.RTC, "remoteAVStreams_Empty", "RoomId|LocalUserId|remoteUser", roomId,
                    DataInterface.getUserId(), remoteUser.getUserId());
                continue;
            }
            //默认订阅大流
            for (RCRTCInputStream stream : remoteAVStreams) {
                if (stream instanceof RCRTCVideoInputStream) {
                    ((RCRTCVideoInputStream) stream).setStreamType(RCRTCStreamType.NORMAL);
                }
            }
            write("subscribeAVStream-T", "RoomId|LocalUserId|remoteUser", roomId, DataInterface.getUserId(),
                remoteUser.getUserId());
            localUser.subscribeStreams(remoteAVStreams, new IRCRTCResultCallback() {
                @Override
                public void onSuccess() {
                    write("subscribeAVStream-R", "RoomId|LocalUserId|remoteUser", roomId, DataInterface.getUserId(),
                        remoteUser.getUserId());
                }

                @Override
                public void onFailed(final RTCErrorCode errorCode) {
                    write("subscribeAVStream-E", "RoomId|LocalUserId|remoteUser|erroCode", roomId,
                        DataInterface.getUserId(), remoteUser.getUserId(), errorCode.getValue());
                    postUIThread(new Runnable() {
                        @Override
                        public void run() {

                            StringBuilder msg = new StringBuilder("订阅资源失败");
                            msg.append("\n")
                                .append("ErrorCode: ")
                                .append(errorCode.getValue())
                                .append("\n")
                                .append("ClientId: ")
                                .append(RCRTCEngine.getInstance().getClientId())
                                .append("\n")
                                .append("RoomId: ")
                                .append(roomId)
                                .append("\n")
                                .append("LocalUserId: ")
                                .append(DataInterface.getUserId())
                                .append("\n")
                                .append("RemoteUserId: ")
                                .append(remoteUser.getUserId());
                            DialogUtils
                                .showDialog(RoomInfoActivity.this, msg.toString(), "确定", new DialogInterface.OnClickListener() {
                                    @Override
                                    public void onClick(DialogInterface dialog, int which) {
                                        dialog.dismiss();
//                            finish();
                                    }
                                });
                        }
                    });
                }
            });
        }

    }

    private void addAllVideoView() {
        List<RCRTCRemoteUser> remoteUsers = mRtcRoom.getRemoteUsers();
        if (remoteUsers != null) {
            for (RCRTCRemoteUser remoteUser : remoteUsers) {
                addNewRemoteView(remoteUser);//准备view
            }
        }
    }

    /**
     * 添加远端音视频流View
     *
     * @param remoteUser
     */
    private void addNewRemoteView(RCRTCRemoteUser remoteUser) {
        List<RCRTCInputStream> remoteAVStreams = remoteUser.getStreams();
        ArrayList<RCRTCInputStream> streams = new ArrayList<>();
        RCRTCInputStream audioStream = null;
        for (RCRTCInputStream inputStream : remoteAVStreams) {
            if (inputStream.getMediaType() == RCRTCMediaType.VIDEO) {
                streams.add(inputStream);
            } else if (inputStream.getMediaType() == RCRTCMediaType.AUDIO) {
                audioStream = inputStream;
            }
        }
        if (streams.isEmpty() && audioStream != null) {
            streams.add(audioStream);
        }
        for (RCRTCInputStream stream : streams) {
            RCRTCVideoView remoteView = new RCRTCVideoView(this);
            mVideoMagr.addSmallView(remoteView, remoteUser.getUserId(), stream.getTag());
            ((RCRTCVideoInputStream)stream).setVideoView(remoteView);
        }
        mVideoMagr.updateUserInfos(getAnchorInfos());

    }

    private ArrayList<UserInfo> getAnchorInfos() {
        List<OnlineUserInfo> allUsers = onlineUserPanel.getAllUsers();
        if (allUsers == null)
            return null;
        ArrayList<UserInfo> userInfos = new ArrayList<>();
        for (OnlineUserInfo user : allUsers) {
            if (user.roleType != RoleType.VIEWER) {
                userInfos.add(user);
            }
        }
        userInfos.add(ChatroomKit.getCurrentUser());
        return userInfos;
    }

    /**
     * 发布音视频资源
     */
    private void publishResource() {
        write("publishDefaultLiveAVStream-T", "RoomId|LocalUserId", roomId, DataInterface.getUserId());
        mRtcRoom.getLocalUser().publishDefaultLiveStreams(new IRCRTCResultDataCallback<RCRTCLiveInfo>() {
            @Override
            public void onSuccess(final RCRTCLiveInfo rongRTCLiveRoom) {
                write("publishDefaultLiveAVStream-R", "RoomId|LocalUserId", roomId, DataInterface.getUserId());
                if (isFinish())
                    return;
                onPublishLiveSuccess(rongRTCLiveRoom);
            }

            @Override
            public void onFailed(final RTCErrorCode rtcErrorCode) {
                write("publishDefaultLiveAVStream-E", "RoomId|LocalUserId|ErrorCode", roomId, DataInterface.getUserId(),
                    rtcErrorCode.getValue());
                postUIThread(new Runnable() {
                    @Override
                    public void run() {
                        closeLoading();
                        StringBuilder msg = new StringBuilder("资源发布失败: ");
                        msg.append("\n")
                            .append("ErrorCode: ")
                            .append(rtcErrorCode.getValue())
                            .append("\n")
                            .append("ClientId: ")
                            .append(RCRTCEngine.getInstance().getClientId())
                            .append("\n")
                            .append("RoomId: ")
                            .append(roomId)
                            .append("\n")
                            .append("LocalUserId: ")
                            .append(DataInterface.getUserId());
                        DialogUtils.showDialog(RoomInfoActivity.this, msg.toString(), "确定",
                            new DialogInterface.OnClickListener() {
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
     *
     * @param rongRTCLiveRoom
     */
    private void onPublishLiveSuccess(RCRTCLiveInfo rongRTCLiveRoom) {
        if (!TextUtils.equals(roomId, rongRTCLiveRoom.getRoomId()) || isViewer()) {
            showToast("发布资源失败：数据异常");
            return;
        }
        mLiveInfo = rongRTCLiveRoom;
        if (mRoleType.get() == RoleType.HOST) {
            mConfigHelper = new MixConfigHelper(rongRTCLiveRoom, mRtcRoom);
            mConfigHelper.setCallback(new IRCRTCResultCallback() {
                @Override
                public void onSuccess() {
                }

                @Override
                public void onFailed(RTCErrorCode rtcErrorCode) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            DialogUtils.showDialog(RoomInfoActivity.this, "混流布局设置失败");
                        }
                    });
                }
            });
            mInfo.setMcuUrl(rongRTCLiveRoom.getLiveUrl());
            mConfigHelper.changeMixConfig(new LayoutConfigDialog.ConfigParams(RCRTCMixConfig.MixLayoutMode.SUSPENSION));
            onSubmitRoomInfo(mInfo);
        }

        RCRTCVideoResolution videoResolution = mRtcRoom.getLocalUser().getDefaultVideoStream().getVideoConfig()
            .getVideoResolution();
        bottomPanel.setVideoFrameSize(videoResolution.getWidth(), videoResolution.getHeight());

    }

    /**
     * 向APPServer提交Live信息更新直播列表
     *
     * @param chatroomInfo
     */
    private void onSubmitRoomInfo(ChatroomInfo chatroomInfo) {
        Request.Builder request = new Request.Builder();
        request.url(DataInterface.APPSERVER + DataInterface.PUBLISH);
        request.method(RequestMethod.POST);
        request.body(new Gson().toJson(chatroomInfo));
        HttpClient.getDefault().request(request.build(), new HttpClient.ResultCallback() {
            @Override
            public void onResponse(final String s) {
                LogUtils.i("DemoServer", "onSubmitRoomInfo result = " + s);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (isFinish())
                            return;
                        closeLoading();
                        BaseResponse res = new Gson().fromJson(s, BaseResponse.class);
                        if (res.isSuccess()) {
                            joinChatRoom();
                        } else {
                            DialogUtils.showDialog(RoomInfoActivity.this, "创建直播间失败:" + res.desc, "确定",
                                new DialogInterface.OnClickListener() {
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
                LogUtils.e("DemoServer", "onSubmitRoomInfo failure = " + i);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        closeLoading();
                        showToast("创建直播间失败: " + i);
                    }
                });

            }
        });
    }

    /**
     * 退出房间
     *
     * @param resubscribe 是否需要降级为观众重新订阅直播流
     */
    private void quitRoom(final boolean resubscribe) {
        unPublishCustomStream(null);
        RCRTCEngine.getInstance()
            .leaveRoom(new IRCRTCResultCallback() {
                @Override
                public void onSuccess() {
                    if (!isFinish())
                        return;
//                        if (mRoleType.get() == RoleType.ANCHOR){    //升级为主播
//                            joinRtcRoom();
//                        }else
                    if (resubscribe) { //降级为观众
                        subscribeLiveAVStream();
                    }
                }

                @Override
                public void onFailed(RTCErrorCode rtcErrorCode) {
                    FinLog.d(TAG, "quitRoom Faild: " + rtcErrorCode);
                }
            });
    }

    /**
     * 是否为观众
     *
     * @return
     */
    private boolean isViewer() {
        return mRoleType == null || mRoleType.get() == RoleType.VIEWER;
    }

    @Override
    protected void onDestroy() {
        LogUtils.d(TAG, "onDestroy");
        super.onDestroy();
        stopService(new Intent(this, RTCNotificationService.class));
        if (mReceiver != null) {
            mReceiver.setListener(null);
            mReceiver.unregisterReceiver(this);
        }
        mReceiver = null;
        if (isViewer()) {
            unsubscribeLiveAVStream(null);
        } else {
            quitRoom(false);
        }
        mRtcRoom = null;
        AudioManager audioManager = (AudioManager) getSystemService(
            Context.AUDIO_SERVICE);
        audioManager.setMode(AudioManager.MODE_NORMAL);
        if (mConfigHelper != null) {
            mConfigHelper.release();
        }
        mSetCDNPushDialog = null;
        RCRTCEngine.getInstance().unInit();
    }

    public IRCRTCRoomEventsListener mRoomEventsListener = new IRCRTCRoomEventsListener() {

        /**
         * 有远端用户发布了音视频资源
         *
         * @param rongRTCRemoteUser
         * @param list
         */
        @Override
        public void onRemoteUserPublishResource(final RCRTCRemoteUser rongRTCRemoteUser,
            List<RCRTCInputStream> list) {

            write("subscribeAVStream-T", "RoomId|LocalUserId|remoteUser", roomId, DataInterface.getUserId(),
                rongRTCRemoteUser.getUserId());
            addNewRemoteView(rongRTCRemoteUser);
            mRtcRoom.getLocalUser().subscribeStreams(list, new IRCRTCResultCallback() {
                @Override
                public void onSuccess() {
                    write("subscribeAVStream-R", "RoomId|LocalUserId|remoteUser", roomId, DataInterface.getUserId(),
                        rongRTCRemoteUser.getUserId());
                }

                @Override
                public void onFailed(final RTCErrorCode errorCode) {
                    write("subscribeAVStream-E", "RoomId|LocalUserId|remoteUserId", roomId, DataInterface.getUserId(),
                        rongRTCRemoteUser.getUserId());
                    postUIThread(new Runnable() {
                        @Override
                        public void run() {
                            StringBuilder msg = new StringBuilder("订阅资源失败: ");
                            msg.append("\n")
                                .append("ErrorCode: ")
                                .append(errorCode)
                                .append("\n")
                                .append("ClientId: ")
                                .append(RCRTCEngine.getInstance().getClientId())
                                .append("\n")
                                .append("RoomId: ")
                                .append(roomId)
                                .append("\n")
                                .append("LocalUserId: ")
                                .append(DataInterface.getUserId())
                                .append("\n")
                                .append("RemoteUserId: ")
                                .append(rongRTCRemoteUser.getUserId());
                            DialogUtils
                                .showDialog(RoomInfoActivity.this, msg.toString(), "确定", new DialogInterface.OnClickListener() {
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
            if (mConfigHelper != null) {
                mConfigHelper.updateMixConfig();
            }
        }

        @Override
        public void onRemoteUserMuteAudio(RCRTCRemoteUser rcrtcRemoteUser, RCRTCInputStream rcrtcInputStream,
            boolean b) {
        }

        @Override
        public void onRemoteUserMuteVideo(RCRTCRemoteUser rcrtcRemoteUser, RCRTCInputStream rcrtcInputStream,
            boolean b) {
        }

        @Override
        public void onRemoteUserUnpublishResource(RCRTCRemoteUser rongRTCRemoteUser, List<RCRTCInputStream> list) {
            for (RCRTCInputStream rongRTCAVInputStream : list) {
                if (rongRTCAVInputStream.getMediaType() == RCRTCMediaType.VIDEO) {
                    if (mVideoMagr != null)
                        mVideoMagr.removeVideoView(rongRTCRemoteUser.getUserId(), rongRTCAVInputStream.getTag());
                }
            }

        }

        /**
         * 有用户加入了房间
         *
         * @param rongRTCRemoteUser
         */
        @Override
        public void onUserJoined(RCRTCRemoteUser rongRTCRemoteUser) {
            if (mRoleType.get() != RoleType.HOST)
                return;
            ArrayList<UserInfo> userInfos = getAnchorInfos();
            if (userInfos == null)
                return;
            ChatroomKit.sendMessage(new ChatroomSyncUserInfo(userInfos));
        }

        /**
         * 有用户离开
         *
         * @param rongRTCRemoteUser
         */
        @Override
        public void onUserLeft(RCRTCRemoteUser rongRTCRemoteUser) {
            if (!isFinish()) {
                mVideoMagr.removeVideoView(rongRTCRemoteUser.getUserId(), null);
            }
            if (mConfigHelper != null) {
                mConfigHelper.updateMixConfig();
            }
        }


        @Override
        public void onUserOffline(RCRTCRemoteUser rongRTCRemoteUser) {
            if (!isFinish()) {
                mVideoMagr.removeVideoView(rongRTCRemoteUser.getUserId(), null);
            }
            if (mConfigHelper != null) {
                mConfigHelper.updateMixConfig();
            }
        }

        @Override
        public void onVideoTrackAdd(String s, String s1) {

        }


        /**
         * 网络异常导致离开房间
         */
        @Override
        public void onLeaveRoom(int var1) {
            Log.e(TAG, "onLeaveRoom: " + roomId);
            if (isFinish())
                return;
            AlertDialog.Builder builder = new AlertDialog.Builder(RoomInfoActivity.this);
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

    };

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
        //TODO 为防止长时间处于后台被系统杀掉，所以显示前台Service
        if (!mIsQuit)
            startService(new Intent(this, RTCNotificationService.class));
        if (mRtcRoom != null){
            RCRTCEngine.getInstance().getDefaultVideoStream().stopCamera();
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
            RCRTCEngine.getInstance().getDefaultVideoStream().startCamera(null);
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

        });
    }

    @Override
    protected void onReciveChatRoomUserBlock(MessageContent messageContent) {
        if (isViewer()){
            unsubscribeLiveAVStream(null);
        }else {
            quitRoom(false);
        }
        super.onReciveChatRoomUserBlock(messageContent);
    }

    private static void write(String tag,String keys, Object... values){
        FwLog.write(FwLog.I,FwLog.RTC,"SL-"+tag,keys,values);
    }

    private void unPublishCustomStream(final CheckBox checkBox) {
        unPublishCustomStream(checkBox,null);
    }

    /**
     * 取消发送自定义流
     * @param checkBox
     */
    private void unPublishCustomStream(final CheckBox checkBox, final IRCRTCResultCallback callback) {
        if (mRtcRoom == null || mRtcRoom.getLocalUser() == null)
            return;
        mRtcRoom.getLocalUser().unpublishStream(mFileVideoOutputStream,
            new IRCRTCResultCallback() {
                @Override
                public void onSuccess() {
                    if (callback != null){
                        callback.onSuccess();
                    }
                    postUIThread(new Runnable() {
                        @Override
                        public void run() {
                            if (mVideoMagr != null)
                                mVideoMagr.removeVideoView(mRtcRoom.getLocalUser().getUserId(), mFileVideoOutputStream.getTag());
                            if (checkBox != null)
                                checkBox.setSelected(false);
                        }
                    });
                }

                @Override
                public void onFailed(final RTCErrorCode errorCode) {
                    if (callback != null){
                        callback.onFailed(errorCode);
                    }
                    postUIThread(new Runnable() {
                        @Override
                        public void run() {
                            showToast("取消发布自定义视频失败:" + errorCode);
                        }
                    });

                }
            });
    }

    private void publishCustomStream(String filePath,final CheckBox checkBox) {
        if (mRtcRoom == null || mRtcRoom.getLocalUser() == null){
            showToast("未加入房间");
            return;
        }

        checkBox.setSelected(true);
        mFileVideoOutputStream = RCRTCEngine.getInstance().createFileVideoOutputStream(filePath, false, true,
            "FileVideo", RCRTCVideoStreamConfig.Builder.create().setVideoResolution(RCRTCVideoResolution.RESOLUTION_360_640).setVideoFps(RCRTCVideoFps.Fps_24).build());
        mFileVideoOutputStream.setOnSendListener(new IRCRTCOnStreamSendListener() {
            @Override
            public void onStart(RCRTCVideoOutputStream stream) {
                if (mConfigHelper != null)
                    mConfigHelper.updateMixConfig();
                RCRTCVideoView videoView = new RCRTCVideoView(RoomInfoActivity.this);
                stream.setVideoView(videoView);
                mVideoMagr.addSmallView(videoView,mRtcRoom.getLocalUser().getUserId(),stream.getTag());
            }

            @Override
            public void onComplete(final RCRTCVideoOutputStream stream) {
                unPublishCustomStream(checkBox);
                if (mConfigHelper != null)
                    mConfigHelper.updateMixConfig();
            }

            @Override
            public void onFailed() {
                postUIThread(new Runnable() {
                    @Override
                    public void run() {
                        showToast("发布自定义流失败");
                        if(checkBox != null)
                            checkBox.setSelected(false);
                    }
                });
            }
        });

        mRtcRoom.getLocalUser().publishStream(mFileVideoOutputStream, new IRCRTCResultCallback() {
            @Override
            public void onSuccess() {
            }

            @Override
            public void onFailed(RTCErrorCode rtcErrorCode) {
                unPublishCustomStream(checkBox);
                postUIThread(new Runnable() {
                    @Override
                    public void run() {
                        showToast("发布自定义流失败");
                        if(checkBox != null)
                            checkBox.setSelected(false);
                    }
                });
            }
        });
    }
}
