package cn.rongcloud.chatroomdemo.ui.activity;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;

import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.model.ChatroomInfo;
import cn.rongcloud.chatroomdemo.model.RoleType;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import cn.rongcloud.chatroomdemo.utils.LogUtils;

/**
 * Created by wangw on 2019-09-03.
 */
public class CreateLiveRoomActivity extends BaseActivity implements View.OnClickListener, TextWatcher {

    private final int[] COVERS = {R.drawable.chatroom_01,
            R.drawable.chatroom_02,
            R.drawable.chatroom_03,
            R.drawable.chatroom_04,
            R.drawable.chatroom_05,
            R.drawable.chatroom_06};

    private ImageView mIvCover;
    private EditText mEvRoomname;
    private EditText mEvUserName;
    private Button mBtnStart;
    private int mCoverIndex;
    private final String TAG = "CreateLiveRoomActivity";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_liveroom);
        onInitViews();
    }

    private void onInitViews() {
        mIvCover = findViewById(R.id.iv_cover);
        mEvRoomname = findViewById(R.id.ev_roomname);
        mBtnStart = findViewById(R.id.btn_start);

        mCoverIndex = DataInterface.getRandomNum(COVERS.length);
        mIvCover.setImageResource(COVERS[mCoverIndex]);
        mBtnStart.setOnClickListener(this);
        mEvRoomname.addTextChangedListener(this);
        mEvUserName = findViewById(R.id.ev_username);
        if (DataInterface.isLogin()){
            mEvUserName.setEnabled(false);
            mEvUserName.setText(DataInterface.getUserName());
        }

        mEvUserName.addTextChangedListener(this);
        findViewById(R.id.iv_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

    }

    @Override
    public void onClick(View v) {
        startLive();
    }

    private void startLive() {
        mBtnStart.setEnabled(false);
        if (!DataInterface.isLogin()) {
            String userName = mEvUserName.getText().toString().trim();
            if (TextUtils.isEmpty(userName)) {
                showToast("主播名称不能为空");
                return;
            }
        }

        String roomName = String.valueOf(mEvRoomname.getText()).trim();
        if (TextUtils.isEmpty(roomName)) {
            showToast("直播间名称不能为空");
            return;
        }
        LogUtils.i(TAG, "startLive userName = "+mEvUserName.getText().toString()+" | roomName="+mEvRoomname.getText().toString());
        if (!DataInterface.isLogin()){
            DataInterface.setLogin(mEvUserName.getText().toString().trim());
        }
        ChatroomInfo chatroomInfo = new ChatroomInfo(roomName, roomName, null, DataInterface.getUserId(), mCoverIndex);
        RoomInfoActivity.jumpTo(CreateLiveRoomActivity.this,chatroomInfo,RoleType.HOST);
        finish();
    }


    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {
    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {
    }

    @Override
    public void afterTextChanged(Editable s) {
        if (DataInterface.isLogin()) {
            mBtnStart.setEnabled(!TextUtils.isEmpty(mEvRoomname.getText()));
        }else {
            mBtnStart.setEnabled((!TextUtils.isEmpty(mEvRoomname.getText())) && (!TextUtils.isEmpty(mEvUserName.getText())));
        }
    }
}
