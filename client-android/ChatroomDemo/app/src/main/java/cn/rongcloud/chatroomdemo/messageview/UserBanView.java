package cn.rongcloud.chatroomdemo.messageview;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import io.rong.imlib.model.MessageContent;
import io.rong.message.ChatroomUserBan;

/**
 * Created by duanliuyi on 2018/6/20.
 */

public class UserBanView extends BaseMsgView {

    private TextView tvInfo;

    public UserBanView(Context context) {
        super(context);
        View view = LayoutInflater.from(getContext()).inflate(R.layout.msg_system_view, this);
        tvInfo = (TextView) view.findViewById(R.id.tv_system_info);
    }

    @Override
    public void setContent(MessageContent msgContent, String senderUserId) {
        if (msgContent instanceof ChatroomUserBan) {
            String id = ((ChatroomUserBan) msgContent).getId();
            String name = "";
            if (DataInterface.getUserInfo(id) != null) {
                name = DataInterface.getUserInfo(id).getName();
            } else {
                name = id;
            }
            int duration = ((ChatroomUserBan) msgContent).getDuration();
            tvInfo.setText("系统消息  " + name + " 被禁言 " + duration / 1000 / 60 + " 分钟");
        }

    }
}
