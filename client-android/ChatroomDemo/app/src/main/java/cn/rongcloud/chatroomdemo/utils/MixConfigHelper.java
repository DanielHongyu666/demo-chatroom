package cn.rongcloud.chatroomdemo.utils;

import java.util.ArrayList;
import java.util.List;

import cn.rongcloud.chatroomdemo.ui.panel.LayoutConfigDialog;
import cn.rongcloud.rtc.RTCErrorCode;
import cn.rongcloud.rtc.callback.RongRTCResultUICallBack;
import cn.rongcloud.rtc.config.RongCenterConfig;
import cn.rongcloud.rtc.room.RongRTCMixConfig;
import cn.rongcloud.rtc.room.RongRTCLiveInfo;
import cn.rongcloud.rtc.room.RongRTCRoom;
import cn.rongcloud.rtc.stream.local.RongRTCLocalSourceManager;

/**
 * Created by wangw on 2019-12-24.
 */
public class MixConfigHelper {

    private static final String TAG = "MixConfigHelper";
    private final RongRTCRoom mRTCRoom;
    private LayoutConfigDialog.ConfigParams mConfigParams;
    private RongRTCResultUICallBack mCallback;
    private RongRTCLiveInfo mLiveInfo;

    public MixConfigHelper(RongRTCLiveInfo rongRTCLiveInfo, RongRTCRoom rtcRoom) {
        mLiveInfo = rongRTCLiveInfo;
        mRTCRoom = rtcRoom;
    }


    public RongRTCMixConfig onChange(LayoutConfigDialog.ConfigParams params, List<String> anchorList) {
        mConfigParams = params;
        return onSubmitChange(anchorList);
    }

    public void release() {
        mCallback = null;
    }

    public void onUserChange(List<String> anchorList) {
        if (mConfigParams != null && mConfigParams.model == RongRTCMixConfig.MixLayoutMode.CUSTOM)
            onSubmitChange(anchorList);
    }

    private RongRTCMixConfig onSubmitChange(List<String> anchorList) {
        if (mConfigParams == null)
            return null;
        RongRTCMixConfig mixConfig = createMixConfig(mConfigParams,anchorList);
        mLiveInfo.setMixConfig(mixConfig, new RongRTCResultUICallBack() {
            @Override
            public void onUiSuccess() {
                if (mCallback != null)
                    mCallback.onSuccess();
            }

            @Override
            public void onUiFailed(RTCErrorCode rtcErrorCode) {
                if (mCallback != null)
                    mCallback.onFailed(rtcErrorCode);
            }
        });
//        Gson gson = new GsonBuilder()
//                .setExclusionStrategies(new ExclusionStrategy() {
//                    @Override
//                    public boolean shouldSkipField(FieldAttributes f) {
//                        //TODO 此处需要优化
//                        if (TextUtils.equals(f.getName(),"tiny") ||
//                                (f.getDeclaringClass() == RongRTCMixConfig.OutputBean.VideoBean.NormalBean.class && TextUtils.equals(f.getName(),"bitrate")))
//                            return true;
//                        return false;
//                    }
//
//                    @Override
//                    public boolean shouldSkipClass(Class<?> clazz) {
//                        return false;
//                    }
//                })
//                .create();
//        String configJson = new Gson().toJson(mcuConfig);
//        Log.d(TAG,"MCUConfig= "+configJson);
//
//        Request request = new Request.Builder()
//                .url(mConfigUrl+"/server/mcu/config")
//                .method(RequestMethod.POST)
//                .addHeader("RoomId", mRTCRoom.getRoomId())
//                .addHeader("UserId", mRTCRoom.getLocalUser().getUserId())
//                .addHeader("AppKey", DataInterface.APP_KEY)
//                .addHeader("SessionId", mRTCRoom.getSessionId())
//                .addHeader("Token", RongMediaSignalClient.getInstance().getRtcToken())
//                .body(configJson)
//                .build();
//        HttpClient.getDefault().request(request, new HttpClient.ResultCallback() {
//            @Override
//            public void onResponse(final String s) {
//                LogUtils.i("DemoServer","onSubmitChange result = "+s);
//                if (mCallback != null)
//                    mCallback.onSuccess();
//            }
//
//            @Override
//            public void onFailure(final int i) {
//                LogUtils.e("DemoServer","onSubmitChange failure = "+i);
//                if (mCallback != null){
//                    mCallback.onFailed(i);
//                }
//
//            }
//
//            @Override
//            public void onError(IOException e) {
//                LogUtils.e("DemoServer","refreshData error = "+e.getMessage());
//                if (mCallback != null){
//                    mCallback.onFailed(-5000);
//                }
//            }
//        });
        return mixConfig;
    }

