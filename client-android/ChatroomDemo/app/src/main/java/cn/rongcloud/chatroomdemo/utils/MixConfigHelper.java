package cn.rongcloud.chatroomdemo.utils;

import android.os.SystemClock;
import cn.rongcloud.chatroomdemo.ui.panel.LayoutConfigDialog.ConfigParams;
import cn.rongcloud.rtc.api.RCRTCEngine;
import cn.rongcloud.rtc.api.RCRTCLocalUser;
import cn.rongcloud.rtc.api.RCRTCMixConfig;
import cn.rongcloud.rtc.api.RCRTCMixConfig.CustomLayoutList.CustomLayout;
import cn.rongcloud.rtc.api.RCRTCRemoteUser;
import cn.rongcloud.rtc.api.RCRTCRoom;
import cn.rongcloud.rtc.api.callback.IRCRTCResultCallback;
import cn.rongcloud.rtc.api.callback.IRCRTCResultDataCallback;
import cn.rongcloud.rtc.api.stream.RCRTCInputStream;
import cn.rongcloud.rtc.api.stream.RCRTCLiveInfo;
import cn.rongcloud.rtc.api.stream.RCRTCOutputStream;
import cn.rongcloud.rtc.api.stream.RCRTCVideoStreamConfig;
import cn.rongcloud.rtc.base.RCRTCMediaType;
import cn.rongcloud.rtc.base.RCRTCStream;
import cn.rongcloud.rtc.base.RTCErrorCode;
import java.util.ArrayList;
import java.util.List;

import cn.rongcloud.chatroomdemo.ui.panel.LayoutConfigDialog;

/**
 * Created by wangw on 2019-12-24.
 */
public class MixConfigHelper {

    private static final String TAG = "MixConfigHelper";
    private final RCRTCRoom mRTCRoom;
    private LayoutConfigDialog.ConfigParams mConfigParams;
    private IRCRTCResultCallback mCallback;
    private RCRTCLiveInfo mLiveInfo;
    private static final int TINY_VIDEOSTREAM_WIDTH=144;
    private static final int TINY_VIDEOSTREAM_HEIGHT=176;
    private static final int TINY_VIDEOSTREAM_FPS=15;
    private static final int TINY_VIDEOSTREAM_BITRATE=120;

    public MixConfigHelper(RCRTCLiveInfo rongRTCLiveInfo, RCRTCRoom rtcRoom) {
        mLiveInfo = rongRTCLiveInfo;
        mRTCRoom = rtcRoom;
    }

    /**
     * 修改合流布局配置
     * @param params 合流布局参数
     * @return
     */
    public RCRTCMixConfig changeMixConfig(LayoutConfigDialog.ConfigParams params) {
        mConfigParams = params;
        return onSubmitChange();
    }

    public void release() {
        mCallback = null;
    }

    /**
     * 如果有新的视频流加入，需要更新合流布局配置
     */
    public void updateMixConfig() {
        if (mConfigParams != null && mConfigParams.model == RCRTCMixConfig.MixLayoutMode.CUSTOM)
            onSubmitChange();
    }

    private RCRTCMixConfig onSubmitChange() {
        if (mConfigParams == null)
            return null;
        RCRTCMixConfig mixConfig = createMixConfig(mConfigParams);
        mLiveInfo.setMixConfig(mixConfig, new IRCRTCResultCallback() {
            @Override
            public void onSuccess() {
                if (mCallback != null)
                    mCallback.onSuccess();
            }

            @Override
            public void onFailed(RTCErrorCode rtcErrorCode) {
                if (mCallback != null)
                    mCallback.onFailed(rtcErrorCode);
            }
        });
        return mixConfig;
    }

