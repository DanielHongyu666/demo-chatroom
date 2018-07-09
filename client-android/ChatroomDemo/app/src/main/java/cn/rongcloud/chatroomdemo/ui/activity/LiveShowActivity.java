package cn.rongcloud.chatroomdemo.ui.activity;

import android.content.DialogInterface;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.FragmentActivity;
import android.support.v7.app.AlertDialog;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.orzangleli.xdanmuku.DanmuContainerView;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;

import java.util.Random;

import cn.rongcloud.chatroomdemo.ChatroomKit;
import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.model.BanWarnMessage;
import cn.rongcloud.chatroomdemo.model.HostInfo;
import cn.rongcloud.chatroomdemo.model.NeedLoginEvent;
import cn.rongcloud.chatroomdemo.ui.adapter.ChatListAdapter;
import cn.rongcloud.chatroomdemo.ui.adapter.MemberAdapter;
import cn.rongcloud.chatroomdemo.ui.danmu.DanmuAdapter;
import cn.rongcloud.chatroomdemo.ui.danmu.DanmuEntity;
import cn.rongcloud.chatroomdemo.ui.gift.GiftSendModel;
import cn.rongcloud.chatroomdemo.ui.gift.GiftView;
import cn.rongcloud.chatroomdemo.ui.like.HeartLayout;
import cn.rongcloud.chatroomdemo.ui.panel.BottomPanelFragment;
import cn.rongcloud.chatroomdemo.ui.panel.CircleImageView;
import cn.rongcloud.chatroomdemo.ui.panel.HorizontalListView;
import cn.rongcloud.chatroomdemo.ui.panel.HostPanel;
import cn.rongcloud.chatroomdemo.ui.panel.InputPanel;
import cn.rongcloud.chatroomdemo.ui.panel.LoginPanel;
import cn.rongcloud.chatroomdemo.ui.panel.OnlineUserPanel;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageContent;
import io.rong.message.ChatroomBarrage;
import io.rong.message.ChatroomFollow;
import io.rong.message.ChatroomGift;
import io.rong.message.ChatroomLike;
import io.rong.message.ChatroomUserBan;
import io.rong.message.ChatroomUserBlock;
import io.rong.message.ChatroomUserQuit;
import io.rong.message.ChatroomUserUnBan;
import io.rong.message.ChatroomWelcome;
import io.rong.message.TextMessage;

public class LiveShowActivity extends FragmentActivity implements View.OnClickListener, Handler.Callback {

    public static final String LIVE_URL = "live_url";

    private ViewGroup background;
    private ListView chatListView;
    private BottomPanelFragment bottomPanel;
    // private ImageView btnGift;
    private ImageView btnHeart;
    private HeartLayout heartLayout;
    private SurfaceView surfaceView;
    private RelativeLayout layoutHost;
    private CircleImageView ivHostAvater;
    private TextView tvHostName;
    private HostPanel hostPanel;
    private HorizontalListView hlvMember;
    private MemberAdapter memberAdapter;
    private OnlineUserPanel onlineUserPanel;
    private LoginPanel loginPanel;
    private TextView tvOnlineNum;

    private Random random = new Random();
    private Handler handler = new Handler(this);
    private ChatListAdapter chatListAdapter;
    private String roomId;
    //  private KSYMediaPlayer ksyMediaPlayer;
    private SurfaceHolder surfaceHolder;
    private int onlineNum = 0;
    private int fansNum = 0;
    private int likeNum = 0;
    private int giftNum = 0;

