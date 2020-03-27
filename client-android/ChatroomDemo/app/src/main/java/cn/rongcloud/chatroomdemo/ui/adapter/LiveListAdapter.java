package cn.rongcloud.chatroomdemo.ui.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.model.ChatroomInfo;

/**
 * Created by duanliuyi on 2018/5/9.
 */

public class LiveListAdapter extends BaseAdapter {

    ArrayList<ChatroomInfo> chatroomInfos;
    Context mContext;

    public LiveListAdapter(Context mContext, ArrayList<ChatroomInfo> chatroomInfos) {
        this.chatroomInfos = chatroomInfos;
        this.mContext = mContext;
    }

    @Override
    public int getCount() {
        return chatroomInfos.size();
    }

    @Override
    public Object getItem(int i) {
        return chatroomInfos.get(i);
    }

    @Override
    public long getItemId(int i) {
        return i;
    }

    @Override
    public View getView(int i, View view, ViewGroup viewGroup) {
        ViewHolder viewHolder = null;
        if (view == null) {
            viewHolder = new ViewHolder();
            view = LayoutInflater.from(mContext).inflate(R.layout.item_live_list, null);
            viewHolder.tvLiveName = view.findViewById(R.id.tv_live_name);
//            viewHolder.tvOnlineNum = view.findViewById(R.id.tv_live_onlinenum);
//            viewHolder.tvLiveStatus = view.findViewById(R.id.tv_live_status);
            viewHolder.ivPic = view.findViewById(R.id.iv_live_pic);
            view.setTag(viewHolder);
        } else {
            viewHolder = (ViewHolder) view.getTag();
        }

        ChatroomInfo info = chatroomInfos.get(i);
        viewHolder.tvLiveName.setText(info.getLiveName());
//        viewHolder.tvLiveStatus.setText(info.getLiveStatus());
//        viewHolder.tvOnlineNum.setText(info.getOnlineNum() + "");
        viewHolder.ivPic.setImageURI(info.getCover());

        return view;
    }

    public void refreshData(List<ChatroomInfo> roomList) {
        chatroomInfos.clear();
        if (roomList !=null)
            chatroomInfos.addAll(roomList);
        notifyDataSetChanged();
    }


    class ViewHolder {
        TextView tvLiveName;
//        TextView tvLiveStatus;
//        TextView tvOnlineNum;
        ImageView ivPic;
    }
}
