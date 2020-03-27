package cn.rongcloud.chatroomdemo.ui.panel;

import android.content.Context;
import android.graphics.Color;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.rtc.user.RongRTCUser;

/**
 * Created by wangw on 2019-08-22.
 */
public class VideoViewWrapper extends RelativeLayout {
    private TextView mTvUserName;
    private RelativeLayout mRlCover;
    private FrameLayout mFlVideoContainer;
    private RongRTCUser mUserInfo;
    private SurfaceView mVideoView;
    private View mRootView;

    public VideoViewWrapper(@NonNull Context context) {
        super(context);
        onInitView();
    }

    public VideoViewWrapper(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        onInitView();
    }

    public VideoViewWrapper(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        onInitView();
    }


    private void onInitView() {
        inflate(getContext(), R.layout.widget_smallview_wrapper, this);
        mTvUserName = findViewById(R.id.tv_UserName);
        mRlCover = findViewById(R.id.rl_cover);
        mFlVideoContainer = findViewById(R.id.fl_video_container);
        mRootView = findViewById(R.id.rootview);
        mRlCover.bringToFront();
    }

    public void setVideView(SurfaceView view,RongRTCUser user){
        mVideoView = view;
        mFlVideoContainer.removeAllViews();
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        layoutParams.gravity = Gravity.CENTER;
        mFlVideoContainer.addView(view,layoutParams);
//        mFlVideoContainer.bringToFront();
//        view.setBackgroundColor(Color.BLACK);

        mUserInfo = user;
    }

    public SurfaceView getVideoView(){
        return mVideoView;
    }

    public void restView(){
        mVideoView = null;
        mFlVideoContainer.removeAllViews();
        mUserInfo = null;
    }


    public RongRTCUser getUserInfo() {
        return mUserInfo;
    }


    public void updateUserName(String name) {
        mTvUserName.setText(name);
    }

    public void setBorder(int value) {
        mRootView.setPadding(value,value,value,value);
    }

    public void showUserName(boolean isShow) {
        if (mTvUserName != null)
            mTvUserName.setVisibility(isShow ? VISIBLE : INVISIBLE);
    }
}
