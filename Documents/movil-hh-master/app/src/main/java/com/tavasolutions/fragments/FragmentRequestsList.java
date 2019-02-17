package com.tavasolutions.fragments;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.google.gson.Gson;
import com.ramotion.foldingcell.FoldingCell;
import com.tavasolutions.dto.RequestDTO;
import com.tavasolutions.grids.IMyAdapter;
import com.tavasolutions.grids.IMyViewHolder;
import com.tavasolutions.grids.MyAdapter;

import java.util.ArrayList;
import java.util.Arrays;

import hotel.tavasolutions.com.hotel.R;

public class FragmentRequestsList extends Fragment implements View.OnClickListener, IMyViewHolder {

    View rootView;

    RecyclerView recyclerView;

    MyAdapter<RequestViewHolder, RequestDTO> mAdapter;

    ArrayList<RequestDTO> listaRequest=new ArrayList<>();
    LinearLayoutManager layoutmanager;



    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        rootView = inflater.inflate(R.layout.fragment_requests_list, null);

        layoutmanager=new LinearLayoutManager(getActivity());
        recyclerView= rootView.findViewById(R.id.requestsList);

        populateRecyclerView();

        return rootView;
    }

    public void populateRecyclerView(){

        Gson gson= new Gson();

        String response = getArguments().getString("requests");

        RequestDTO[] arr = gson.fromJson(response, RequestDTO[].class);
        listaRequest  = new ArrayList(Arrays.asList(arr));

        mAdapter=new MyAdapter<>(listaRequest,FragmentRequestsList.this, R.layout.request_item);
        recyclerView.setLayoutManager(layoutmanager);
        recyclerView.setAdapter(mAdapter);


    }


    @Override
    public void onClick(View view) {

    }

    @Override
    public RecyclerView.ViewHolder getInstancia(View v) {
        return new RequestViewHolder(v);
    }


    public class RequestViewHolder extends RecyclerView.ViewHolder implements IMyAdapter<FragmentRequestsList.RequestViewHolder> {


        FoldingCell fc;

        //FOLDED STATE VIEW

        TextView dateTextViewFolded,departmentTextViewFolded, roomTextViewFolded;

        //UNFOLDED STATE VIEW

        TextView dateTextViewUnfolded, departmentTextViewUnfolded, roomTextViewUnfolded, requestTv, noteTv, ddelayTv;


        public RequestViewHolder(View v) {
            super(v);

            //FOLDED

            dateTextViewFolded=v.findViewById(R.id.dateFolded);
            departmentTextViewFolded=v.findViewById(R.id.departmentFolded);
            roomTextViewFolded = v.findViewById(R.id.roomFolded);


            //UNFOLDED
            dateTextViewUnfolded =v.findViewById(R.id.textView12);
            departmentTextViewUnfolded =v.findViewById(R.id.textView16);
            roomTextViewUnfolded = v.findViewById(R.id.textView15);
            requestTv = v.findViewById(R.id.requestTv);
            noteTv = v.findViewById(R.id.noteTv);
            ddelayTv = v.findViewById(R.id.delayTv);

            fc=v.findViewById(R.id.folding_cell);
            fc.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    fc.toggle(false);
                }
            });


        }


        @Override
        public void bindView(FragmentRequestsList.RequestViewHolder holder, final int position) {
            RequestDTO requestDDTO=listaRequest.get(position);

            //FOLDED
            dateTextViewFolded.setText(requestDDTO.getInitiateddate());
            departmentTextViewFolded.setText(requestDDTO.getDepartment());
            roomTextViewFolded.setText(requestDDTO.getRoom());

            //UNFOLDED
            dateTextViewUnfolded.setText(requestDDTO.getInitiateddate());
            departmentTextViewUnfolded.setText(requestDDTO.getDepartment());
            roomTextViewUnfolded.setText(requestDDTO.getRoom());
            requestTv.setText(requestDDTO.getRequest());
            noteTv.setText(requestDDTO.getNote());
            ddelayTv.setText(requestDDTO.getDelay());


        }
    }

}
