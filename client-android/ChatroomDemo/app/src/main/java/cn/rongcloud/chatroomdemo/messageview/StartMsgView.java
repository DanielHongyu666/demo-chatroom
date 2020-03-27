package cn.rongcloud.chatroomdemo.messageview;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.utils.CommonUtils;
import io.rong.imlib.model.MessageContent;
import io.rong.message.ChatroomStart;

/**
 * Created by duanliuyi on 2018/6/20.
 */

public class StartMsgView extends BaseMsgView {

    private TextView tvInfo;

    public StartMsgView(Context context) {
        super(context);
        View view = LayoutInflater.from(getContext()).inflate(R.layout.msg_system_view, this);
        tvInfo = (TextView) view.findViewById(R.id.tv_system_info);
    }

    @Override
    protected void onBindContent(MessageContent msgContent, String senderUserId) {
        if (msgContent instanceof ChatroomStart) {
            String time = ((ChatroomStart) msgContent).getTime();
            long timeLong = Long.valueOf(time);
            String timeString = CommonUtils.getDateToString(timeLong, "yyyy-MM-dd HH:mm:ss");

            tvInfo.setText("系统通知  " + timeString + "  开始直播");
        }

    }
}
