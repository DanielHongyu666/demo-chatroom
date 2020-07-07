package cn.rongcloud.chatroomdemo.ui.panel;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;
import static android.view.ViewGroup.LayoutParams.WRAP_CONTENT;

import android.app.Dialog;
import android.app.DialogFragment;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.RecyclerView.Adapter;
import android.support.v7.widget.RecyclerView.ViewHolder;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.TextView;
import android.widget.Toast;
import cn.rongcloud.chatroomdemo.R;
import cn.rongcloud.chatroomdemo.model.CDNUrl;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by wangw on 2020/6/1.
 */
public class CDNSupplyListDialog extends DialogFragment {


  public static CDNSupplyListDialog newInstance(ArrayList<CDNUrl> supplyList) {

    Bundle args = new Bundle();
    args.putParcelableArrayList("supplyList",supplyList);
    CDNSupplyListDialog fragment = new CDNSupplyListDialog();
    fragment.setArguments(args);
    return fragment;
  }

  private RecyclerView mRecyclerView;
  private SelectCDNCallback mSelectCDNCallback;

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
    window.setGravity(Gravity.BOTTOM);
    window.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
  }

  @Nullable
  @Override
  public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container,
      Bundle savedInstanceState) {
    View view = inflater.inflate(R.layout.widget_layout_cdn_supplylist_panel, container);
    view.findViewById(R.id.iv_back).setOnClickListener(new OnClickListener() {
      @Override
      public void onClick(View v) {
        dismiss();
      }
    });
    mRecyclerView = view.findViewById(R.id.recyclerview);
    return view;
  }

  @Override
  public void onActivityCreated(Bundle savedInstanceState) {
    super.onActivityCreated(savedInstanceState);
    ArrayList<CDNUrl> supplyList = getArguments().getParcelableArrayList("supplyList");
    if (supplyList == null){
      Toast.makeText(getActivity(), "CDNSupply List is Null", Toast.LENGTH_SHORT).show();
      return;
    }
    onInitView(supplyList);
  }

  private void onInitView(ArrayList<CDNUrl> supplyList) {
    mRecyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
    CDNSupplyAdapter adapter = new CDNSupplyAdapter(supplyList);
    mRecyclerView.setAdapter(adapter);
  }

  public void setSelectCDNCallback(
      SelectCDNCallback mSelectCDNCallback) {
    this.mSelectCDNCallback = mSelectCDNCallback;
  }

  class CDNSupplyAdapter extends Adapter<CDNSupplyVH> {

    private List<CDNUrl> mDatas;

    public CDNSupplyAdapter(List<CDNUrl> datas) {
      this.mDatas = datas;
    }

    public void setData(List<CDNUrl> supplyList){
      this.mDatas = supplyList;
      notifyDataSetChanged();
    }

    @Override
    public CDNSupplyVH onCreateViewHolder(ViewGroup parent, int viewType) {
      return new CDNSupplyVH(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_cdn_supply,parent,false));
    }

    @Override
    public void onBindViewHolder(CDNSupplyVH holder, int position) {
      holder.onBindData(mDatas.get(position));
    }

    @Override
    public int getItemCount() {
      return mDatas.size();
    }
  }


  class CDNSupplyVH extends ViewHolder implements OnClickListener {

    private CDNUrl mData;
    private TextView mTvUrl;

    public CDNSupplyVH(View itemView) {
      super(itemView);
      mTvUrl = itemView.findViewById(R.id.tv_name);
      itemView.setOnClickListener(this);
    }

    public void onBindData(CDNUrl data) {
      mData = data;
      mTvUrl.setText(mData.name);
    }

    @Override
    public void onClick(View v) {
      if (mSelectCDNCallback != null)
        mSelectCDNCallback.onSelected(mData);
      dismiss();
    }
  }

  public interface SelectCDNCallback{
    void onSelected(CDNUrl cdn);
  }

}