    public RCRTCMixConfig createMixConfig(LayoutConfigDialog.ConfigParams configParams){
        RCRTCMixConfig config = new RCRTCMixConfig();
        //设置合流布局模式
        config.setLayoutMode(configParams.model);
        RCRTCLocalUser localUser = mRTCRoom.getLocalUser();
        //当做背景Video的用户Id
        config.setHostVideoStream(localUser.getDefaultVideoStream());

        //合流布局输出参数配置
        RCRTCMixConfig.MediaConfig mediaConfig = new RCRTCMixConfig.MediaConfig();

        //视频输出配置
        RCRTCMixConfig.MediaConfig.VideoConfig videoConfig = new RCRTCMixConfig.MediaConfig.VideoConfig();
        //标准视频流的输出布局参数
        RCRTCMixConfig.MediaConfig.VideoConfig.VideoLayout normal = new RCRTCMixConfig.MediaConfig.VideoConfig.VideoLayout();
        RCRTCVideoStreamConfig vc = mRTCRoom.getLocalUser().getDefaultVideoStream().getVideoConfig();
        int videoWidth = vc.getVideoResolution().getWidth();
        normal.setWidth(videoWidth);
        int videoHeight = vc.getVideoResolution().getHeight();
        normal.setHeight(videoHeight);
        normal.setFps(vc.getVideoFps().getFps());
        videoConfig.setVideoLayout(normal);

        if(configParams.isEnableTinyStream){
            //设置 MCU 输出小流视频的 输出分辨率 ，码率，帧率
            RCRTCMixConfig.MediaConfig.VideoConfig.VideoLayout tinyVideoLayout = new RCRTCMixConfig.MediaConfig.VideoConfig.VideoLayout();
            tinyVideoLayout.setWidth(TINY_VIDEOSTREAM_WIDTH);
            tinyVideoLayout.setHeight(TINY_VIDEOSTREAM_HEIGHT);
            tinyVideoLayout.setFps(TINY_VIDEOSTREAM_FPS);
            tinyVideoLayout.setBitrate(TINY_VIDEOSTREAM_BITRATE);
            videoConfig.setTinyVideoLayout(tinyVideoLayout);
        }

        //设置渲染模式
        videoConfig.setExtend(new RCRTCMixConfig.MediaConfig.VideoConfig.VideoExtend(configParams.isCrop ? RCRTCMixConfig.VideoRenderMode.CROP : RCRTCMixConfig.VideoRenderMode.WHOLE));
        //设置视频合流布局输出参数配置
        mediaConfig.setVideoConfig(videoConfig);
        //如果音频码率没有要求可以不设置
        //mediaConfig.setAudioConfig(new RCRTCMixConfig.MediaConfig.AudioConfig(rongRTCConfig.getAudioBitRate()));
        config.setMediaConfig(mediaConfig);

        //如果非自定义合流模式，则不需要设置CustomLayoutList
        if (configParams.model != RCRTCMixConfig.MixLayoutMode.CUSTOM){
            return config;
        }
        ArrayList<RCRTCMixConfig.CustomLayoutList.CustomLayout> list = new ArrayList<>();
        //设置背景Video渲染坐标
        RCRTCMixConfig.CustomLayoutList.CustomLayout iv = new RCRTCMixConfig.CustomLayoutList.CustomLayout();
        //当做背景Video Sream
        iv.setVideoStream(localUser.getDefaultVideoStream());
        iv.setX(0);
        iv.setY(0);
        iv.setWidth(normal.getWidth());
        iv.setHeight(normal.getHeight());
        list.add(iv);
        //布局每一个视频流的坐标及大小
        for (RCRTCOutputStream stream : localUser.getStreams()) {
            //必须是VideoStream
            if (stream == localUser.getDefaultVideoStream() || stream.getMediaType() != RCRTCMediaType.VIDEO)
                continue;
            list.add(createCustomLayout(configParams, list.size()-1, stream));
        }
        List<RCRTCRemoteUser> remoteUsers = mRTCRoom.getRemoteUsers();
        for (RCRTCRemoteUser user : remoteUsers) {
            //必须是VideoStream
            for (RCRTCInputStream stream : user.getStreams()) {
                if (stream.getMediaType() != RCRTCMediaType.VIDEO)
                    continue;
                list.add(createCustomLayout(configParams, list.size()-1, stream));
            }
        }
        //设置自定义视频合流布局参数列表
        config.setCustomLayouts(list);
        return config;
    }

    private CustomLayout createCustomLayout(ConfigParams configParams, int i,
        RCRTCStream stream) {
        CustomLayout vb = new CustomLayout();
        vb.setVideoStream(stream);
        vb.setX(configParams.x);
        vb.setY(configParams.height*i);
        vb.setWidth(configParams.width);
        vb.setHeight(configParams.height);
        return vb;
    }

    public IRCRTCResultCallback getCallback() {
        return mCallback;
    }

    public void setCallback(IRCRTCResultCallback callback) {
        mCallback = callback;
    }

//    public interface McuConfigHelperCallback{
//        void onSuccess();
//        void onFailed(int errorCode);
//    }

}
