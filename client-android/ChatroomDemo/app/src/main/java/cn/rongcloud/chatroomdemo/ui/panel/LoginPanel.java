package cn.rongcloud.chatroomdemo.ui.panel;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.Toast;

import cn.rongcloud.chatroomdemo.ChatroomKit;
import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import io.rong.message.ChatroomWelcome;

/**
 * Created by duanliuyi on 2018/5/28.
 */

public class LoginPanel extends LinearLayout {

    private Button btnLogin;

    public LoginPanel(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView(context);
    }

    private void initView(final Context context) {
        final View layout = LayoutInflater.from(getContext()).inflate(R.layout.widget_login_panel, this);
        btnLogin = (Button) findViewById(R.id.btn_login);

        btnLogin.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (ChatroomKit.getCurrentUser() != null) {
                    Toast.makeText(getContext(), "已登录", Toast.LENGTH_SHORT).show();
                    layout.setVisibility(GONE);
                    DataInterface.setLoginStatus(true);
                    ChatroomWelcome welcomeMessage = new ChatroomWelcome();
                    welcomeMessage.setId(ChatroomKit.getCurrentUser().getUserId());
                    ChatroomKit.sendMessage(welcomeMessage);
                } else {
                    Toast.makeText(getContext(), "网络异常", Toast.LENGTH_SHORT).show();
                }
            }
        });


    }
}
