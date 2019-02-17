package hotel.tavasolutions.com.hotel;


import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.preference.PreferenceActivity;
import android.support.design.widget.TextInputLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import com.tavasolutions.dto.ErrorDTO;

import com.tavasolutions.dto.UserDTO;
import com.tavasolutions.services.SecurityService;
import com.tavasolutions.util.Constant;
import com.tavasolutions.util.HttpUtil;
import com.tavasolutions.util.Variable;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import cz.msebera.android.httpclient.Header;


public class Login extends AppCompatActivity {

    private Toolbar toolbar;
    private EditText inputName,  inputPassword;
    private TextInputLayout inputLayoutName, inputLayoutPassword;
    private TextView btn_loguearse;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);


        TextView txt = (TextView) findViewById(R.id.textView1);
        Typeface font = Typeface.createFromAsset(getAssets(), "fonts/fontawesome-webfont.ttf");
        txt.setTypeface(font);
        txt.setText(getString(R.string.fa_jsfiddle));

        /*
        Spinner spinner = (Spinner) findViewById(R.id.planets_spinner);
        */

// Create an ArrayAdapter using the string array and a default spinner layout
       //////////// ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(this,
                /////////////R.array.planets_array, android.R.layout.simple_spinner_item);
// Specify the layout to use when the list of choices appears
        ////////////adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
// Apply the adapter to the spinner
        //////////////spinner.setAdapter(adapter);


        inputLayoutName = (TextInputLayout) findViewById(R.id.input_layout_usuario);
        inputLayoutPassword = (TextInputLayout) findViewById(R.id.input_layout_password);
        inputName = (EditText) findViewById(R.id.username_input);
        inputPassword = (EditText) findViewById(R.id.pass);
        btn_loguearse = findViewById(R.id.btn_loguearse);

        inputName.addTextChangedListener(new MyTextWatcher(inputName));
        inputPassword.addTextChangedListener(new MyTextWatcher(inputPassword));

        btn_loguearse.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                submitForm();
            }
        });
    }

    /**
     * Validating form
     */
    private void submitForm() {
        if (!validateName()) {
            return;
        }
        if (!validatePassword()) {
            return;
        }

        Log.e(Login.class.getSimpleName(), "submitForm: VALIDATIONS SUCCEDED!! " );


        RequestParams rp = new RequestParams();
        rp.add("mod", "login");
        rp.add("user", inputName.getText().toString());
        rp.add("password",inputPassword.getText().toString());
        rp.add("hotelId","1");



        HttpUtil.get( "security.php",rp,new JsonHttpResponseHandler() {
            @Override
            public void onSuccess(int statusCode, Header[] headers, JSONObject response) {

                if (statusCode!=200){

                    Gson gson= new Gson();
                    ErrorDTO obj= gson.fromJson(response.toString(),ErrorDTO.class);

                    Toast.makeText(getApplicationContext(), "ERROR!" + obj.getMsg(), Toast.LENGTH_SHORT).show();


                    Toast.makeText(getApplicationContext(), "ERROR!", Toast.LENGTH_SHORT).show();
                    return;
                }


                try {
                    Gson gson= new Gson();
                    UserDTO obj= gson.fromJson(response.toString(),UserDTO.class);

                    Toast.makeText(getApplicationContext(), "Welcome! " + obj.getFirst_name(), Toast.LENGTH_SHORT).show();

                    Variable.user = obj;
                    startActivity(new Intent(Login.this, MainActivity.class));

                    // close splash activity
                    finish();
                    //JSONObject serverResp = new JSONObject(response.toString());
                } catch (Exception e) {
                    //e.printStackTrace();
                     Toast.makeText(getApplicationContext(), "ERROR:" +  e.getMessage(), Toast.LENGTH_SHORT).show();


                }
            }

            @Override
            public void  onFailure(int statusCode, Header[] headers, String responseString, Throwable throwable){
                //throwable.printStackTrace();
                Toast.makeText(getApplicationContext(), responseString, Toast.LENGTH_SHORT).show();

            }


        });



    }

    private boolean validateName() {
        if (inputName.getText().toString().trim().equals("")) {
            inputName.setError(getString(R.string.err_msg_name));
            requestFocus(inputName);
            return false;
        } else {
            inputName.setError(null);
        }

        return true;
    }



    private boolean validatePassword() {
        if (inputPassword.getText().toString().trim().equals("")) {
            inputPassword.setError(getString(R.string.err_msg_password));
            requestFocus(inputPassword);
            return false;
        } else {
            inputPassword.setError(null);
        }

        return true;
    }

    private static boolean isValidEmail(String email) {
        return !TextUtils.isEmpty(email) && android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches();
    }

    private void requestFocus(View view) {
        if (view.requestFocus()) {
            getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);
        }
    }

    private class MyTextWatcher implements TextWatcher {

        private View view;

        private MyTextWatcher(View view) {
            this.view = view;
        }

        public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {
        }

        public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
        }

        public void afterTextChanged(Editable editable) {
            switch (view.getId()) {
                case R.id.input_usuario:
                    validateName();
                    break;
                case R.id.input_password:
                    validatePassword();
                    break;
            }
        }
    }
}