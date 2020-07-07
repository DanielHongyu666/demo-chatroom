package cn.rongcloud.chatroomdemo.utils;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothHeadset;
import android.bluetooth.BluetoothProfile;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.util.Log;

public class HeadsetReceiver extends BroadcastReceiver {

    private static final String TAG = "HeadsetReceiver";
    public boolean FIRST_HEADSET_PLUG_RECEIVER = false;

    private boolean mBluetoothConnected;
    private AudioManager mAudioManager;
    private HeadsetListener mListener;

    public HeadsetReceiver(AudioManager audioManager) {
        if (audioManager == null) {
            Log.e(TAG, "AudioManager is Null");
        }
        mAudioManager = audioManager;
        onInit();
    }

    private void onInit() {
        mBluetoothConnected = hasBluetoothA2dpConnected();
        if (mAudioManager != null && mAudioManager.getMode() != AudioManager.MODE_IN_COMMUNICATION) {
            mAudioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
        }
        if (mBluetoothConnected)
            setBluetoothSco(true,mAudioManager);
        else
            setSpeakerphoneOn(!isWiredHeadsetOn(),mAudioManager);
    }

    public void registerReceiver(Context context){
        if (context == null) {
            Log.e(TAG, "Context is Null");
            return;
        }
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("android.intent.action.HEADSET_PLUG");
        intentFilter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED);
        intentFilter.addAction(BluetoothHeadset.ACTION_CONNECTION_STATE_CHANGED);
        intentFilter.addAction(BluetoothHeadset.ACTION_AUDIO_STATE_CHANGED);
        intentFilter.addAction(AudioManager.ACTION_SCO_AUDIO_STATE_UPDATED);
        context.registerReceiver(this,intentFilter);
    }

    public void unregisterReceiver(Context context){
        if (context == null) {
            Log.e(TAG, "Context is Null");
            return;
        }
        context.unregisterReceiver(this);
    }

    /**
     * 是否插入耳机
     * @return
     */
    public boolean isWiredHeadsetOn(){
        if (mAudioManager != null)
            return mAudioManager.isWiredHeadsetOn();
        return false;
    }

    /**
     * 是否连接了蓝牙耳机
     *
     * @return
     */
    @SuppressLint("WrongConstant")
    public boolean hasBluetoothA2dpConnected() {
        boolean bool = false;
        BluetoothAdapter mAdapter = BluetoothAdapter.getDefaultAdapter();
        if (mAdapter != null && mAdapter.isEnabled()) {
            int a2dp = mAdapter.getProfileConnectionState(BluetoothProfile.A2DP);
            if (a2dp == BluetoothProfile.STATE_CONNECTED) {
                bool = true;
            }
        }
        return bool;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        // Log.d("HeadsetPlugReceiver", "onReceive: "+intent.getAction()+" , state=
        // "+intent.getIntExtra(BluetoothProfile.EXTRA_STATE, -1)+" , SCO_AUDIO_STATE=
        // "+intent.getIntExtra(AudioManager.EXTRA_SCO_AUDIO_STATE, -1));
        if ("android.intent.action.HEADSET_PLUG".equals(action)) {
            int state = -1;
            if (intent.hasExtra("state")) {
                state = intent.getIntExtra("state", -1);
            }
            onNotifyHeadsetState(state == 1,false);
        } else if (BluetoothHeadset.ACTION_CONNECTION_STATE_CHANGED.equals(action)) {
            int state = intent.getIntExtra(BluetoothProfile.EXTRA_STATE, -1);
            switch (state) {
                case BluetoothProfile.STATE_DISCONNECTED:
                    mBluetoothConnected = false;
                    onNotifyHeadsetState(mBluetoothConnected,true);
                    break;
                case BluetoothProfile.STATE_CONNECTED:
                    mBluetoothConnected = true;
                    onNotifyHeadsetState(mBluetoothConnected,true);
                    break;
            }

        } else if (AudioManager.ACTION_SCO_AUDIO_STATE_UPDATED.equals(action)) {
            onNotifySCOAudioStateChange(
                (intent.getIntExtra(AudioManager.EXTRA_SCO_AUDIO_STATE, -1)),mAudioManager);
        }
        //        else if (BluetoothHeadset.ACTION_AUDIO_STATE_CHANGED.equals(action)){
        //            int state = intent.getIntExtra(BluetoothProfile.EXTRA_STATE, -1);
        //            switch (state) {
        //                case BluetoothHeadset.STATE_AUDIO_DISCONNECTED:
        //                    headsetInfo = new HeadsetInfo(false, 0);
        //                    break;
        //                case BluetoothHeadset.STATE_AUDIO_CONNECTED:
        //                    headsetInfo = new HeadsetInfo(true, 0);
        //                    break;
        //            }
        //        }
    }

    public void onNotifySCOAudioStateChange(int scoAudioState,AudioManager am){
        if (am == null)
            return;
        switch (scoAudioState) {
            case AudioManager.SCO_AUDIO_STATE_CONNECTED:
                if (am != null)
                    am.setBluetoothScoOn(true);
                break;
            case AudioManager.SCO_AUDIO_STATE_DISCONNECTED:
                Log.d("onNotifyHeadsetState", "onNotifySCOAudioStateChange: "+mBluetoothConnected);
                if (mBluetoothConnected)
                    setBluetoothSco(true,am);
                break;
        }
    }

    public void onNotifyHeadsetState(boolean isConnected,boolean isBluetooth){
        if (isBluetooth){
            setBluetoothSco(isConnected,mAudioManager);
        }else {
            setSpeakerphoneOn(!isConnected,mAudioManager);
        }
        if (mListener != null){
            mListener.onHeadsetStateChange(isConnected);
        }
    }

    private void setBluetoothSco(boolean isConnected,AudioManager am) {
        if (am == null) {
            return;
        }
        if (isConnected) {
            am.startBluetoothSco();
//            am.setBluetoothScoOn(true);
        }else {
            am.stopBluetoothSco();
            am.setBluetoothScoOn(false);
        }
        am.setSpeakerphoneOn(!isConnected);
    }

    private void setSpeakerphoneOn(boolean on,AudioManager audioManager) {
        if (audioManager == null)
            return;
        boolean wasOn = audioManager.isSpeakerphoneOn();
        if (wasOn == on) {
            return;
        }
        audioManager.setSpeakerphoneOn(on);
    }

    public HeadsetListener getListener() {
        return mListener;
    }

    public void setListener(HeadsetListener mListener) {
        this.mListener = mListener;
    }

    public interface HeadsetListener{

        /**
         * 耳机连接状态改变
         * @param headsetEnable 连接是否可用
         */
        void onHeadsetStateChange(boolean headsetEnable);
    }
}
