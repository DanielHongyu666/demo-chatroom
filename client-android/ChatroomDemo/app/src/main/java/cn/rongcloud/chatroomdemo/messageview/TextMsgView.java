package cn.rongcloud.chatroomdemo.messageview;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.ui.panel.EmojiManager;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import io.rong.imlib.model.MessageContent;
import io.rong.message.TextMessage;

public class TextMsgView extends BaseMsgView {

    private TextView username;
    private TextView msgText;

    public TextMsgView(Context context) {
        super(context);
        View view = LayoutInflater.from(getContext()).inflate(R.layout.msg_text_view, this);
        username = (TextView) view.findViewById(R.id.username);
        msgText = (TextView) view.findViewById(R.id.msg_text);
    }

    @Override
    public void setContent(MessageContent msgContent, String senderUserId) {
        TextMessage msg = (TextMessage) msgContent;
        username.setText(DataInterface.getUserInfo(senderUserId).getName() + ": ");
        msgText.setText(EmojiManager.parse(msg.getContent(), msgText.getTextSize()));
        msgText.setText(msg.getContent());

    }
}
