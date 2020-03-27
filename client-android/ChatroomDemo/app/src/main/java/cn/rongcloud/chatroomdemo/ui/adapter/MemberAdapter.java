package cn.rongcloud.chatroomdemo.ui.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;

import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.model.OnlineUserInfo;
import cn.rongcloud.chatroomdemo.model.RoleType;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import io.rong.imlib.model.UserInfo;

/**
 * Created by duanliuyi on 2018/5/18.
 */

public class MemberAdapter extends BaseAdapter {

    private ArrayList<OnlineUserInfo> infos;
    private Context mContext;
    private boolean isTop;

    public MemberAdapter(Context context, ArrayList<OnlineUserInfo> infos, boolean isTop) {
        this.mContext = context;
        this.infos = infos;
        this.isTop = isTop;
    }

    @Override
    public Object getItem(int i) {
        return infos.get(i);
    }

    @Override
    public View getView(int i, View view, ViewGroup viewGroup) {
        ViewHolder viewHolder = null;
        if (view == null) {
            viewHolder = new ViewHolder();
            view = LayoutInflater.from(mContext).inflate(R.layout.item_member, null);
            viewHolder.tvName = view.findViewById(R.id.tv_member_name);
            viewHolder.icon = view.findViewById(R.id.iv_member_avatar);
            viewHolder.optView = view.findViewById(R.id.tv_option);
            view.setTag(viewHolder);
        } else {
            viewHolder = (ViewHolder) view.getTag();
        }

        OnlineUserInfo user = infos.get(i);
        viewHolder.icon.setImageURI(user.getPortraitUri());
        if (isTop) {
            viewHolder.tvName.setVisibility(View.GONE);
        } else {
            viewHolder.tvName.setVisibility(View.VISIBLE);
            viewHolder.tvName.setText(user.getName());
            viewHolder.optView.setVisibility(View.VISIBLE);
            viewHolder.optView.setEnabled(user.roleType == RoleType.VIEWER);
        }
        return view;
    }

    @Override
    public int getCount() {
        return infos.size();
    }

    public ArrayList<OnlineUserInfo> getDatas() {
        return infos;
    }

    @Override
    public long getItemId(int i) {
        return i;
    }

    public void addItem(OnlineUserInfo userInfo) {
        removeItemByUid(userInfo.getUserId());
        infos.add(userInfo);
        notifyDataSetChanged();
    }

    public void removeItem(int i) {
        if(i < getCount()){
            infos.remove(i);
            notifyDataSetChanged();
        }
    }

    public void removeItemByUid(String uid) {
        int i;
        for (i = 0; i < getCount(); i++) {
            if(TextUtils.equals(((UserInfo)getItem(i)).getUserId(),uid)){
                break;
            }
        }
        if (i < getCount()){
            removeItem(i);
        }
    }


    class ViewHolder {
        ImageView icon;
        TextView tvName;
        View optView;
    }


}
