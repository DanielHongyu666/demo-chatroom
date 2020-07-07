package cn.rongcloud.chatroomdemo.ui.panel;

import android.app.Dialog;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.annotation.IntRange;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.support.v7.widget.SwitchCompat;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.FrameLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;

import cn.rongcloud.rtc.api.RCRTCMixConfig;
import java.io.Serializable;

import cn.rongcloud.chatroomdemo.R;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;
import static android.view.ViewGroup.LayoutParams.WRAP_CONTENT;

/**
 * Created by wangw on 2019-12-02.
 */
public class LayoutConfigDialog extends DialogFragment implements View.OnClickListener {


    public static LayoutConfigDialog newInstance(int videoWidth,int videoHeight,ConfigParams params) {

        Bundle args = new Bundle();

        LayoutConfigDialog fragment = new LayoutConfigDialog();
        fragment.setArguments(args);
        args.putInt("videowidth",videoWidth);
        args.putInt("videoheight",videoHeight);
        args.putSerializable("params",params);
        return fragment;
    }

    private RadioGroup mRadioGroup;
    private FrameLayout mFlContent;
    private CustomLayoutView mCustomLayout;
    private ConfigChangeListener mConfigChangeListener;
    private SwitchCompat mScAdaptiveCrop;
    private SwitchCompat mScSuspendCrop;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.widget_layout_config_panel, container, false);
        mRadioGroup = view.findViewById(R.id.rg_options);
        mFlContent = view.findViewById(R.id.fl_content);
        mCustomLayout = view.findViewById(R.id.customview);
        mScAdaptiveCrop = view.findViewById(R.id.sc_adaptive_crop);
        mScSuspendCrop = view.findViewById(R.id.sc_suspend_crop);
        setListener(view);
        return view;
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
        Bundle args = getArguments();
        mCustomLayout.setVideoFrameSize(args.getInt("videowidth",0),args.getInt("videoheight",0));
        ConfigParams params = (ConfigParams) args.getSerializable("params");
        if (params == null)
            params = new ConfigParams(RCRTCMixConfig.MixLayoutMode.SUSPENSION);
        onSetView(params);

    }

    private void onSetView(ConfigParams params) {
        switch (params.model.getValue()) {
            case 1:
                ((RadioButton)getView().findViewById(R.id.rd_03)).setChecked(true);
                mCustomLayout.setViews(params);
                break;
            case 2:
                ((RadioButton)getView().findViewById(R.id.rd_02)).setChecked(true);
                mScSuspendCrop.setChecked(params.isCrop);
                break;
            default:
            case 3:
                ((RadioButton)getView().findViewById(R.id.rd_01)).setChecked(true);
                mScAdaptiveCrop.setChecked(params.isCrop);
                break;
        }

    }

    private void setListener(View v) {
        v.findViewById(R.id.iv_close).setOnClickListener(this);
        v.findViewById(R.id.btn_submit).setOnClickListener(this);
        mRadioGroup.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                int id = R.id.ll_adaptive;
                switch (checkedId) {
                    case R.id.rd_01:
                        id = R.id.ll_adaptive;
                        break;
                    case R.id.rd_02:
                        id = R.id.ll_suspend;
                        break;
                    case R.id.rd_03:
                        id = R.id.customview;
                        break;
                }
                for (int i = 0; i < mFlContent.getChildCount(); i++) {
                    mFlContent.getChildAt(i).setVisibility(mFlContent.getChildAt(i).getId() == id ? View.VISIBLE : View.INVISIBLE);
                }
            }
        });
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.iv_close:
                dismiss();
                break;
            case R.id.btn_submit:
                onSubmit();
                break;
        }
    }

    private void onSubmit() {
        ConfigParams params;
        switch (mRadioGroup.getCheckedRadioButtonId()) {
            case R.id.rd_02:
                params = new ConfigParams(RCRTCMixConfig.MixLayoutMode.SUSPENSION);
                params.isCrop = mScSuspendCrop.isChecked();
                break;
            case R.id.rd_03:
                params = new ConfigParams(RCRTCMixConfig.MixLayoutMode.CUSTOM);
                params.height = mCustomLayout.getVideoHeight();
                params.width = mCustomLayout.getVideoWidth();
                params.x = mCustomLayout.getVideoX();
                params.y = mCustomLayout.getVideoY();
                params.isCrop = mCustomLayout.isCropVideo();
                break;
                default:
            case R.id.rd_01:
                params = new ConfigParams(RCRTCMixConfig.MixLayoutMode.ADAPTIVE);
                params.isCrop = mScAdaptiveCrop.isChecked();
                break;
        }
        if (mConfigChangeListener != null){
            mConfigChangeListener.onChange(params);
        }
        dismiss();
    }

    public ConfigChangeListener getConfigChangeListener() {
        return mConfigChangeListener;
    }

    public LayoutConfigDialog setConfigChangeListener(ConfigChangeListener configChangeListener) {
        mConfigChangeListener = configChangeListener;
        return this;
    }

    public interface ConfigChangeListener{
        void onChange(ConfigParams params);
    }

    public static class ConfigParams implements Serializable {

        public final RCRTCMixConfig.MixLayoutMode model;   // 2和3不用指定 input   1. 自定义布局， 2:悬浮布局(默认)，3：自适应布局；
        public int x;
        public int y;
        public int width;
        public int height;
        public boolean isCrop;  // 1:crop裁剪填充 ；2:whole

        public ConfigParams(RCRTCMixConfig.MixLayoutMode model) {
            this.model = model;
        }
    }

}