    public RongRTCMixConfig createMixConfig(LayoutConfigDialog.ConfigParams configParams, List<String> remoteUserIdList){
        RongRTCMixConfig config = new RongRTCMixConfig();
        //设置合流布局模式
        config.setLayoutMode(configParams.model);
        //当做背景Video的用户Id
        config.setHostUserId(mRTCRoom.getLocalUser().getUserId());

        //合流布局输出参数配置
        RongRTCMixConfig.MediaConfig mediaConfig = new RongRTCMixConfig.MediaConfig();

        //视频输出配置
        RongRTCMixConfig.MediaConfig.VideoConfig videoConfig = new RongRTCMixConfig.MediaConfig.VideoConfig();
        //标准视频流的输出布局参数
        RongRTCMixConfig.MediaConfig.VideoConfig.VideoLayout normal = new RongRTCMixConfig.MediaConfig.VideoConfig.VideoLayout();
        RongCenterConfig rongRTCConfig = RongRTCLocalSourceManager.getInstance().getRongRTCConfig();
        int videoWidth = rongRTCConfig.getVideoWidth();
        normal.setWidth(videoWidth);
        int videoHeight = rongRTCConfig.getVideoHeight();
        normal.setHeight(videoHeight);
        normal.setFps(rongRTCConfig.getVideoFPS());
        videoConfig.setVideoLayout(normal);
        //设置渲染模式
        videoConfig.setExtend(new RongRTCMixConfig.MediaConfig.VideoConfig.VideoExtend(configParams.isCrop ? RongRTCMixConfig.VideoRenderMode.CROP : RongRTCMixConfig.VideoRenderMode.WHOLE));
        //设置视频合流布局输出参数配置
        mediaConfig.setVideoConfig(videoConfig);
        //如果音频码率没有要求可以不设置
        //mediaConfig.setAudioConfig(new RongRTCMixConfig.MediaConfig.AudioConfig(rongRTCConfig.getAudioBitRate()));
        config.setMediaConfig(mediaConfig);

        //如果非自定义合流模式，则不需要设置CustomLayoutList
        if (configParams.model != RongRTCMixConfig.MixLayoutMode.CUSTOM){
            return config;
        }
        ArrayList<RongRTCMixConfig.CustomLayoutList.CustomLayout> list = new ArrayList<>();
        //设置背景Video渲染坐标
        RongRTCMixConfig.CustomLayoutList.CustomLayout iv = new RongRTCMixConfig.CustomLayoutList.CustomLayout();
        //当做背景Video的用户Id
        iv.setUserId(mRTCRoom.getLocalUser().getUserId());
        iv.setX(0);
        iv.setY(0);
        iv.setWidth(normal.getWidth());
        iv.setHeight(normal.getHeight());
        list.add(iv);
        //其他自定义视频合流布局参数
        if (remoteUserIdList != null && !remoteUserIdList.isEmpty()){
            int i = 0;
            for (String uid : remoteUserIdList) {
                RongRTCMixConfig.CustomLayoutList.CustomLayout vb = new RongRTCMixConfig.CustomLayoutList.CustomLayout();
                vb.setUserId(uid);
                vb.setX(configParams.x);
                vb.setY(configParams.height*i);
                vb.setWidth(configParams.width);
                vb.setHeight(configParams.height);
                list.add(vb);
                i++;
            }
        }
        //设置自定义视频合流布局参数列表
        config.setCustomLayouts(list);
        return config;
    }

    public RongRTCResultUICallBack getCallback() {
        return mCallback;
    }

    public void setCallback(RongRTCResultUICallBack callback) {
        mCallback = callback;
    }

//    public interface McuConfigHelperCallback{
//        void onSuccess();
//        void onFailed(int errorCode);
//    }

}
