package com.tavasolutions.fragments;

import android.app.DatePickerDialog;
import android.app.Dialog;
import android.app.TimePickerDialog;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.DatePicker;
import android.widget.TextView;
import android.widget.TimePicker;

import java.util.Calendar;

import hotel.tavasolutions.com.hotel.R;

public class FragmentAddRequestFrontDesk extends Fragment implements View.OnClickListener {

    View rootView;

    static TextView dateTextView, hourTextView;

    CheckBox delayCheckBox;

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

        return rootView;
    }


    @Override
    public void onClick(View view) {
        switch (view.getId()){
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
                        hourTextView.setText( selectedHour + ":" + selectedMinute);
                    }
                }, hour, minute, false);//Yes 24 hour time
                mTimePicker.setTitle("Select Time");
                mTimePicker.show();

                break;
            }
            case R.id.checkBox:{
                dateTextView.setVisibility(dateTextView.getVisibility() == View.INVISIBLE ? View.VISIBLE : View.INVISIBLE);
                hourTextView.setVisibility(hourTextView.getVisibility() == View.INVISIBLE ? View.VISIBLE : View.INVISIBLE);
                break;
            }
            default: break;
        }
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
            FragmentAddRequestFrontDesk.dateTextView.setText(day + "/" + (month + 1) + "/" + year);
        }
    }


}
