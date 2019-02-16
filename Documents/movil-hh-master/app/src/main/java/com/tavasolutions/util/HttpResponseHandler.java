package com.tavasolutions.util;

import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONObject;

import cz.msebera.android.httpclient.Header;

public class HttpResponseHandler extends JsonHttpResponseHandler{

    @Override
    public void onSuccess(int statusCode, Header[] headers, JSONObject response) {


        if(statusCode == 422) {

        }
    }

    @Override
    public void onFailure(int statusCode, Header[] headers, Throwable e, JSONObject errorResponse) {

    }
}