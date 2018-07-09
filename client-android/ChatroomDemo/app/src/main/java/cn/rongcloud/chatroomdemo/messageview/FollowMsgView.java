package cn.rongcloud.chatroomdemo.messageview;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import io.rong.imlib.model.MessageContent;

public class FollowMsgView extends BaseMsgView {

    private TextView username;
    private TextView infoText;

    public FollowMsgView(Context context) {
        super(context);
        View view = LayoutInflater.from(getContext()).inflate(R.layout.msg_info_view, this);
        username = (TextView) view.findViewById(R.id.username);
        infoText = (TextView) view.findViewById(R.id.info_text);
    }

    @Override
    public void setContent(MessageContent msgContent, String senderUserId) {
        String name = "";
        if (DataInterface.getUserInfo(senderUserId) != null) {
            name = DataInterface.getUserInfo(senderUserId).getName();
        } else {
            name = senderUserId;
        }

        username.setText(name + "  ");
        infoText.setText("关注了主播");

    }
}
