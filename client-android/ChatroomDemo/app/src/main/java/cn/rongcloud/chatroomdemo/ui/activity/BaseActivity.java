package cn.rongcloud.chatroomdemo.ui.activity;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentActivity;
import android.widget.Toast;

import cn.rongcloud.chatroomdemo.ui.panel.LoadDialog;
import cn.rongcloud.chatroomdemo.utils.LogUtils;

/**
 * Created by wangw on 2019-08-21.
 */
public class BaseActivity extends FragmentActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        LogUtils.d(toString(),"Activity onCreate");
    }

    public void postShowToast(final String msg) {
        LogUtils.i(this.toString(),msg);
        if (isFinish())
            return;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                showToast(msg);
            }
        });
    }

    public void showToast( String msg) {
        LogUtils.i(this.toString(),msg);
        if (isFinish())
            return;
        Toast.makeText(BaseActivity.this, msg, Toast.LENGTH_SHORT).show();
    }

    public void postCloseLoading(){
        if (isFinish())
            return;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                closeLoading();
            }
        });
    }

    public void showToast( int resId) {
        if (isFinish())
            return;
        Toast.makeText(BaseActivity.this, resId, Toast.LENGTH_SHORT).show();
    }

    public void showLoading(){
        if (isFinish())
            return;
        LoadDialog.show(this);
    }

    public void showLoading(String msg){
        if (isFinish())
            return;
        LoadDialog.show(this,msg);
    }

    public void closeLoading(){
        if (isFinish())
            return;
        LoadDialog.dismiss(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        LogUtils.d(toString(),"Activity onDestroy");
        closeLoading();
    }

    public boolean isFinish(){
        return isFinishing() || isDestroyed();
    }
}