    private DanmuContainerView danmuContainerView;
    private GiftView giftView;
    private String TAG = "LiveShowActivity";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_live_show);
        EventBus.getDefault().register(this);
        ChatroomKit.addEventHandler(handler);
        DataInterface.setLoginStatus(false);
        DataInterface.setBanStatus(false);
        roomId = getIntent().getStringExtra("liveid");
        initView();
        startLiveShow();
    }

    private void initView() {
        background = (ViewGroup) findViewById(R.id.background);
        chatListView = (ListView) findViewById(R.id.chat_listview);
        bottomPanel = (BottomPanelFragment) getSupportFragmentManager().findFragmentById(R.id.bottom_bar);
        // btnGift = (ImageView) bottomPanel.getView().findViewById(R.id.btn_gift);
        btnHeart = (ImageView) bottomPanel.getView().findViewById(R.id.btn_heart);
        heartLayout = (HeartLayout) findViewById(R.id.heart_layout);
        surfaceView = (SurfaceView) findViewById(R.id.player_surface);
        danmuContainerView = (DanmuContainerView) findViewById(R.id.danmuContainerView);
        layoutHost = (RelativeLayout) findViewById(R.id.layout_host);
        tvHostName = (TextView) findViewById(R.id.tv_holder_name);
        ivHostAvater = (CircleImageView) findViewById(R.id.iv_host_header);
        hostPanel = (HostPanel) findViewById(R.id.host_panel);
        hlvMember = (HorizontalListView) findViewById(R.id.gv_room_member);
        onlineUserPanel = (OnlineUserPanel) findViewById(R.id.online_user_panel);
        loginPanel = (LoginPanel) findViewById(R.id.login_panel);
        tvOnlineNum = (TextView) findViewById(R.id.tv_room_onlive_people);

        HostInfo hostInfo = DataInterface.getHostInfoByRoomId(roomId);
        tvHostName.setText(hostInfo.getName());
        ivHostAvater.setImageResource(hostInfo.getAvatarRes());
        hostPanel.setHostInfo(hostInfo.getName(), hostInfo.getAvatarRes());


        tvOnlineNum.setText(onlineNum + "");
        hostPanel.setHostPanelNum(fansNum, likeNum, giftNum);

        danmuContainerView.setAdapter(new DanmuAdapter(this));

        giftView = (GiftView) findViewById(R.id.giftView);
        giftView.setViewCount(2);
        giftView.init();

        memberAdapter = new MemberAdapter(this, DataInterface.getUserList(roomId), true);
        hlvMember.setAdapter(memberAdapter);

        chatListAdapter = new ChatListAdapter(this);
        chatListView.setAdapter(chatListAdapter);
        background.setOnClickListener(this);
        // btnGift.setOnClickListener(this);
        btnHeart.setOnClickListener(this);
        bottomPanel.setInputPanelListener(new InputPanel.InputPanelListener() {
            @Override
            public void onSendClick(String text, int type) {
                if (DataInterface.isBanStatus()) {
                    BanWarnMessage banWarnMessage = new BanWarnMessage();
                    Message message = Message.obtain(ChatroomKit.getCurrentUser().getUserId(), Conversation.ConversationType.CHATROOM, banWarnMessage);
                    chatListAdapter.addMessage(message);
                    chatListAdapter.notifyDataSetChanged();
                    return;
                }


                if (type == InputPanel.TYPE_TEXTMESSAGE) {
                    final TextMessage content = TextMessage.obtain(text);
                    ChatroomKit.sendMessage(content);
                } else if (type == InputPanel.TYPE_BARRAGE) {
                    ChatroomBarrage barrage = new ChatroomBarrage();
                    barrage.setContent(text);
                    ChatroomKit.sendMessage(barrage);
                }

            }
        });

        bottomPanel.setBanListener(new BottomPanelFragment.BanListener() {
            @Override
            public void addBanWarn() {
                BanWarnMessage banWarnMessage = new BanWarnMessage();
                Message message = Message.obtain(ChatroomKit.getCurrentUser().getUserId(), Conversation.ConversationType.CHATROOM, banWarnMessage);
                chatListAdapter.addMessage(message);
                chatListAdapter.notifyDataSetChanged();
            }
        });

        layoutHost.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                hostPanel.setVisibility(View.VISIBLE);
                onlineUserPanel.setVisibility(View.GONE);
            }
        });

        hlvMember.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                onlineUserPanel.setVisibility(View.VISIBLE);
                hostPanel.setVisibility(View.GONE);
            }
        });


    }

    private void startLiveShow() {
        //        String liveUrl = "rtmp://live.hkstv.hk.lxdns.com/live/hks";
        String liveUrl = getIntent().getStringExtra(LiveShowActivity.LIVE_URL);
        joinChatRoom(roomId);
        //   playShow(liveUrl);
    }

    private void joinChatRoom(final String roomId) {
        ChatroomKit.joinChatRoom(roomId, -1, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {

            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                Toast.makeText(LiveShowActivity.this, "聊天室加入失败! errorCode = " + errorCode, Toast.LENGTH_SHORT).show();
            }
        });
    }

    //    private void playShow(String liveUrl) {
    //        try {
    //            ksyMediaPlayer.setDataSource(liveUrl);
    //            ksyMediaPlayer.prepareAsync();
    //        } catch (IOException e) {
    //            e.printStackTrace();
    //        }
    //
    //        surfaceHolder = surfaceView.getHolder();
    //        surfaceHolder.addCallback(surfaceCallback);
    //    }

    @Override
    public void onBackPressed() {
        if (!bottomPanel.onBackAction()) {
            finish();
            return;
        }
    }


    long currentTime = 0;
    int clickCount = 0;

    //500毫秒后做检查，如果没有继续点击了，发消息
    public void checkAfter(final long lastTime) {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                if (lastTime == currentTime) {
                    ChatroomLike likeMessage = new ChatroomLike();
                    likeMessage.setCounts(clickCount);
                    ChatroomKit.sendMessage(likeMessage);

                    clickCount = 0;
                }
            }
        }, 500);
    }

    long banStartTime = 0;

    public void startBan(final long thisBanStartTime, long duration) {
        DataInterface.setBanStatus(true);

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                if (banStartTime == thisBanStartTime) {
                    DataInterface.setBanStatus(false);
                }
            }
        }, duration * 1000 * 60);
    }

    @Override
    public void onClick(View v) {

        if (v.equals(background)) {
            bottomPanel.onBackAction();
            hostPanel.setVisibility(View.GONE);
            onlineUserPanel.setVisibility(View.GONE);
            loginPanel.setVisibility(View.GONE);
        } else if (v.equals(btnHeart)) {
            if (DataInterface.isLoginStatus()) {
                heartLayout.post(new Runnable() {
                    @Override
                    public void run() {
                        int rgb = Color.rgb(random.nextInt(255), random.nextInt(255), random.nextInt(255));
                        heartLayout.addHeart(rgb);
                    }
                });
                clickCount++;
                currentTime = System.currentTimeMillis();
                checkAfter(currentTime);
            } else {
                EventBus.getDefault().post(new NeedLoginEvent(true));
            }


        }
        //        if (v.equals(background)) {
        //            bottomPanel.onBackAction();
        //        } else if (v.equals(btnGift)) {
        //            GiftMessage msg = new GiftMessage("2", "送您一个礼物");
        //            LiveKit.sendMessage(msg);
        //        } else if (v.equals(btnHeart)) {
        //            heartLayout.post(new Runnable() {
        //                @Override
        //                public void run() {
        //                    int rgb = Color.rgb(random.nextInt(255), random.nextInt(255), random.nextInt(255));
        //                    heartLayout.addHeart(rgb);
        //                }
        //            });
        //            GiftMessage msg = new GiftMessage("1", "为您点赞");
        //            LiveKit.sendMessage(msg);
        //        }

    }

    @Override
    public boolean handleMessage(android.os.Message msg) {
        switch (msg.what) {
            case ChatroomKit.MESSAGE_ARRIVED:
            case ChatroomKit.MESSAGE_SENT: {
                MessageContent messageContent = ((Message) msg.obj).getContent();
                String sendUserId = ((Message) msg.obj).getSenderUserId();
                if (messageContent instanceof ChatroomBarrage) {
                    ChatroomBarrage barrage = (ChatroomBarrage) messageContent;
                    DanmuEntity danmuEntity = new DanmuEntity();
                    danmuEntity.setContent(barrage.getContent());
                    danmuEntity.setPortrait(DataInterface.getUserInfo(sendUserId).getPortraitUri());
                    danmuEntity.setName(DataInterface.getUserInfo(sendUserId).getName());
                    danmuEntity.setType(barrage.getType());
                    danmuContainerView.addDanmu(danmuEntity);
                } else if (messageContent instanceof ChatroomGift) {
                    ChatroomGift gift = (ChatroomGift) messageContent;
                    if (gift.getNumber() > 0) {
                        GiftSendModel model = new GiftSendModel(gift.getNumber());
                        model.setGiftRes(DataInterface.getGiftInfo(gift.getId()).getGiftRes());
                        model.setNickname(DataInterface.getUserInfo(sendUserId).getName());
                        model.setSig("送出" + DataInterface.getGiftNameById(gift.getId()));
                        model.setUserAvatarRes(DataInterface.getUserInfo(sendUserId).getPortraitUri().toString());
                        giftView.addGift(model);

                        giftNum = giftNum + gift.getNumber();
                        hostPanel.setGiftNum(giftNum);
                    }
                } else {
                    chatListAdapter.addMessage((Message) msg.obj);

                    if (messageContent instanceof ChatroomWelcome) {
                        onlineNum++;
                        tvOnlineNum.setText(onlineNum + "");
                    } else if (messageContent instanceof ChatroomUserQuit) {
                        onlineNum--;
                        tvOnlineNum.setText(onlineNum + "");
                    } else if (messageContent instanceof ChatroomFollow) {
                        fansNum++;
                        hostPanel.setFansNum(fansNum);
                    } else if (messageContent instanceof ChatroomLike) {
                        likeNum = likeNum + ((ChatroomLike) messageContent).getCounts();
                        hostPanel.setLikeNum(likeNum);
                        //出点赞的心
                        for (int i = 0; i < ((ChatroomLike) messageContent).getCounts(); i++) {
                            heartLayout.post(new Runnable() {
                                @Override
                                public void run() {
                                    int rgb = Color.rgb(random.nextInt(255), random.nextInt(255), random.nextInt(255));
                                    heartLayout.addHeart(rgb);
                                }
                            });
                        }
                    } else if (messageContent instanceof ChatroomUserBan) {
                        if (DataInterface.isLoginStatus() && ChatroomKit.getCurrentUser().getUserId().equals(((ChatroomUserBan) messageContent).getId())) {
                            banStartTime = System.currentTimeMillis();
                            startBan(banStartTime, ((ChatroomUserBan) messageContent).getDuration());
                        }
                    } else if (messageContent instanceof ChatroomUserUnBan) {
                        if (DataInterface.isLoginStatus() && ChatroomKit.getCurrentUser().getUserId().equals(((ChatroomUserUnBan) messageContent).getId())) {
                            DataInterface.setBanStatus(false);
                        }
                    } else if (messageContent instanceof ChatroomUserBlock) {
                        if (DataInterface.isLoginStatus() && ChatroomKit.getCurrentUser().getUserId().equals(((ChatroomUserBlock) messageContent).getId())) {
                            new AlertDialog.Builder(LiveShowActivity.this).setTitle("已被管理员禁封").setPositiveButton("确定", new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialogInterface, int i) {
                                    finish();
                                }
                            }).setCancelable(false).show();

                        }
                    }
                }
                break;
            }
            case ChatroomKit.MESSAGE_SEND_ERROR: {
                break;
            }
            default:
        }
        chatListAdapter.notifyDataSetChanged();
        return false;
    }

    @Override
    protected void onDestroy() {
        ChatroomKit.quitChatRoom(new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                ChatroomKit.removeEventHandler(handler);
                if (DataInterface.isLoginStatus()) {
                    Toast.makeText(LiveShowActivity.this, "退出聊天室成功", Toast.LENGTH_SHORT).show();

                    ChatroomUserQuit userQuit = new ChatroomUserQuit();
                    userQuit.setId(ChatroomKit.getCurrentUser().getUserId());
                    ChatroomKit.sendMessage(userQuit);
                }
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                ChatroomKit.removeEventHandler(handler);
                Toast.makeText(LiveShowActivity.this, "退出聊天室失败! errorCode = " + errorCode, Toast.LENGTH_SHORT).show();

                Log.i(TAG, "errorCode = " + errorCode);
            }
        });
        //    ksyMediaPlayer.stop();

        if (EventBus.getDefault().isRegistered(this)) {
            EventBus.getDefault().unregister(this);
        }
        super.onDestroy();
    }


    @Subscribe
    public void onEventMainThread(NeedLoginEvent event) {
        if (event.isNeedLogin()) {
            loginPanel.setVisibility(View.VISIBLE);
        }
    }
}