package cn.rongcloud.chatroomdemo.updateapk;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Notification;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;

import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.utils.DataInterface;
import cn.rongcloud.rtc.media.http.HttpClient;
import cn.rongcloud.rtc.media.http.Request;
import cn.rongcloud.rtc.media.http.RequestMethod;


public class UpDateApkHelper {
    private static final String TAG = "UpDateApkHelper";
    private static final String GET_CLIENT_NEW_VERSION = "/app/version";
    private Activity activity;

    public UpDateApkHelper(Activity activity) {
        this.activity = activity;
    }

    public void diffVersionFromServer() {
        final Request request = new Request.Builder().url(DataInterface.APPSERVER+GET_CLIENT_NEW_VERSION).method(RequestMethod.GET).build();
        HttpClient.getDefault().request(request, new HttpClient.ResultCallback() {
            @Override
            public void onResponse(String result) {
                try {
                    JSONObject root = new JSONObject(result);
                    if (root.getInt("code") == 200) {
                        JSONObject res = root.getJSONObject("result");
//                        JSONObject client = res.getJSONObject("client");
                        JSONObject android = res.getJSONObject("android");
                        final String remoteVersion = android.getString("name");
                        final String downLoadUrl = android.getString("url");
                        final boolean force = android.optBoolean("force",false);
                        String localVersion = DataInterface.APP_VERSION;
                        Log.i(TAG, "onResponse() remote version: " + remoteVersion + " local version: " + localVersion + " downLoadUrl " + downLoadUrl);
                        if (needUpDate(remoteVersion, localVersion)) {
                            activity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    showUpdateDialog(remoteVersion, downLoadUrl,force);
                                }
                            });
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onFailure(int errorCode) {
                Log.i(TAG, "onFailure() errorCode = " + errorCode);
            }

            @Override
            public void onError(IOException exception) {
                Log.i(TAG, "onFailure() onError = " + exception);
            }
        });
    }

    private void showUpdateDialog(final String targetVersion, final String downLoadUrl, final boolean force) {
        final AlertDialog dlg = new AlertDialog.Builder(activity).create();
        dlg.setTitle(String.format(activity.getString(R.string.apk_update_title), targetVersion));
        dlg.setButton(DialogInterface.BUTTON_POSITIVE, String.format(activity.getString(R.string.rtc_dialog_ok), targetVersion), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                Toast.makeText(activity, R.string.downloading_apk, Toast.LENGTH_SHORT).show();
                UpdateService.Builder.create(downLoadUrl)
                        .setStoreDir("update/flag")
                        .setDownloadSuccessNotificationFlag(Notification.DEFAULT_ALL)
                        .setDownloadErrorNotificationFlag(Notification.DEFAULT_ALL)
                        .build(activity);

                //TODO 要求强制更新时，必须一直显示更新弹窗
                if (force)
                    showUpdateDialog(targetVersion,downLoadUrl,force);
//                if (force)
//                    showDownloadingDialog();

            }
        });
        dlg.setCancelable(!force);
        if (!force) {
            dlg.setButton(DialogInterface.BUTTON_NEGATIVE, String.format(activity.getString(R.string.rtc_dialog_cancel), targetVersion), new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialogInterface, int i) {
                    dlg.cancel();
                }
            });
        }
        dlg.show();
    }

    private void showDownloadingDialog() {
        final AlertDialog dlg = new AlertDialog.Builder(activity).create();
        dlg.setTitle("正在下载中...\n");
        dlg.setCancelable(false);
        dlg.show();
    }

    /**
     * @param localVersion
     * @param remoteVersion
     * @return
     */
    private boolean needUpDate(String remoteVersion, String localVersion) {
        try {
            String[] remoteValues = remoteVersion.split("\\.");
            String[] localValues = localVersion.split("\\.");
            int length = remoteValues.length > localValues.length ? remoteValues.length : localValues.length;
            for (int i = 0; i < length; i++) {
                int remoteValue = remoteValues.length > i ? Integer.valueOf(remoteValues[i]) : 0;
                int localValue = localValues.length > i ? Integer.valueOf(localValues[i]) : 0;
                if (remoteValue > localValue){
                    return true;
                }else if (localValue > remoteValue){
                    return false;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return  false;
    }
}
