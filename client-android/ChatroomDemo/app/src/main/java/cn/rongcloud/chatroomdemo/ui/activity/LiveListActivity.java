package cn.rongcloud.chatroomdemo.ui.activity;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentActivity;
import android.view.View;
import android.widget.AdapterView;
import android.widget.GridView;
import android.widget.Toast;

import java.util.ArrayList;

import cn.rongcloud.chatroomdemo.ChatroomKit;
import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.model.ChatroomInfo;
import cn.rongcloud.chatroomdemo.ui.adapter.LiveListAdapter;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import io.rong.imlib.RongIMClient;

/**
 * Created by duanliuyi on 2018/5/9.
 */

public class LiveListActivity extends FragmentActivity {

    GridView mGridView;
    LiveListAdapter mAdapter;


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_live_list);

        mGridView = (GridView) findViewById(R.id.gridview_live);


        final ArrayList<ChatroomInfo> infos = DataInterface.getChatroomList();
        mAdapter = new LiveListAdapter(LiveListActivity.this, infos);
        mGridView.setAdapter(mAdapter);
        mGridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, final int i, long l) {
                if (RongIMClient.getInstance().getCurrentConnectionStatus() == RongIMClient.ConnectionStatusListener.ConnectionStatus.CONNECTED) {
                    Intent intent = new Intent(LiveListActivity.this, LiveShowActivity.class);
                    intent.putExtra("liveid", infos.get(i).getLiveId());
                    startActivity(intent);
                } else {
                    Toast.makeText(LiveListActivity.this, "未连接", Toast.LENGTH_SHORT).show();
                }


            }
        });


    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        ChatroomKit.logout();
    }
}
