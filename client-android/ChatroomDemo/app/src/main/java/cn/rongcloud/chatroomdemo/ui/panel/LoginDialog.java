package cn.rongcloud.chatroomdemo.ui.panel;

import android.app.Dialog;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;

import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.ui.activity.BaseActivity;
import cn.rongcloud.chatroomdemo.utils.CommonUtils;
import cn.rongcloud.chatroomdemo.utils.DataInterface;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;
import static android.view.ViewGroup.LayoutParams.WRAP_CONTENT;

/**
 * Created by wangw on 2019-09-04.
 */
public class LoginDialog extends DialogFragment {


    private EditText mEvUserName;
    private Button mBtnLogin;
    private LoginDialogListener mListener;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.widget_login_panel, container, false);
        mEvUserName = view.findViewById(R.id.ev_username);
        mBtnLogin = view.findViewById(R.id.btn_login);
        view.findViewById(R.id.iv_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });
        return view;
    }

    @Override
    public void onStart() {
        super.onStart();
        Dialog dialog = getDialog();
        if (dialog == null)
            return;
        dialog.setCancelable(false);
        dialog.setCanceledOnTouchOutside(false);
        Window window = dialog.getWindow();
        window.setLayout(MATCH_PARENT,WRAP_CONTENT);
        window.setGravity(Gravity.CENTER);
        window.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mEvUserName.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                mBtnLogin.setEnabled(!TextUtils.isEmpty(mEvUserName.getText()));
            }
        });
        mBtnLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String userName = mEvUserName.getText().toString().trim();
                if (TextUtils.isEmpty(userName)) {
                    ((BaseActivity)getActivity()).showToast("用户名称不能为空");
                    return;
                }
                //TODO 模拟登陆成功后的操作
                DataInterface.setLogin(userName);
                CommonUtils.hideInputMethod(getActivity(),mEvUserName);
                if (mListener != null)
                    mListener.onLoginSuccess();
                dismiss();
            }
        });

    }

    public LoginDialog setListener(LoginDialogListener listener){
        mListener = listener;
        return this;
    }


    public interface LoginDialogListener{
        void onLoginSuccess();
        void onFailed();
    }


}
