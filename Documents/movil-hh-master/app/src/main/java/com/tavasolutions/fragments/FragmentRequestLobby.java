package com.tavasolutions.fragments;


import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.TextView;

import com.google.gson.Gson;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import com.tavasolutions.dto.RequestDTO;
import com.tavasolutions.grids.IMyAdapter;
import com.tavasolutions.grids.IMyViewHolder;
import com.tavasolutions.grids.MyAdapter;
import com.tavasolutions.util.HttpUtil;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;

import cz.msebera.android.httpclient.Header;
import hotel.tavasolutions.com.hotel.R;

public class FragmentRequestLobby extends Fragment implements View.OnClickListener, IMyViewHolder {


    View rootView;

    RecyclerView recyclerView;

    MyAdapter<ImportViewHolder, RequestDTO> mAdapter;

    ArrayList<RequestDTO> listaRequest=new ArrayList<>();
    LinearLayoutManager layoutmanager;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        rootView = inflater.inflate(R.layout.fragment_lobby, null);
        layoutmanager=new LinearLayoutManager(getActivity());
        recyclerView= rootView.findViewById(R.id.recycler);

        RequestParams rp = new RequestParams();
        rp.add("mod", "getAllUndoneRequests");


        HttpUtil.get( "requests.php",rp,new JsonHttpResponseHandler() {
            @Override
            public void onSuccess(int statusCode, Header[] headers, JSONArray response) {

                if (statusCode==200){
                    populateRecyclerView(response);


                    return;
                }


                try {

                } catch (Exception e) {
                    e.printStackTrace();
                    //Toast.makeText(getApplicationContext(), "ERROR:" +  e.getMessage(), Toast.LENGTH_SHORT).show();


                }
            }

            @Override
            public void  onFailure(int statusCode, Header[] headers, String responseString, Throwable throwable){
                //throwable.printStackTrace();
               // Toast.makeText(getApplicationContext(), responseString, Toast.LENGTH_SHORT).show();

            }


        });



        return rootView;
    }

    public void populateRecyclerView(JSONArray response){

        Gson gson= new Gson();

        RequestDTO[] arr = gson.fromJson(response.toString(), RequestDTO[].class);
        listaRequest  = new ArrayList(Arrays.asList(arr));

        mAdapter=new MyAdapter<>(listaRequest,FragmentRequestLobby.this, R.layout.lista_lobby);
        recyclerView.setLayoutManager(layoutmanager);
        recyclerView.setAdapter(mAdapter);


    }


    @Override
    public void onClick(View view) {

    }

    @Override
    public RecyclerView.ViewHolder getInstancia(View v) {
        return new ImportViewHolder(v);
    }

    public class ImportViewHolder extends RecyclerView.ViewHolder implements IMyAdapter<ImportViewHolder> {

        TextView tv_initiateddate,tv_room, tv_request, tv_initiateby, tv_note, tv_delay;

        ImageButton completeBtn;

        public ImportViewHolder(View view){
            super(view);

            tv_initiateddate= view.findViewById(R.id.tv_initiateddate);
            tv_room = view.findViewById(R.id.tv_room);
            tv_request=view.findViewById(R.id.tv_request);
            tv_initiateby = view.findViewById(R.id.tv_initiateby);
            completeBtn=view.findViewById(R.id.imageViewBtn);

            //tv_note = view.findViewById(R.id.tv_note);
            //tv_delay = view.findViewById(R.id.tv_delay);
        }

        @Override
        public void bindView(ImportViewHolder holder, final int position) {
            tv_initiateddate.setText(listaRequest.get(position).getInitiateddate());
            tv_room.setText(listaRequest.get(position).getRoom());
            tv_request.setText(listaRequest.get(position).getRequest());
            tv_initiateby.setText(listaRequest.get(position).getInitiateby());
            completeBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    RequestParams rp = new RequestParams();
                    rp.add("mod", "completeRequest");
                    rp.add("requestRecordId", listaRequest.get(position).getRequestrecordid());


                    HttpUtil.post( "requests.php",rp,new JsonHttpResponseHandler() {
                        @Override
                        public void onSuccess(int statusCode, Header[] headers, JSONArray response) {
                            Log.e(FragmentRequestLobby.class.getSimpleName(), "onSuccess: " );

                            if (statusCode==200){

                                populateRecyclerView(response);

                                return;
                            }


                            try {

                            } catch (Exception e) {
                                e.printStackTrace();
                                //Toast.makeText(getApplicationContext(), "ERROR:" +  e.getMessage(), Toast.LENGTH_SHORT).show();


                            }
                        }

                        @Override
                        public void  onFailure(int statusCode, Header[] headers, String responseString, Throwable throwable){
                            //throwable.printStackTrace();
                            // Toast.makeText(getApplicationContext(), responseString, Toast.LENGTH_SHORT).show();

                        }


                    });
                }
            });
            //tv_note.setText(listaRequest.get(position).getNote());
            //tv_delay.setText(listaRequest.get(position).getDelay());
        }


    }

}
