package hotel.tavasolutions.com.hotel;

import android.app.SearchManager;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.view.MenuItemCompat;
import android.support.v7.widget.SearchView;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.view.View;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Toast;

import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import com.tavasolutions.dto.UserDTO;
import com.tavasolutions.enums.EnumProfile;
import com.tavasolutions.fragments.FragmentRequestLobby;
import com.tavasolutions.util.HttpUtil;
import com.tavasolutions.util.Variable;

import org.json.JSONArray;
import org.json.JSONObject;

import cz.msebera.android.httpclient.Header;

public class MainActivity extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener {

    //hotel
    NavigationView navigationView  ;

    SearchView searchView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        UserDTO user = Variable.user;
        int activity = 0;

        if (user.getId_profile() == EnumProfile.HOUSEKEEPING_MANAGER.getValue())
            activity = R.layout.activity_main;
        if (user.getId_profile() == EnumProfile.FRONTDESK.getValue())
            activity  =R.layout.activity_front_desk;
        if (user.getId_profile() == EnumProfile.LOBBY.getValue())
            activity  =R.layout.activity_lobby;

        if (activity==0){
            Toast.makeText(getApplicationContext(), "We are sorry, Access denied", Toast.LENGTH_SHORT).show();
            return;
        }

        setContentView(activity);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        });

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.addDrawerListener(toggle);
        toggle.syncState();


        //NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);

        if (user.getId_profile() == EnumProfile.HOUSEKEEPING_MANAGER.getValue()){

            MenuItem item = (MenuItem) navigationView.getMenu().findItem(R.id.menu_hkp);
            SpannableString s = new SpannableString("Housekeeping");
            s.setSpan(new ForegroundColorSpan(Color.WHITE), 0, s.length(), 0);
            item.setTitle(s);


            item = (MenuItem) navigationView.getMenu().findItem(R.id.menu_hkp_requests);
            SpannableString s1 = new SpannableString("Requests");
            s1.setSpan(new ForegroundColorSpan(Color.WHITE), 0, s1.length(), 0);
            item.setTitle(s1);

            item = (MenuItem) navigationView.getMenu().findItem(R.id.menu_hkp_settings);
            SpannableString s2 = new SpannableString("Settings");
            s2.setSpan(new ForegroundColorSpan(Color.WHITE), 0, s2.length(), 0);
            item.setTitle(s2);

            item = (MenuItem) navigationView.getMenu().findItem(R.id.menu_settings);
            SpannableString s3 = new SpannableString("Settings");
            s3.setSpan(new ForegroundColorSpan(Color.WHITE), 0, s3.length(), 0);
            item.setTitle(s3);

            item = (MenuItem) navigationView.getMenu().findItem(R.id.menu_users);
            SpannableString s4 = new SpannableString("Users");
            s4.setSpan(new ForegroundColorSpan(Color.WHITE), 0, s4.length(), 0);
            item.setTitle(s4);

            item = (MenuItem) navigationView.getMenu().findItem(R.id.menu_parameters);
            SpannableString s5 = new SpannableString("Parameters");
            s5.setSpan(new ForegroundColorSpan(Color.WHITE), 0, s5.length(), 0);
            item.setTitle(s5);

            item = (MenuItem) navigationView.getMenu().findItem(R.id.menu_hkp_issues_hkp);
            SpannableString s6 = new SpannableString("Issues Housekeeping");
            s6.setSpan(new ForegroundColorSpan(Color.WHITE), 0, s6.length(), 0);
            item.setTitle(s6);

            item = (MenuItem) navigationView.getMenu().findItem(R.id.menu_hkp_issues_main);
            SpannableString s7 = new SpannableString("Issues Maintenance");
            s7.setSpan(new ForegroundColorSpan(Color.WHITE), 0, s7.length(), 0);
            item.setTitle(s7);
        }





    }

    @Override
    public void onBackPressed() {
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        final MenuItem searchItem = menu.findItem(R.id.menu_search);
        final SearchView searchView = (SearchView) MenuItemCompat.getActionView(searchItem);
        //permite modificar el hint que el EditText muestra por defecto
        searchView.setQueryHint(getText(R.string.menu_search));
        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {

                Log.e(MainActivity.class.getSimpleName(), "onQueryTextSubmit: "+ searchView.getQuery() );
                RequestParams rp = new RequestParams();
                rp.add("mod", "validateRoomNumber");
                rp.add("roomNumber", searchView.getQuery().toString());


                HttpUtil.get( "requests.php",rp,new JsonHttpResponseHandler() {
                    @Override
                    public void onSuccess(int statusCode, Header[] headers, JSONArray response) {

                        if (statusCode==200){

                            Toast.makeText(MainActivity.this, "response!!!", Toast.LENGTH_SHORT).show();

                            return;
                        }

                    }

                    @Override
                    public void  onFailure(int statusCode, Header[] headers, String responseString, Throwable throwable){
                        //throwable.printStackTrace();
                         Toast.makeText(getApplicationContext(), responseString, Toast.LENGTH_SHORT).show();

                    }


                });
                searchView.setQuery("", false);
                searchView.setIconified(true);
                return true;
            }
            @Override
            public boolean onQueryTextChange(String newText) {
                //textView.setText(newText);
                return true;
            }
        });


        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }


        return super.onOptionsItemSelected(item);
    }

    @SuppressWarnings("StatementWithEmptyBody")
    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.
        int id = item.getItemId();

        Menu navMenu = navigationView.getMenu();

        if (id == R.id.menu_hkp_settings) {
            MenuItem menu_hkp_issues_hkp = navMenu.findItem(R.id.menu_hkp_issues_hkp);
            boolean visible = menu_hkp_issues_hkp.isVisible();

            navMenu.findItem(R.id.menu_hkp_issues_hkp).setVisible(!visible);
            navMenu.findItem(R.id.menu_hkp_issues_main).setVisible(!visible);

            if(visible)
                navMenu.findItem(R.id.menu_hkp_settings).setActionView(R.layout.menu_right_image);
            else
                navMenu.findItem(R.id.menu_hkp_settings).setActionView(R.layout.menu_down_image);

            //navMenu.findItem(R.id.menu_colegio).setActionView(R.layout.menu_down_image);
        }
        if (id == R.id.menu_front_init) {

            Intent intent = new Intent(this, FrontDeskInititateActivity.class);
            startActivity(intent);
            return true;

        } else if (id == R.id.menu_lobby) {

            getSupportFragmentManager()
                    .beginTransaction()
                    .replace(R.id.root,new FragmentRequestLobby(), FragmentRequestLobby.class.getSimpleName())
                    .addToBackStack("import")
                    .commit();
        } else if (id == R.id.nav_slideshow) {

        } else if (id == R.id.nav_manage) {

        } else if (id == R.id.nav_share) {

        } else if (id == R.id.nav_send) {

        }

        if (navMenu.findItem(id).getActionView()==null){
            DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
            drawer.closeDrawer(GravityCompat.START);
        }


        return true;
    }
}
