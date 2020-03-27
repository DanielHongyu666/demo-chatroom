package cn.rongcloud.chatroomdemo.messageview;


import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import io.rong.imlib.model.MessageContent;
import io.rong.message.ChatroomLike;

/**
 * Created by duanliuyi on 2018/5/23.
 */

public class LikeMsgView extends BaseMsgView {

    private TextView username;
    private TextView infoText;

    public LikeMsgView(Context context) {
        super(context);
        View view = LayoutInflater.from(getContext()).inflate(R.layout.msg_info_view, this);
        username = (TextView) view.findViewById(R.id.username);
        infoText = (TextView) view.findViewById(R.id.info_text);
    }

    @Override
    protected void onBindContent(MessageContent msgContent, String senderUserId) {
        String name = getSendUserName();
        username.setText(name + "  ");
        infoText.setText("给主播点了" + ((ChatroomLike) msgContent).getCounts() + "个赞");

    }
}
