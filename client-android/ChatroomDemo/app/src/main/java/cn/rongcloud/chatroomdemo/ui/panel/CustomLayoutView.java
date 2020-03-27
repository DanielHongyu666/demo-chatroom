package cn.rongcloud.chatroomdemo.ui.panel;

import android.content.Context;
import android.support.annotation.Nullable;
import android.support.v7.widget.SwitchCompat;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import cn.rongcloud.chatroomdemo.R;

/**
 * Created by wangw on 2019-12-02.
 */
public class CustomLayoutView extends LinearLayout {

    private static final float RATIO = 3*1.0f/4;
    private static final int MAX_NUM = 6;
    private SwitchCompat mScCrop;
    private EditText mEvX;
    private TextView mTvY;
    private TextView mTvWidth;
    private EditText mEvHeight;

    private int mVW;
    private int mVH;
    private int mMaxHeight;
    private int mMaxX;


    public CustomLayoutView(Context context) {
        super(context);
        onInitView();
    }

    public CustomLayoutView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        onInitView();
    }

    public CustomLayoutView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        onInitView();
    }

    private void onInitView() {
        inflate(getContext(), R.layout.layout_custom_view, this);
        setOrientation(VERTICAL);
        findViews();
        setListener();
    }

    public void setViews(LayoutConfigDialog.ConfigParams params) {
        mScCrop.setChecked(params.isCrop);
        mEvHeight.setText(params.height+"");
        mEvX.setText(params.x+"");
    }

    private void setListener() {
        mEvX.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (getIntValue(mEvX) > mMaxX) {
                    mEvX.setText(mMaxX +"");
                }
            }
        });
        mEvHeight.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                countSize();
            }
        });
    }

    public void setVideoFrameSize(int width,int height){
        mVW = width;
        mVH = height;
        mMaxHeight = mVH/MAX_NUM;
        countSize();
    }

    private void countSize() {
        if (mVH == 0 || mVW == 0)
            return;
        int h = getIntValue(mEvHeight);
        if (h == 0 || h > mMaxHeight){
            h = mMaxHeight;
            mEvHeight.setText(h+"");
        }
        int w = (int) (h * RATIO);
        mMaxX =mVW - w;
        mTvWidth.setText(""+ w);
        mEvX.setText(""+mMaxX);
    }


    private void findViews() {
        mScCrop = (SwitchCompat)findViewById( R.id.sc_crop );
        mEvX = (EditText)findViewById( R.id.ev_x );
        mTvY = (TextView)findViewById( R.id.tv_y );
        mTvWidth = (TextView)findViewById( R.id.tv_width );
        mEvHeight = (EditText)findViewById( R.id.ev_height );
    }

    public int getVideoX(){
        return getIntValue(mEvX);
    }

    public int getVideoY(){
        return getIntValue(mTvY);
    }

    private int getIntValue(TextView tvY) {
        try {
            return Integer.parseInt(tvY.getText().toString());
        }catch (Exception e){
            e.printStackTrace();
        }
        return 0;
    }

    public int getVideoWidth(){
        return getIntValue(mTvWidth);
    }

    public int getVideoHeight(){
        return getIntValue(mEvHeight);
    }

    public boolean isCropVideo(){
        return mScCrop.isChecked();
    }


}
