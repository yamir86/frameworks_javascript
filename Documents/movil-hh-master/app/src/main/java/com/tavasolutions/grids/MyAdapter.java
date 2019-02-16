package com.tavasolutions.grids;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import java.util.ArrayList;

public class MyAdapter<VH extends RecyclerView.ViewHolder & IMyAdapter,T> extends RecyclerView.Adapter<VH> {


    public ArrayList<T> mDataset;


    int LayoutItem;
    IMyViewHolder IVH;
    public MyAdapter(ArrayList<T> myDataset, IMyViewHolder ivh, int layitem) {
        LayoutItem = layitem;
        mDataset = myDataset;
        IVH=ivh;


    }

    //RecyclerView.ViewHolder HolderObject;
    @Override
    public VH onCreateViewHolder(ViewGroup parent, int viewType) {

        View v = LayoutInflater.from(parent.getContext()).inflate(LayoutItem, parent, false);

        //HolderObject=IVH.getInstancia(v);
        //return (VH)HolderObject;
        return (VH)IVH.getInstancia(v);
    }

    @Override
    public void onBindViewHolder(VH holder, int position) {
        //((VH)holder).bindView(holder,position);
        holder.bindView(holder,position);
    }

    @Override
    public int getItemCount() {
        if (mDataset!=null)
            return mDataset.size();
        else
            return 0;
    }






}
