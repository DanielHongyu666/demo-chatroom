package cn.rongcloud.chatroomdemo.utils;

import android.content.ContentResolver;
import android.content.Context;
import android.content.res.AssetManager;
import android.net.Uri;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Random;

import cn.rongcloud.chatroomdemo.ChatroomApp;
import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.model.ChatroomInfo;
import cn.rongcloud.chatroomdemo.model.Gift;
import cn.rongcloud.chatroomdemo.model.HostInfo;
import cn.rongcloud.chatroomdemo.model.UserMode;
import io.rong.imlib.model.UserInfo;

/**
 * Created by duanliuyi on 2018/5/10.
 */

/*数据接口
*
* 由于本demo没有App Server，用户信息，聊天室信息 等全部通过DataInterface的接口返回，目前都是写死的数据。 开发者可以修改这些接口，去自己的app server取数据。
* */
public class DataInterface {

    /*appkey   需要改成开发者自己的appKey*/
    public static String appKey = "tdrvipkstfsu5";

    public static final int Avatar_1 = R.drawable.avatar_1;
    public static final int Avatar_2 = R.drawable.avatar_2;
    public static final int Avatar_3 = R.drawable.avatar_3;
    public static final int Avatar_4 = R.drawable.avatar_4;
    public static final int Avatar_5 = R.drawable.avatar_5;
    public static final int Avatar_6 = R.drawable.avatar_6;
    public static final int Avatar_7 = R.drawable.avatar_7;
    public static final int Avatar_8 = R.drawable.avatar_8;
    public static final int Avatar_9 = R.drawable.avatar_9;
    public static final int Avatar_10 = R.drawable.avatar_10;

    /*是否登录*/
    private static boolean loginStatus = false;

    public static boolean isLoginStatus() {
        return loginStatus;
    }

    public static void setLoginStatus(boolean loginStatus) {
        DataInterface.loginStatus = loginStatus;
    }


    static private ArrayList<UserInfo> userInfoList;
    static private ArrayList<UserMode> userModes;


    public static ArrayList<UserMode> getUserModes() {
        return userModes;
    }

    static public void initUserInfo() {
        userInfoList = new ArrayList<>();
        Gson gson = new Gson();
        String jsonArray = getJson("users.json", ChatroomApp.getContext());
        userModes = gson.fromJson(jsonArray, new TypeToken<ArrayList<UserMode>>() {
        }.getType());
        Uri uri = null;
        for (int i = 0; i < userModes.size(); i++) {
            UserMode mode = userModes.get(i);
            switch (i % 10) {
                case 0:
                    uri = getUri(ChatroomApp.getContext(), Avatar_1);
                    break;
                case 1:
                    uri = getUri(ChatroomApp.getContext(), Avatar_2);
                    break;
                case 2:
                    uri = getUri(ChatroomApp.getContext(), Avatar_3);
                    break;
                case 3:
                    uri = getUri(ChatroomApp.getContext(), Avatar_4);
                    break;
                case 4:
                    uri = getUri(ChatroomApp.getContext(), Avatar_5);
                    break;
                case 5:
                    uri = getUri(ChatroomApp.getContext(), Avatar_6);
                    break;
                case 6:
                    uri = getUri(ChatroomApp.getContext(), Avatar_7);
                    break;
                case 7:
                    uri = getUri(ChatroomApp.getContext(), Avatar_8);
                    break;
                case 8:
                    uri = getUri(ChatroomApp.getContext(), Avatar_9);
                    break;
                case 9:
                    uri = getUri(ChatroomApp.getContext(), Avatar_10);
                    break;
            }
            UserInfo userInfo = new UserInfo(mode.getId(), mode.getName(), uri);
            userInfoList.add(userInfo);
        }


    }

    /*
    * 获取用户信息
    * */
    public static UserInfo getUserInfo(String userid) {
        for (int i = 0; i < userInfoList.size(); i++) {
            if (userInfoList.get(i).getUserId().equals(userid)) {
                return userInfoList.get(i);
            }
        }
        return null;
    }


    /*根据roomId获取房间在线成员列表*/
    public static ArrayList<UserInfo> getUserList(String roomId) {
        ArrayList<UserInfo> userInfos = new ArrayList<>();
        for (int i = 0; i < 10; i++) {
            userInfos.add(userInfoList.get(i));
        }
        return userInfos;
    }


