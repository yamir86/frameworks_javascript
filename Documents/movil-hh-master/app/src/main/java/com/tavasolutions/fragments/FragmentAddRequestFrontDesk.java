package com.tavasolutions.fragments;

import android.app.DatePickerDialog;
import android.app.Dialog;
import android.app.TimePickerDialog;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.Fragment;
import android.support.v7.widget.CardView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.SearchView;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.TimePicker;
import android.widget.Toast;

import com.google.gson.Gson;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import com.tavasolutions.dto.AddRequestDTO;
import com.tavasolutions.dto.DepartmentDTO;
import com.tavasolutions.dto.RequestDTO;
import com.tavasolutions.dto.RoomDTO;
import com.tavasolutions.grids.MyAdapter;
import com.tavasolutions.util.HttpUtil;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.List;

import cz.msebera.android.httpclient.Header;
import hotel.tavasolutions.com.hotel.R;

public class FragmentAddRequestFrontDesk extends Fragment implements View.OnClickListener {

    View rootView;

    static TextView dateTextView, hourTextView;

    CheckBox delayCheckBox;
    EditText searchView;

    CardView addRequestLayout;

    String roomSearchQuery;
    Spinner departmentsSpinner, requestsSpinner;
    Button btnAdd;

    EditText noteEditText;

    AddRequestDTO addRequestDTO;

    Button searchRoomButton;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        rootView=inflater.inflate(R.layout.fragmen_add_request_frontdesk, null);

        dateTextView=rootView.findViewById(R.id.tvDate);
        hourTextView=rootView.findViewById(R.id.tvHour);

        delayCheckBox=rootView.findViewById(R.id.checkBox);

        dateTextView.setOnClickListener(this);
        hourTextView.setOnClickListener(this);
        delayCheckBox.setOnClickListener(this);
        noteEditText=(EditText)rootView.findViewById(R.id.noteEditText);

        btnAdd=(Button)rootView.findViewById(R.id.buttonAdd);
        btnAdd.setOnClickListener(this);

        searchRoomButton=rootView.findViewById(R.id.searchButton);

        searchRoomButton.setOnClickListener(this);

        addRequestLayout=(CardView)rootView.findViewById(R.id.addRequestLayout);

        departmentsSpinner=(Spinner)rootView.findViewById(R.id.spinner);
        requestsSpinner=(Spinner)rootView.findViewById(R.id.spinner2);


        addRequestDTO=new AddRequestDTO();


        searchView =  rootView.findViewById(R.id.roomSearchView);
        //permite modificar el hint que el EditText muestra por defecto
        /*searchView.setQueryHint(getText(R.string.menu_search));
        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {

                return true;
            }
            @Override
            public boolean onQueryTextChange(String newText) {
                //textView.setText(newText);
                return true;
            }
        });

        */

