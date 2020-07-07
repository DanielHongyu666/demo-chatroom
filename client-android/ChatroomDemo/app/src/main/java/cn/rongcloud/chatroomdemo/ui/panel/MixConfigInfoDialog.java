package cn.rongcloud.chatroomdemo.ui.panel;

import android.app.Dialog;
import android.app.DialogFragment;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.LinearLayout;
import android.widget.TextView;

import cn.rongcloud.rtc.api.RCRTCMixConfig;
import java.util.List;

import cn.rongcloud.chatroomdemo.R;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;
import static android.view.ViewGroup.LayoutParams.WRAP_CONTENT;

/**
 * Created by wangw on 2019-12-24.
 */
public class MixConfigInfoDialog extends DialogFragment implements View.OnClickListener {


    private LinearLayout mLlInfos;


    public static MixConfigInfoDialog newInstance(RCRTCMixConfig config) {

        Bundle args = new Bundle();
        args.putParcelable("config",config);
        MixConfigInfoDialog fragment = new MixConfigInfoDialog();
        fragment.setArguments(args);
        return fragment;
    }


    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.widget_mcuconfig_info_panel, container, false);
        mLlInfos = view.findViewById(R.id.ll_infos);
        view.findViewById(R.id.iv_close).setOnClickListener(this);
        view.findViewById(R.id.btn_close).setOnClickListener(this);
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
        window.setGravity(Gravity.CENTER);
        window.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        RCRTCMixConfig config = getArguments().getParcelable("config");
        initItems(config.getCustomLayouts());
    }

    private void initItems(List<RCRTCMixConfig.CustomLayoutList.CustomLayout> customLayoutList) {
        mLlInfos.removeAllViews();
        if (customLayoutList == null || customLayoutList.isEmpty())
            return;
        for (RCRTCMixConfig.CustomLayoutList.CustomLayout video : customLayoutList) {
            mLlInfos.addView(createItemView(video,mLlInfos.getChildCount()));
        }
    }

    private View createItemView(RCRTCMixConfig.CustomLayoutList.CustomLayout video,int index) {
        View view = LayoutInflater.from(getActivity()).inflate(R.layout.widget_mcuconfig_info_item, mLlInfos,false);
        setText(view,R.id.tv_name,index == 0 ? "H" : "M"+(index)+":");
        setText(view,R.id.tv_x,"X "+video.getX());
        setText(view,R.id.tv_y,"Y "+video.getY());
        setText(view,R.id.tv_w,"宽 "+video.getWidth());
        setText(view,R.id.tv_h,"高 "+video.getHeight());
        return view;
    }

    private void setText(View view,int id,String txt){
        ((TextView)view.findViewById(id)).setText(txt);
    }

    public void onClick(View v){
        dismiss();
    }
}