    /*获取直播间列表信息*/
    public static ArrayList<ChatroomInfo> getChatroomList() {
        ArrayList<ChatroomInfo> chatroomInfos = new ArrayList<>();

        chatroomInfos.add(new ChatroomInfo("ChatRoom1", "聊天室01", "直播中", getRandomNum(1000), getUri(ChatroomApp.getContext(), R.drawable.chatroom_01)));
        chatroomInfos.add(new ChatroomInfo("ChatRoom2", "聊天室02", "直播中", getRandomNum(1000), getUri(ChatroomApp.getContext(), R.drawable.chatroom_02)));
        chatroomInfos.add(new ChatroomInfo("ChatRoom3", "聊天室03", "直播中", getRandomNum(1000), getUri(ChatroomApp.getContext(), R.drawable.chatroom_03)));
        chatroomInfos.add(new ChatroomInfo("ChatRoom4", "聊天室04", "直播中", getRandomNum(1000), getUri(ChatroomApp.getContext(), R.drawable.chatroom_04)));
        chatroomInfos.add(new ChatroomInfo("ChatRoom5", "聊天室05", "直播中", getRandomNum(1000), getUri(ChatroomApp.getContext(), R.drawable.chatroom_05)));
        chatroomInfos.add(new ChatroomInfo("ChatRoom6", "聊天室06", "直播中", getRandomNum(1000), getUri(ChatroomApp.getContext(), R.drawable.chatroom_06)));

        chatroomInfos.add(new ChatroomInfo("ChatRoom7", "聊天室07", "直播中", getRandomNum(1000), getUri(ChatroomApp.getContext(), R.drawable.chatroom_01)));
        chatroomInfos.add(new ChatroomInfo("ChatRoom8", "聊天室08", "直播中", getRandomNum(1000), getUri(ChatroomApp.getContext(), R.drawable.chatroom_02)));

        return chatroomInfos;
    }

    /*根据roomId获取主播名*/
    public static String getHostNameByRoomId(String roomId) {
        switch (roomId) {
            case "ChatRoom1":
                return "1号主播";
            case "ChatRoom2":
                return "2号主播";
            case "ChatRoom3":
                return "3号主播";
            case "ChatRoom4":
                return "4号主播";
            case "ChatRoom5":
                return "5号主播";
            case "ChatRoom6":
                return "6号主播";
            case "ChatRoom7":
                return "7号主播";
            case "ChatRoom8":
                return "8号主播";
        }
        return "主播";
    }

    /*根据roomId获取主播信息*/
    public static HostInfo getHostInfoByRoomId(String roomId) {
        HostInfo info = null;
        switch (roomId) {
            case "ChatRoom1":
                info = new HostInfo("1号主播", R.drawable.chatroom_01);
                break;
            case "ChatRoom2":
                info = new HostInfo("2号主播", R.drawable.chatroom_02);
                break;
            case "ChatRoom3":
                info = new HostInfo("3号主播", R.drawable.chatroom_03);
                break;
            case "ChatRoom4":
                info = new HostInfo("4号主播", R.drawable.chatroom_04);
                break;
            case "ChatRoom5":
                info = new HostInfo("5号主播", R.drawable.chatroom_05);
                break;
            case "ChatRoom6":
                info = new HostInfo("6号主播", R.drawable.chatroom_06);
                break;
            case "ChatRoom7":
                info = new HostInfo("7号主播", R.drawable.chatroom_01);
                break;
            case "ChatRoom8":
                info = new HostInfo("8号主播", R.drawable.chatroom_02);
                break;
        }
        return info;
    }


    /*获取礼物列表*/
    public static ArrayList<Gift> getGiftList() {
        ArrayList<Gift> gifts = new ArrayList<>();
        String[] giftNames = new String[]{"蛋糕", "气球", "花儿", "项链", "戒指"};
        int[] giftRes = new int[]{R.drawable.gift_cake, R.drawable.gift_ballon, R.drawable.gift_flower, R.drawable.gift_necklace, R.drawable.gift_ring};

        for (int i = 0; i < giftNames.length; i++) {
            Gift gift = new Gift();
            gift.setGiftId("GiftId_" + (i + 1));
            gift.setGiftName(giftNames[i]);
            gift.setGiftRes(giftRes[i]);
            gifts.add(gift);
        }
        return gifts;
    }


    /*获取礼物名*/
    public static String getGiftNameById(String giftId) {
        switch (giftId) {
            case "GiftId_1":
                return "蛋糕";
            case "GiftId_2":
                return "气球";
            case "GiftId_3":
                return "花儿";
            case "GiftId_4":
                return "项链";
            case "GiftId_5":
                return "戒指";
        }
        return null;
    }

    /*根据giftId获取礼物信息*/
    public static Gift getGiftInfo(String giftId) {
        ArrayList<Gift> gifts = getGiftList();
        for (int i = 0; i < gifts.size(); i++) {
            if (gifts.get(i).getGiftId().equals(giftId)) {
                return gifts.get(i);
            }
        }
        return null;
    }


    /*生成随机数*/
    public static int getRandomNum(int max) {
        Random r = new Random();
        return r.nextInt(max);
    }

    public static Uri getUri(Context context, int res) {
        Uri uri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://"
                + context.getResources().getResourcePackageName(res) + "/"
                + context.getResources().getResourceTypeName(res) + "/"
                + context.getResources().getResourceEntryName(res));

        return uri;
    }


    public static String getJson(String fileName, Context context) {
        //将json数据变成字符串
        StringBuilder stringBuilder = new StringBuilder();
        try {
            //获取assets资源管理器
            AssetManager assetManager = context.getAssets();
            //通过管理器打开文件并读取
            BufferedReader bf = new BufferedReader(new InputStreamReader(
                    assetManager.open(fileName)));
            String line;
            while ((line = bf.readLine()) != null) {
                stringBuilder.append(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return stringBuilder.toString();
    }
}
