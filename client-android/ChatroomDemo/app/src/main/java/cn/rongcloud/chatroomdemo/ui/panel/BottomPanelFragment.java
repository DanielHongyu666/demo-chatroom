package cn.rongcloud.chatroomdemo.ui.panel;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import org.greenrobot.eventbus.EventBus;

import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.model.NeedLoginEvent;
import cn.rongcloud.chatroomdemo.utils.DataInterface;


public class BottomPanelFragment extends Fragment {

    private static final String TAG = "BottomPanelFragment";

    private ViewGroup buttonPanel;
    private ImageView btnInput;
    private InputPanel inputPanel;
    private GiftPanel giftPanel;
    private ImageView btnGift;
    private ImageView btnHeart;
    private ImageView btnBarrage;
    private BanListener banListener;


    public interface BanListener {
        void addBanWarn();
    }

    public void setBanListener(BanListener banListener) {
        this.banListener = banListener;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_bottombar, container);
        buttonPanel = (ViewGroup) view.findViewById(R.id.button_panel);
        btnInput = (ImageView) view.findViewById(R.id.btn_input);
        inputPanel = (InputPanel) view.findViewById(R.id.input_panel);
        giftPanel = (GiftPanel) view.findViewById(R.id.gift_panel);
        btnGift = (ImageView) view.findViewById(R.id.btn_gift);
        btnHeart = (ImageView) view.findViewById(R.id.btn_heart);
        btnBarrage = (ImageView) view.findViewById(R.id.btn_barrage);

        btnInput.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isLoginAndCanInput()) {
                    inputPanel.setVisibility(View.VISIBLE);
                    inputPanel.setType(InputPanel.TYPE_TEXTMESSAGE);
                }
            }
        });

        btnBarrage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (isLoginAndCanInput()) {
                    inputPanel.setVisibility(View.VISIBLE);
                    inputPanel.setType(InputPanel.TYPE_BARRAGE);
                }
            }
        });

        btnGift.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (isLogin()) {
                    giftPanel.setVisibility(View.VISIBLE);
                }
            }
        });
        return view;
    }

    public boolean isLogin() {
        if (DataInterface.isLoginStatus()) {
            return true;
        } else {
            EventBus.getDefault().post(new NeedLoginEvent(true));
            return false;
        }
    }

    public boolean isLoginAndCanInput() {
        if (DataInterface.isLoginStatus()) {
            if (DataInterface.isBanStatus()) {
                if (banListener != null) {
                    banListener.addBanWarn();
                }
                return false;
            }
            return true;
        } else {
            EventBus.getDefault().post(new NeedLoginEvent(true));
            return false;
        }
    }


    /**
     * back键或者空白区域点击事件处理
     *
     * @return 已处理true, 否则false
     */
    public boolean onBackAction() {
        if (inputPanel.onBackAction()) {
            return true;
        }
        if (inputPanel.getVisibility() == View.VISIBLE || giftPanel.getVisibility() == View.VISIBLE) {
            inputPanel.setVisibility(View.GONE);
            giftPanel.setVisibility(View.GONE);
            buttonPanel.setVisibility(View.VISIBLE);
            return true;
        }
        return false;
    }

    public void setInputPanelListener(InputPanel.InputPanelListener l) {
        inputPanel.setPanelListener(l);
    }


}
