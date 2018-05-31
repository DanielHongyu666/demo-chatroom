package cn.rongcloud.chatroomdemo.ui.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;

import cn.rongcloud.chatroomdemo.R;
import io.rong.imlib.model.UserInfo;

/**
 * Created by duanliuyi on 2018/5/18.
 */

public class MemberAdapter extends BaseAdapter {

    private ArrayList<UserInfo> infos;
    private Context mContext;
    private boolean isTop;

    public MemberAdapter(Context context, ArrayList<UserInfo> infos, boolean isTop) {
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
            view.setTag(viewHolder);
        } else {
            viewHolder = (ViewHolder) view.getTag();
        }

        UserInfo user = infos.get(i);
        viewHolder.icon.setImageURI(user.getPortraitUri());
        if (isTop) {
            viewHolder.tvName.setVisibility(View.GONE);
        } else {
            viewHolder.tvName.setVisibility(View.VISIBLE);
            viewHolder.tvName.setText(user.getName());
        }


        return view;
    }

    @Override
    public int getCount() {
        return infos.size();
    }

    @Override
    public long getItemId(int i) {
        return i;
    }


    class ViewHolder {
        ImageView icon;
        TextView tvName;
    }


}
