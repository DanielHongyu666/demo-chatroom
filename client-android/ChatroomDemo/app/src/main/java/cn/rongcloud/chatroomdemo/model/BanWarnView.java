package cn.rongcloud.chatroomdemo.model;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.messageview.BaseMsgView;
import io.rong.imlib.model.MessageContent;

/**
 * Created by duanliuyi on 2018/6/25.
 */

public class BanWarnView extends BaseMsgView {
    private TextView tvInfo;

    public BanWarnView(Context context) {
        super(context);
        View view = LayoutInflater.from(getContext()).inflate(R.layout.msg_system_view, this);
        tvInfo = (TextView) view.findViewById(R.id.tv_system_info);
    }

    @Override
    protected void onBindContent(MessageContent msgContent, String senderUserId) {
        tvInfo.setText("系统消息  已被管理员禁言");
        tvInfo.setTextColor(getResources().getColor(R.color.red));

    }

}
