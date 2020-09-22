package cn.rongcloud.chatroomdemo.ui.panel;

import android.content.Context;
import android.text.TextUtils;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.LinearLayout;

import cn.rongcloud.rtc.api.stream.RCRTCVideoView;
import cn.rongcloud.rtc.core.RendererCommon.ScalingType;
import java.util.List;

import io.rong.imlib.model.UserInfo;

/**
 * Created by wangw on 2019-08-21.
 */
public class VideoViewMagr {


    private Context mContext;
    private ViewGroup mLargeViewContainer;
    private LinearLayout mSmallViews;
    private int mScreenWidth;
    private int mScreenHeight;
    private LinearLayout.LayoutParams mSmallLayoutParams;
    private List<UserInfo> mUserInfos;
    private View.OnClickListener mOnClickListener;
    private static final String AUDIO_ONLY_VIEW_TAG="AudioOnlyView_tag";

    public VideoViewMagr(Context context) {
        mContext = context;
    }

    public void initView(ViewGroup largeViewContainer, LinearLayout smallViewsContainer){
        this.mLargeViewContainer = largeViewContainer;
        mSmallViews = smallViewsContainer;
        getSize();
        int base = mScreenHeight < mScreenWidth ? mScreenHeight : mScreenWidth;
        mSmallLayoutParams = new LinearLayout.LayoutParams(base / 4, base / 3);
    }

    private void getSize() {
        WindowManager wm = (WindowManager) mContext
                .getSystemService(Context.WINDOW_SERVICE);

        mScreenWidth = wm.getDefaultDisplay().getWidth();
        mScreenHeight = wm.getDefaultDisplay().getHeight();
    }

    public void setLargeView(SurfaceView view, String userId, String tag){
        if (mLargeViewContainer == null)
            return;
        mLargeViewContainer.removeAllViews();
        onSetLargeView(view, userId, userId+"_"+tag,new VideoViewWrapper(mContext));
    }

