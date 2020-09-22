package cn.rongcloud.chatroomdemo.utils;

import android.content.ContentResolver;
import android.content.Context;
import android.content.SharedPreferences;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;

import cn.rongcloud.chatroomdemo.http.HttpHelper;
import cn.rongcloud.chatroomdemo.http.Request;
import cn.rongcloud.chatroomdemo.http.RequestMethod;
import cn.rongcloud.rtc.api.RCRTCEngine;
import io.rong.imlib.RongIMClient.ConnectionErrorCode;
import io.rong.imlib.RongIMClient.DatabaseOpenStatus;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.ArrayList;
import java.util.Random;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.regex.Pattern;
import cn.rongcloud.chatroomdemo.ChatroomApp;
import cn.rongcloud.chatroomdemo.ChatroomKit;
import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.model.Gift;
import cn.rongcloud.rtc.utils.FinLog;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.common.DeviceUtils;
import io.rong.imlib.model.UserInfo;

import static io.rong.imlib.RongIMClient.ConnectionStatusListener.ConnectionStatus.CONNECTED;
import static io.rong.imlib.RongIMClient.ConnectionStatusListener.ConnectionStatus.CONNECTING;

/**
 * Created by duanliuyi on 2018/5/10.
 */

/*数据接口
 *
 * 由于本demo没有App Server，用户信息，聊天室信息 等全部通过DataInterface的接口返回，目前都是写死的数据。 开发者可以修改这些接口，去自己的app server取数据。
 * */
public class DataInterface {
    private static final String TAG = "DataInterface";
    public static String APP_VERSION = "2.2.0";

    public static final String NAV_SERVER = "https://nav.cn.ronghub.com";
    public static final String FILE_SERVER = "up.qbox.me";

    //ToDO 改为您自己 BuglyKey
    public static final String BuglyKey = "ead5321317";

    //TODO 需要改成开发者自己的 appKey 和 AppServer
    public static final String APP_KEY = 替换成自己的AppKey;
    public static String APPSERVER = 替换成自己的APPserver地址;
    private static final String CONFIG_NAME = "chatroom_config";
    private static final String CODE = "code";
    public static final String RESULT = "result";
    public static final String PUBLISH = "/publish"; //发布
    public static final String UNPUBLISH = "/unpublish"; //取消发布
    public static final String QUERY = "/query"; //查询直播列表
    private static final String GETTOKENURL = "/user/get_token"; //获取Token

    public static String APPSERVER_CDN = ""; //CDN推流相关的 AppServer
    public static final String CDNSUPPLY =  "/cdnsupply";    //获取CDN支持列表
    public static final String CDNURL =  "/cdnurl";  //生成CDN推流拉流地址


    //TODO Jenkins 自动打包时使用，不使用Jenkins则可以忽略此字段
    private static String RONG_RTC_CONFIG_SERVER_URL = "MESERVER";
    private static String RONG_RTC_APP_SERVER_URL = "JENKINS_APPSERVER";
    private static String RONG_SEALLIVE_APP_VERSION = "JENKINS_APP_VERSION";
    private static String RONG_APPSERVER_CDN = "JENKINS_CDNAPPSERVER";



    public static final int DEfALUT_AVATAR = R.drawable.avatar_1;
    private static final int[] AVATARS = {R.drawable.avatar_1,
            R.drawable.avatar_2,
            R.drawable.avatar_3,
            R.drawable.avatar_4,
            R.drawable.avatar_5,
            R.drawable.avatar_6,
            R.drawable.avatar_7,
            R.drawable.avatar_8,
            R.drawable.avatar_9,
            R.drawable.avatar_10
    };
    private static final int[] COVERS = {
            R.drawable.chatroom_01,
            R.drawable.chatroom_02,
            R.drawable.chatroom_03,
            R.drawable.chatroom_04,
            R.drawable.chatroom_05,
            R.drawable.chatroom_06
    };


    public static final String KEY_USERTOKEN = "userToken";
//    public static final String KEY_USERNAME = "userName";
    public static final String KEY_USERID = "userId";


    private static SharedPreferences mSP;
    private static AtomicBoolean mGetTokening = new AtomicBoolean(false);
    private static String mUserName;

