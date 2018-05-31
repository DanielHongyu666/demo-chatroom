package cn.rongcloud.chatroomdemo.ui.panel;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;
import android.widget.ListView;

import cn.rongcloud.chatroomdemo.ChatroomKit;
import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.ui.adapter.MemberAdapter;
import cn.rongcloud.chatroomdemo.utils.DataInterface;

/**
 * Created by duanliuyi on 2018/5/18.
 */

public class OnlineUserPanel extends LinearLayout {

    private ListView lvUser;
    private MemberAdapter adapter;

    public OnlineUserPanel(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView(context);
    }

    private void initView(final Context context) {
        LayoutInflater.from(getContext()).inflate(R.layout.widget_online_user, this);
        lvUser = findViewById(R.id.lv_online_user);
        adapter = new MemberAdapter(context, DataInterface.getUserList(ChatroomKit.getCurrentRoomId()), false);
        lvUser.setAdapter(adapter);

    }
}
