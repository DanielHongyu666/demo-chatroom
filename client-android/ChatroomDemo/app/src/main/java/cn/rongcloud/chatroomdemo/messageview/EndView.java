package cn.rongcloud.chatroomdemo.messageview;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import cn.rongcloud.chatroomdemo.R;
import io.rong.imlib.model.MessageContent;
import io.rong.message.ChatroomEnd;

/**
 * Created by duanliuyi on 2018/6/20.
 */

public class EndView extends BaseMsgView {

    private TextView tvInfo;

    public EndView(Context context) {
        super(context);
        View view = LayoutInflater.from(getContext()).inflate(R.layout.msg_system_view, this);
        tvInfo = (TextView) view.findViewById(R.id.tv_system_info);
    }

    @Override
    public void setContent(MessageContent msgContent, String senderUserId) {
        if (msgContent instanceof ChatroomEnd) {
            int duration = ((ChatroomEnd) msgContent).getDuration();
            //  String time = CommonUtils.getTime(duration / 1000);

            tvInfo.setText("系统通知  本次直播已结束，直播时长" + duration + "分钟");
        }

    }


}
