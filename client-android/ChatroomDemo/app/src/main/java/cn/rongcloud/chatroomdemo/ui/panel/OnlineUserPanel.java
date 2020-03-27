package cn.rongcloud.chatroomdemo.ui.panel;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.LinearLayout;
import android.widget.ListView;

import java.util.ArrayList;
import java.util.List;

import cn.rongcloud.chatroomdemo.ChatroomKit;
import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.model.OnlineUserInfo;
import cn.rongcloud.chatroomdemo.ui.adapter.MemberAdapter;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import io.rong.imlib.model.UserInfo;

/**
 * Created by duanliuyi on 2018/5/18.
 */

public class OnlineUserPanel extends LinearLayout {

    private ListView lvUser;
    private MemberAdapter adapter;
    private  UserPanelItemClickListenr mListenr;

    public OnlineUserPanel(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView(context);
    }

    private void initView(final Context context) {
        LayoutInflater.from(getContext()).inflate(R.layout.widget_online_user, this);
        lvUser = findViewById(R.id.lv_online_user);
//        DataInterface.getUserList(ChatroomKit.getCurrentRoomId())
        adapter = new MemberAdapter(context,new ArrayList<OnlineUserInfo>(), false);
        lvUser.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                if (mListenr != null)
                    mListenr.onItemClick((UserInfo) adapter.getItem(position));
            }
        });
        lvUser.setAdapter(adapter);
    }

    public void setListenr(UserPanelItemClickListenr listenr) {
        mListenr = listenr;
    }

    public void addUser(OnlineUserInfo userInfo){
        adapter.addItem(userInfo);
    }

    public void removeUser(String uid){
        adapter.removeItemByUid(uid);
    }

    public OnlineUserInfo getUserInfo(String uid) {
        for (int i = 0; i < adapter.getCount(); i++) {
            if (TextUtils.equals(((UserInfo)adapter.getItem(i)).getUserId(),uid)){
                return (OnlineUserInfo) adapter.getItem(i);
            }
        }
        return null;
    }

    public List<OnlineUserInfo> getAllUsers(){
        if (adapter != null)
            return adapter.getDatas();
        return null;
    }

    public void notifyDataSetChanged() {
        if (adapter != null){
            adapter.notifyDataSetChanged();
        }
    }

    public interface UserPanelItemClickListenr{
        void onItemClick(UserInfo info);
    }
}