    private void onSetLargeView(SurfaceView view, String userId, String tag, VideoViewWrapper wrapper) {
        wrapper.setBorder(0);
        wrapper.setVideView(view,userId);
        wrapper.setTag(tag);
        view.setZOrderMediaOverlay(false);
        view.setZOrderOnTop(false);
        ((RCRTCVideoView)view).setScalingType(ScalingType.SCALE_ASPECT_FIT);
        wrapper.showUserName(false);
        wrapper.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mOnClickListener != null)
                    mOnClickListener.onClick(v);
            }
        });
        wrapper.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,ViewGroup.LayoutParams.MATCH_PARENT));
        mLargeViewContainer.addView(wrapper);
    }

    public void setClickLargeViewListener(View.OnClickListener listener){
        mOnClickListener = listener;
    }


    public void addSmallView(SurfaceView view,String userId,String tag){
        if (mSmallViews == null)
            return;
        removeVideoView(userId,tag);
        VideoViewWrapper wrapper = new VideoViewWrapper(mContext);
        onSetSmallView(view, userId, userId+"_"+tag, wrapper);
    }

    private void onSetSmallView(SurfaceView view, String userId, String tag, VideoViewWrapper wrapper) {
        wrapper.setBorder(3);
        wrapper.setTag(tag);
        wrapper.setVideView(view,userId);
        view.setZOrderOnTop(true);
        view.setZOrderMediaOverlay(true);
        ((RCRTCVideoView)view).setScalingType(ScalingType.SCALE_ASPECT_FILL);
        wrapper.showUserName(true);
        if (mUserInfos != null){
            for (UserInfo userInfo : mUserInfos) {
                if (TextUtils.equals(userId,userInfo.getUserId())){
                    wrapper.updateUserName(userInfo.getName());
                    break;
                }
            }
        }
        wrapper.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                VideoViewWrapper preSmallView = (VideoViewWrapper) v;
                mSmallViews.removeView(preSmallView);
                VideoViewWrapper preLargeView = (VideoViewWrapper) mLargeViewContainer.getChildAt(0);
                mLargeViewContainer.removeAllViews();
                onSetLargeView(preSmallView.getVideoView(),preSmallView.getUserId(), (String) preSmallView.getTag(),preSmallView);
                onSetSmallView(preLargeView.getVideoView(),preLargeView.getUserId(), (String) preLargeView.getTag(),preLargeView);
            }
        });
        mSmallViews.addView(wrapper,mSmallLayoutParams);
    }

    public void resetView(){
        mLargeViewContainer.removeAllViews();
        mSmallViews.removeAllViews();
    }

    /**
     * 删除VideView
     * @param userId  用户ID不能为空
     * @param tag   如果是Null，则删除指定用户下所有的VideoView
     */
    public void removeVideoView(String userId,String tag) {
        if (TextUtils.isEmpty(userId))
            return;
        int size = mLargeViewContainer.getChildCount();
        boolean fullMatch = !TextUtils.isEmpty(tag);
        String target = !fullMatch ? userId : userId+"_"+tag;

        if(size > 0 && checkEquals(mLargeViewContainer.getChildAt(0),target,fullMatch)) {
            mLargeViewContainer.removeAllViews();
            //将第一个小的VideoView补齐到大View中
            if (mSmallViews.getChildCount() > 0){
                VideoViewWrapper child = (VideoViewWrapper) mSmallViews.getChildAt(0);
                mSmallViews.removeView(child);
                onSetLargeView(child.getVideoView(),child.getUserId(), (String) child.getTag(),child);
            }
            return;
        }
        size = mSmallViews.getChildCount();
        for (int i = 0; i < size; i++) {
            if (checkEquals(mSmallViews.getChildAt(i),target,fullMatch)){
                mSmallViews.removeViewAt(i);
                if (fullMatch)
                    break;
            }
        }
    }

    private boolean checkEquals(View v,String target,boolean fullMatch){
        if (v == null)
            return false;
        String tag = (String) v.getTag();
        if (fullMatch){
            return TextUtils.equals(target,tag);
        }else {
            return TextUtils.equals(target,tag.split("_")[0]);
        }
    }

    public void updateUserInfos(List<UserInfo> userInfos) {
        mUserInfos = userInfos;
        onUpdateUserName(mLargeViewContainer);
        onUpdateUserName(mSmallViews);
    }

    private void onUpdateUserName(ViewGroup parent) {
        UserInfo info;
        if (parent.getChildCount() > 0) {
            for (int i = 0; i < parent.getChildCount(); i++) {
                VideoViewWrapper child = (VideoViewWrapper) parent.getChildAt(i);
                if (child.getUserId() != null && (info = getUserInfo(child.getUserId())) != null) {
                    child.updateUserName(info.getName());
                }
            }
        }
    }

    private UserInfo getUserInfo(String uid){
        if (mUserInfos == null)
            return null;
        for (UserInfo userInfo : mUserInfos) {
            if (TextUtils.equals(userInfo.getUserId(),uid))
                return userInfo;
        }
        return null;
    }

    public void addAudioOnlyView(View view){
        if (mLargeViewContainer == null)
            return;
//        mLargeViewContainer.removeAllViews();
        view.setTag(AUDIO_ONLY_VIEW_TAG);
        mLargeViewContainer.addView(view);
    }

    public void removeAudioOnlyView(){
        if (mLargeViewContainer == null)
            return;
        int childCount = mLargeViewContainer.getChildCount();
        View view = null;
        for (int i = 0; i < childCount; i++) {
            view = mLargeViewContainer.getChildAt(i);
            if(view!=null &&
                view.getTag()!=null &&
                !TextUtils.isEmpty((CharSequence) view.getTag()) &&
                TextUtils.equals((CharSequence) view.getTag(),AUDIO_ONLY_VIEW_TAG)){
                mLargeViewContainer.removeViewAt(i);
            }
        }
    }
}
