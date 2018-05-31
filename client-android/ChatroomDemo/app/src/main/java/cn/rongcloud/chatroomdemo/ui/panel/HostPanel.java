package cn.rongcloud.chatroomdemo.ui.panel;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import org.greenrobot.eventbus.EventBus;

import cn.rongcloud.chatroomdemo.ChatroomKit;
import cn.rongcloud.chatroomdemo.model.NeedLoginEvent;
import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import io.rong.message.ChatroomFollow;

/**
 * Created by duanliuyi on 2018/5/18.
 */

public class HostPanel extends LinearLayout {

    private TextView tvFocus;
    private TextView tvFansNum;
    private TextView tvLikeNum;
    private TextView tvGiftNum;
    private TextView tvHostName;
    private CircleImageView ivHostAvatar;


    public HostPanel(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView(context);
    }

    private void initView(final Context context) {
        final View layout = LayoutInflater.from(getContext()).inflate(R.layout.widget_host_panel, this);
        tvFocus = (TextView) findViewById(R.id.tv_focus);
        tvFansNum = (TextView) findViewById(R.id.tv_fans);
        tvLikeNum = (TextView) findViewById(R.id.tv_zan);
        tvGiftNum = (TextView) findViewById(R.id.tv_gift);
        tvHostName = (TextView) findViewById(R.id.tv_host_name);
        ivHostAvatar = (CircleImageView) findViewById(R.id.iv_host_avatar);

        tvFocus.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (DataInterface.isLoginStatus()) {
                    ChatroomFollow follow = new ChatroomFollow();
                    follow.setId(ChatroomKit.getCurrentUser().getUserId());
                    ChatroomKit.sendMessage(follow);

                    Toast.makeText(context, "已关注主播", Toast.LENGTH_SHORT).show();
                    layout.setVisibility(GONE);
                    tvFocus.setText("已关注");
                    tvFocus.setEnabled(false);
                } else {
                    EventBus.getDefault().post(new NeedLoginEvent(true));
                }

            }
        });


    }

    public void setHostPanelNum(int fansNum, int likeNum, int giftNum) {
        tvFansNum.setText("粉丝：" + fansNum);
        tvLikeNum.setText("获赞：" + likeNum);
        tvGiftNum.setText("礼物：" + giftNum);
    }

    public void setFansNum(int fansNum) {
        tvFansNum.setText("粉丝：" + fansNum);
    }

    public void setLikeNum(int likeNum) {
        tvLikeNum.setText("获赞：" + likeNum);
    }

    public void setGiftNum(int giftNum) {
        tvGiftNum.setText("礼物：" + giftNum);
    }

    public void setHostInfo(String name, int avatar) {
        tvHostName.setText(name);
        ivHostAvatar.setImageResource(avatar);
    }

    public void setHostName(String name) {
        tvHostName.setText(name);
    }
}
