package com.tavasolutions.grids;

import android.support.v7.widget.RecyclerView;

public interface IMyAdapter<VHH extends RecyclerView.ViewHolder> {

    void bindView(VHH holder, int position);

}