    /*是否禁言*/
    private static boolean banStatus = false;

    public static boolean isBanStatus() {
        return banStatus;
    }

    public static void setBanStatus(boolean banStatus) {
        DataInterface.banStatus = banStatus;
    }

    public static void init(Context context){
        if (!TextUtils.isEmpty(RONG_RTC_CONFIG_SERVER_URL) &&
                RONG_RTC_CONFIG_SERVER_URL.startsWith("http")) {
            RCRTCEngine.getInstance().setMediaServerUrl(RONG_RTC_CONFIG_SERVER_URL);
        }
        if (!TextUtils.isEmpty(RONG_RTC_APP_SERVER_URL) &&
                RONG_RTC_APP_SERVER_URL.startsWith("http")) {
            APPSERVER = RONG_RTC_APP_SERVER_URL;
        }
        if (!TextUtils.isEmpty(RONG_APPSERVER_CDN) &&
            RONG_APPSERVER_CDN.startsWith("http")) {
            APPSERVER_CDN = RONG_APPSERVER_CDN;
        }
        if (!TextUtils.isEmpty(RONG_SEALLIVE_APP_VERSION) && Pattern.matches("^\\d.*", RONG_SEALLIVE_APP_VERSION)){
            APP_VERSION = RONG_SEALLIVE_APP_VERSION;
        }
        mSP = context.getSharedPreferences(CONFIG_NAME,Context.MODE_PRIVATE);
    }

    public static void putString(String key,String value){
        editor()
                .putString(key,value)
                .apply();
    }

    public static String getString(String key){
        return getString(key,null);
    }

    public static String getString(String key,String defaultVale){
        return mSP.getString(key,defaultVale);
    }

    public static SharedPreferences.Editor editor(){
        return mSP.edit();
    }

    public static String getUserName(){
        return mUserName;
    }

    /**
     * 模拟登陆后的逻辑
     */
    public static void setLogin(String userName){
        mUserName = userName;
        ChatroomKit.setCurrentUser(new UserInfo(getUserId(), getUserName(), Uri.parse(String.valueOf(getRandomNum(AVATARS.length)))));
    }

    public static String getUserId(){
        return getString(KEY_USERID);
    }

    public static boolean isLogin() {
        //TODO 由于AppServer能力有限，没有登录逻辑，所以目前只是做了一个假登录，以是否设置过用户名为判断依据
        return !TextUtils.isEmpty(getUserName());
    }

    /**
     * IM是否连接中
     * @return
     */
    public static boolean isImConnecting(){
        return mGetTokening.get() || RongIMClient.getInstance().getCurrentConnectionStatus() == CONNECTING;
    }

    /**
     * IM是否已连接
     * @return
     */
    public static boolean isImConnected(){
        return RongIMClient.getInstance().getCurrentConnectionStatus() == CONNECTED;
    }

    /**
     * 连接IM
     * @param callback
     */
    public static void connectIM(final RongIMClient.ConnectCallback callback){
        mGetTokening.set(false);
        HttpHelper.getDefault().setEnableSelfCertificate(true);
        String token = getString(KEY_USERTOKEN);
        if (TextUtils.isEmpty(token)){
            getToken(callback);
            return;
        }
        RongIMClient.setConnectionStatusListener(new RongIMClient.ConnectionStatusListener() {
            @Override
            public void onChanged(ConnectionStatus status) {
                switch (status) {
                    case CONNECTED://连接成功。
                        Log.i(TAG, "连接成功");
                        break;
                    case CONNECTING://连接中。
                        Log.i(TAG, "连接中");
                        break;
                    case NETWORK_UNAVAILABLE://网络不可用。
                        Log.i(TAG, "网络不可用");
                        break;
                    case KICKED_OFFLINE_BY_OTHER_CLIENT://用户账户在其他设备登录，本机会被踢掉线
                        Log.i(TAG, "用户账户在其他设备登录");
                        break;
                }
            }
        });
        ChatroomKit.connect(getString(KEY_USERTOKEN), new RongIMClient.ConnectCallback() {

            public void onTokenIncorrect() {
                Log.i(TAG, "onTokenIncorrect");
                putString(KEY_USERTOKEN,null);
                if (callback != null) {
                    callback.onError(ConnectionErrorCode.RC_CONN_TOKEN_INCORRECT);
                }
            }

            @Override
            public void onSuccess(String s) {
                putString(KEY_USERID,s);
                if (isLogin()){
                    setLogin(mUserName);
                }
                Log.i(TAG, "connectSuccess");
                if (callback != null){
                    callback.onSuccess(s);
                }
            }

            @Override
            public void onError(ConnectionErrorCode connectionErrorCode) {
                Log.i(TAG, "connect error code = " + connectionErrorCode);
                if (connectionErrorCode == ConnectionErrorCode.RC_CONN_TOKEN_INCORRECT){
                    onTokenIncorrect();
                }
                if (callback != null) {
                    callback.onError(connectionErrorCode);
                }
            }

            @Override
            public void onDatabaseOpened(DatabaseOpenStatus databaseOpenStatus) {

            }

        });
    }