        return rootView;
    }

    private void retrieveDepartmentsData() {
        RequestParams rp = new RequestParams();
        rp.add("mod", "getDepartmentsList");
        rp.add("roomNumber", String.valueOf(addRequestDTO.getRoomId()));
        HttpUtil.get( "requests.php",rp,new JsonHttpResponseHandler() {
            @Override
            public void onSuccess(int statusCode, Header[] headers, JSONArray response) {

                if (statusCode==200){

                    Log.e(FragmentAddRequestFrontDesk.class.getSimpleName(), "onSuccess: " + response );

                    Gson gson= new Gson();

                    DepartmentDTO[] arr = gson.fromJson(response.toString(), DepartmentDTO[].class);
                    final List departments  = new ArrayList(Arrays.asList(arr));

                    if (!departments.isEmpty()){
                        departments.add(0,new DepartmentDTO(-1,"Select department"));
                        addRequestLayout.setVisibility(View.VISIBLE);
                        final ArrayAdapter<String> spinnerArrayAdapter = new ArrayAdapter<String>
                                (getActivity(), android.R.layout.simple_spinner_item,
                                        departments);
                        spinnerArrayAdapter.setDropDownViewResource(R.layout
                                .spinner_item_layout);
                        departmentsSpinner.setAdapter(spinnerArrayAdapter);
                        departmentsSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                            @Override
                            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                                int idSelected=((DepartmentDTO)departments.get(i)).getId();
                                if (idSelected!=-1) {
                                    addRequestDTO.setDepartmentId(idSelected);
                                    fillRequestsSpinner(idSelected);
                                }
                            }

                            @Override
                            public void onNothingSelected(AdapterView<?> adapterView) {

                            }
                        });


                    }

                    return;
                }

            }

            @Override
            public void  onFailure(int statusCode, Header[] headers, String responseString, Throwable throwable){
                //throwable.printStackTrace();
                Toast.makeText(getActivity(),responseString, Toast.LENGTH_SHORT).show();

            }


        });

    }

    private void fillRequestsSpinner(int idSelected) {

        RequestParams rp = new RequestParams();
        rp.add("mod", "getRequestsList");
        rp.add("departmentId", String.valueOf(idSelected));
        HttpUtil.get( "requests.php",rp,new JsonHttpResponseHandler() {
            @Override
            public void onSuccess(int statusCode, Header[] headers, JSONArray response) {

                if (statusCode==200){

                    Log.e(FragmentAddRequestFrontDesk.class.getSimpleName(), "onSuccess: " + response );

                    Gson gson= new Gson();

                    DepartmentDTO[] arr = gson.fromJson(response.toString(), DepartmentDTO[].class);
                    final List departments  = new ArrayList(Arrays.asList(arr));

                    if (!departments.isEmpty()){
                        departments.add(0,new DepartmentDTO(-1,"Select request"));
                        addRequestLayout.setVisibility(View.VISIBLE);
                        final ArrayAdapter<String> spinnerArrayAdapter = new ArrayAdapter<String>
                                (getActivity(), android.R.layout.simple_spinner_item,
                                        departments);
                        spinnerArrayAdapter.setDropDownViewResource(R.layout.spinner_item_layout);
                        requestsSpinner.setAdapter(spinnerArrayAdapter);
                        requestsSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                            @Override
                            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                                int idSelected=((DepartmentDTO)departments.get(i)).getId();
                                if (idSelected!=-1){
                                    btnAdd.setEnabled(true);
                                    addRequestDTO.setRequestId(idSelected);
                                }else
                                    btnAdd.setEnabled(false);
                            }

                            @Override
                            public void onNothingSelected(AdapterView<?> adapterView) {

                            }
                        });


                    }

                    return;
                }

            }

            @Override
            public void  onFailure(int statusCode, Header[] headers, String responseString, Throwable throwable){
                //throwable.printStackTrace();
                Toast.makeText(getActivity(),responseString, Toast.LENGTH_SHORT).show();

            }


        });



    }


    @Override
    public void onClick(View view) {
        switch (view.getId()){

            case R.id.searchButton:{
                RequestParams rp = new RequestParams();
                rp.add("mod", "validateRoomNumber");

                roomSearchQuery=searchView.getText().toString();
                rp.add("roomNumber", roomSearchQuery);



                HttpUtil.get( "requests.php",rp,new JsonHttpResponseHandler() {
                    @Override
                    public void onSuccess(int statusCode, Header[] headers, JSONArray response) {

                        if (statusCode==200){

                            Gson gson= new Gson();

                            RoomDTO[] arr = gson.fromJson(response.toString(), RoomDTO[].class);
                            List rooms  = new ArrayList(Arrays.asList(arr));



                            if (!rooms.isEmpty()){
                                addRequestLayout.setVisibility(View.VISIBLE);
                                addRequestDTO.setRoomId(((RoomDTO)rooms.get(0)).getRoomId());
                                retrieveDepartmentsData();

                            }else{
                                getActivity().getSupportFragmentManager()
                                        .beginTransaction()
                                        .replace(R.id.root,new NoResultsFragment(), NoResultsFragment.class.getSimpleName())
                                        .addToBackStack("noResult")
                                        .commit();
                            }

                            return;
                        }

                    }

                    @Override
                    public void  onFailure(int statusCode, Header[] headers, String responseString, Throwable throwable){
                        //throwable.printStackTrace();
                        Toast.makeText(getActivity(), responseString, Toast.LENGTH_SHORT).show();

                    }


                });

                break;
            }

            case R.id.tvDate:{

                DialogFragment newFragment = new DatePickerFragment();
                newFragment.show(getActivity().getSupportFragmentManager(), "datePicker");
                break;
            }
            case R.id.tvHour:{

                Calendar mcurrentTime = Calendar.getInstance();
                int hour = mcurrentTime.get(Calendar.HOUR_OF_DAY);
                int minute = mcurrentTime.get(Calendar.MINUTE);
                TimePickerDialog mTimePicker;
                mTimePicker = new TimePickerDialog(getActivity(), new TimePickerDialog.OnTimeSetListener() {
                    @Override
                    public void onTimeSet(TimePicker timePicker, int selectedHour, int selectedMinute) {

                        showTime(selectedHour, selectedMinute);
                    }
                }, hour, minute, true);//Yes 24 hour time
                mTimePicker.setTitle("Select Time");
                mTimePicker.show();

                break;
            }
            case R.id.checkBox:{
                dateTextView.setVisibility(dateTextView.getVisibility() == View.INVISIBLE ? View.VISIBLE : View.INVISIBLE);
                hourTextView.setVisibility(hourTextView.getVisibility() == View.INVISIBLE ? View.VISIBLE : View.INVISIBLE);
                break;
            }
            case R.id.buttonAdd:{

                RequestParams rp = new RequestParams();
                rp.add("mod", "addRequest");
                rp.add("roomId", String.valueOf(addRequestDTO.getRoomId()));
                rp.add("note", noteEditText.getText().toString());
                rp.add("delayDate", dateTextView.getText().toString());
                rp.add("delayTime", hourTextView.getText().toString());
                rp.add("requestId",String.valueOf(addRequestDTO.getRequestId()));
                rp.add("departmentId",String.valueOf(addRequestDTO.getDepartmentId()));
                rp.add("delay", delayCheckBox.isSelected() ? "on" : "off");

                Log.e(FragmentAddRequestFrontDesk.class.getSimpleName(), "onClick: "+rp.toString());

                HttpUtil.post( "requests.php",rp,new JsonHttpResponseHandler() {
                    @Override
                    public void onSuccess(int statusCode, Header[] headers, JSONArray response) {

                        if (statusCode==200){
                            RequestParams rp = new RequestParams();
                            rp.add("mod", "getAllRequests");


                            HttpUtil.get( "requests.php",rp,new JsonHttpResponseHandler() {
                                @Override
                                public void onSuccess(int statusCode, Header[] headers, JSONArray response) {

                                    if (statusCode==200){

                                        Bundle bundle= new Bundle();

                                        bundle.putString("requests",response.toString());

                                        FragmentRequestsList frl=new FragmentRequestsList();
                                        frl.setArguments(bundle);

                                        getActivity().getSupportFragmentManager().beginTransaction()
                                                .replace(R.id.root, frl, FragmentRequestsList.class.getSimpleName())
                                                .addToBackStack("requests")
                                                .commit();

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



                            return;
                        }

                    }

                    @Override
                    public void  onFailure(int statusCode, Header[] headers, String responseString, Throwable throwable){
                        //throwable.printStackTrace();
                        Toast.makeText(getActivity(),responseString, Toast.LENGTH_SHORT).show();

                        Log.e(FragmentAddRequestFrontDesk.class.getSimpleName(), "FAILURE"+responseString );

                    }


                });




                break;
            }
            default: break;
        }
    }

    private String formatDelayString() {


        return dateTextView.getText().toString().concat(" ").concat(hourTextView.getText().toString());


    }


    public void showTime(int hour, int min) {

        String format;
        String hourStr=String.valueOf(hour);
        String minuteStr = String.valueOf(min);

        if (hour == 0) {
            hour += 12;
            format = "AM";
        } else if (hour == 12) {
            format = "PM";
        } else if (hour > 12) {
            hour -= 12;
            format = "PM";
        } else {
            format = "AM";
        }

        if (min<=9)
            minuteStr="0".concat(String.valueOf(min));
        if (hour<=9)
            hourStr="0".concat(String.valueOf(hour));

        hourTextView.setText(new StringBuilder().append(hourStr).append(" : ").append(minuteStr)
                .append(" ").append(format));
    }


    public static class DatePickerFragment extends DialogFragment
            implements DatePickerDialog.OnDateSetListener {

        @Override
        public Dialog onCreateDialog(Bundle savedInstanceState) {
            // Use the current date as the default date in the picker
            final Calendar c = Calendar.getInstance();
            int year = c.get(Calendar.YEAR);
            int month = c.get(Calendar.MONTH);
            int day = c.get(Calendar.DAY_OF_MONTH);

            // Create a new instance of DatePickerDialog and return it
            return new DatePickerDialog(getActivity(), this, year, month, day);
        }

        public void onDateSet(DatePicker view, int year, int month, int day) {
            FragmentAddRequestFrontDesk.dateTextView.setText((month + 1) + "/" + day+"/"+year);
        }
    }


}