    private static void getToken(final RongIMClient.ConnectCallback callback){
        mGetTokening.set(true);
        String json = "";
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("id", DeviceUtils.getDeviceId(ChatroomApp.getContext()));
            json = jsonObject.toString();
        } catch (JSONException e) {
            e.printStackTrace();
        }
        Request.Builder request = new Request.Builder();
        request.url(APPSERVER+GETTOKENURL);
        request.method(RequestMethod.POST);
        request.body(json);
        HttpHelper.getDefault().request(request.build(), new HttpHelper.ResultCallback() {
            @Override
            public void onResponse(final String result) {
                LogUtils.i("DemoServer", "GetToken Result: "+result);
                try {
                    int code = 0;
                    JSONObject jsonObject = new JSONObject(result);
                    if (jsonObject.has(CODE)) {
                        code = jsonObject.getInt(CODE);
                    }
                    if (code == 200) {
                        if (jsonObject.has(RESULT)) {
                            JSONObject jsonObjectResult = jsonObject.getJSONObject(RESULT);
                            if (jsonObjectResult.has("token")) {
                                String token = String.valueOf(jsonObjectResult.get("token"));
                                putString(KEY_USERTOKEN,token);
                                connectIM(callback);
                            }
                        }
                    } else {
                        if (callback != null){
                            callback.onError(ConnectionErrorCode.RC_CONN_TOKEN_INCORRECT);
                        }

                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    if (callback != null){
                        callback.onError(ConnectionErrorCode.RC_CONN_TOKEN_INCORRECT);
                    }
                }
                mGetTokening.set(false);
            }

            @Override
            public void onFailure(final int errorCode) {
                mGetTokening.set(false);
                FinLog.e("DemoServer", "GetToken failure: "+errorCode);
                if (callback != null){
                    callback.onError(ConnectionErrorCode.RC_CONN_TOKEN_INCORRECT);
                }
            }
        });

    }

    /**
     * 退出登录
     */
    public static void logout() {
        ChatroomKit.logout();
        mUserName = null;
    }

    /**
     * 由于服务器全没有存储用户信息，所以使用本地图片模拟获取用户头像
     * @param uri
     * @return
     */
    public static Uri getAvatarUri(Uri uri){
        if (uri == null || TextUtils.isEmpty(uri.toString())){
            return getUri(ChatroomApp.getContext(),AVATARS[0]);
        }
        int index = 0;
        try {
           index = Integer.valueOf(uri.toString());
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
        index = index >= AVATARS.length ? 0 : index;
        return getUri(ChatroomApp.getContext(),AVATARS[index]);
    }

    /**
     * 同获取用户头像类似，使用本地图片当房间封面
     * @param coverIndex
     * @return
     */
    public static Uri getCoverUri(int coverIndex){
        int index = coverIndex >= COVERS.length || coverIndex < 0 ? 0 : coverIndex;
        return getUri(ChatroomApp.getContext(),COVERS[index]);
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
        return Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://"
                + context.getResources().getResourcePackageName(res) + "/"
                + context.getResources().getResourceTypeName(res) + "/"
                + context.getResources().getResourceEntryName(res));
    }

}
