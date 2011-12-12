/*
Copyright (c) 2011 Omar Hussain

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

The Software shall be used for Good, not Evil.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

package com.sortaprecisiontech.llgeofence;

import java.util.ArrayList;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.location.Location;
import android.os.Bundle;
import android.os.IBinder;
import android.os.Looper;
import android.util.Log;


import com.locationlabs.geofence.BorderEvent;
import com.locationlabs.geofence.CircularGeofenceSpec;
import com.locationlabs.geofence.Geofence;
import com.locationlabs.geofence.GeofenceService;
import com.locationlabs.geofence.GeofenceSpec;

import android.content.ServiceConnection;

import com.phonegap.api.Plugin;
import com.phonegap.api.PluginResult;
import com.phonegap.api.PluginResult.Status;
import com.sortaprecisiontech.llgeofence.MyLocation.LocationResult;

public class GeofencePlugin extends Plugin{
	
	protected static final String LOG = "<Your App Name>";
	public static GeofencePlugin sharedGeofencePlugin;
    public static final String GEOFENCE_FIRED = "com.sortaprecisiontech.llgeofence.GEOFENCE_FIRED";
    public static final String AUTH_SUCCESS = "com.sortaprecisiontech.llgeofence.AUTH_SUCCESS";
    public static final String AUTH_FAILURE = "com.sortaprecisiontech.llgeofence.AUTH_FAILURE";
    private static final String CREATE_GEOFENCE = "create_geofence";
    private static final String DELETE_GEOFENCE = "delete_geofence";
    private static final String DELETE_ALL_GEOFENCES = "delete_all_geofences";
    private static final String FIND_GEOFENCE = "find_geofence";
    private static final String GET_ALL_GEOFENCES = "get_all_geofences";
    private static final String SET_CALLBACKS = "setup_callbacks";
    private static final String GET_CURRENT_LOCATION = "get_current_location";
    private static final String GET_LAST_KNOWN_LOCATION = "get_last_known_location";
    private static final String INITIALIZE_SERVICE = "initialize_service";
    private static final String ENABLE = "enable";
    public static final String  DISABLE = "disable";
    
    private String SERVICE_FAILURE_CALLBACK;
    private String GEOFENCE_ENTRY_CALLBACK;
    private String GEOFENCE_EXIT_CALLBACK;
    private String AUTH_SUCCESS_CALLBACK;
	private String AUTH_FAILURE_CALLBACK;
    
    private static final String CONSUMER_KEY    = "<Your Consumer Key>";
    private static final String CONSUMER_SECRET = "<Your Consumer Secret>llgeofence";
    
    private ServiceConnection serviceConnection = null;
    private GeofenceService mService = null;
    private GeofenceReceiver receiver;
    public Location location;
    public MyLocation myLocation;
    
    public GeofencePlugin(){
    	sharedGeofencePlugin = this;
    	myLocation = new MyLocation();
    	final LocationResult locationResult = new LocationResult(){
    	    @Override
    	    public void gotLocation(final Location location){
    	        GeofencePlugin.sharedGeofencePlugin.location = location;
    	        };
    	    };
    	    Thread thread = new Thread(new Runnable(){
    	    	public void run(){
    	    		try {
    	    			myLocation.getLocation(Match.sharedMatch, locationResult);
						
					} catch (Exception e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
    	    	}
    	    	
    	    });
    	    thread.start();
    	
    	
    	
    }
    
	@Override
	public PluginResult execute(String action, JSONArray data, String callback) {
		Looper.myLooper().prepare();
		PluginResult result = null;
		if(action.equalsIgnoreCase(INITIALIZE_SERVICE)){
			try{
				
			 receiver = new GeofenceReceiver();
			 ctx.registerReceiver(receiver,new IntentFilter(GEOFENCE_FIRED));
			 ctx.registerReceiver(receiver,new IntentFilter(AUTH_SUCCESS));
			 ctx.registerReceiver(receiver,new IntentFilter(AUTH_FAILURE));
			 // create our ServiceConnection
			 	serviceConnection = new ServiceConnection() {
			    
				 public void onServiceConnected(ComponentName name, IBinder service) {
			       mService = ((GeofenceService.ServiceBinder)service).getService();
			       mService.setConsumerKeyAndSecret(CONSUMER_KEY, CONSUMER_SECRET);
			       mService.setAuthorizationActions(AUTH_SUCCESS, AUTH_FAILURE, GeofenceReceiver.class);
			       mService.authorize();
			       mService.enable();
			       
			    }

			    public void onServiceDisconnected(ComponentName name) {
			       // geofences still persist
			    	mService = null;
			    }

			 };
			 
			 if (!(ctx.bindService(new Intent(ctx, GeofenceService.class),
					 serviceConnection, Context.BIND_AUTO_CREATE))) {
				 Log.w(LOG, "Failed to bind to GeofenceService");
			 }
			 
			 result = new PluginResult(PluginResult.Status.OK,
				"Service start signal sent.");
			}catch(Exception e){
				result = new PluginResult(Status.ERROR, e.getMessage());
			}

		}
		else if(action.equalsIgnoreCase(CREATE_GEOFENCE)){
			
			try {
				int externalIdentifier = data.getInt(0); //identifier to identify the related object internally
				double latitude = data.getDouble(1);
				double longitude = data.getDouble(2);
				float radius = (float)data.getDouble(3);
				int crossingType = data.getInt(4);
				Geofence g = AddGeofence(latitude, longitude, radius, crossingType);
				org.yajl.JSONObject tmp = new org.yajl.JSONObject(g);
				tmp.append("EID", externalIdentifier);
				String str = tmp.toString();
				tmp = null;
				Log.d("Service_Output", str);
				JSONObject resultobject = new JSONObject(str);
				str = null;
				result = new PluginResult(PluginResult.Status.OK,
						resultobject);
				
			} catch (Exception e) {
				result = new PluginResult(Status.ERROR, e.getMessage());
			}
			
		}else if(action.equalsIgnoreCase(DELETE_GEOFENCE)){
			try{
				long id = data.getLong(0);
				DeleteGeofence(id);
				result = new PluginResult(PluginResult.Status.OK,
						"Geofence deleted successfully.");
			}catch(Exception e){
				result = new PluginResult(Status.ERROR, e.getMessage());
			}
			
		}else if(action.equalsIgnoreCase(DELETE_ALL_GEOFENCES)){
			try{
				DeleteAllGeofences();
				result = new PluginResult(PluginResult.Status.OK,
						"Geofences deleted successfully.");
			}catch(Exception e){
				result = new PluginResult(Status.ERROR, e.getMessage());
			}
		}else if(action.equalsIgnoreCase(FIND_GEOFENCE)){
			try{
				long id = data.getLong(0);
				Geofence g = FindGeofence(id);
				org.yajl.JSONObject tmp = new org.yajl.JSONObject(g);
				String str = tmp.toString();
				tmp = null;
				Log.d("Service_Output", str);
				JSONObject resultobject = new JSONObject(str);
				str = null;
				result = new PluginResult(PluginResult.Status.OK,
						resultobject);
			}catch(Exception e){
				result = new PluginResult(Status.ERROR, e.getMessage());
			}
		}else if(action.equalsIgnoreCase(GET_ALL_GEOFENCES)){
			try{
				ArrayList<Geofence> geofences = GetAllGeofences();
				org.yajl.JSONArray tmp = new org.yajl.JSONArray(geofences);
				String str = tmp.toString();
				tmp = null;
				Log.d("Service_Output", str);
				JSONArray resultobject = new JSONArray(str);
				str = null;
				result = new PluginResult(PluginResult.Status.OK,
						resultobject);
				
			}catch(Exception e){
				result = new PluginResult(Status.ERROR, e.getMessage());
			}
		}else if(action.equalsIgnoreCase(GET_CURRENT_LOCATION)){
			try{
				if(mService != null){
					Thread.sleep(5000);
					Location loc = location;
					org.yajl.JSONObject obj = new org.yajl.JSONObject(loc);
					JSONObject resultobject = new JSONObject(obj.toString());
					result = new PluginResult(PluginResult.Status.OK,resultobject);
				}else{
					result = new PluginResult(PluginResult.Status.ERROR,"Service not running.");
				}
			}catch(Exception e){
				result = new PluginResult(Status.ERROR, e.getMessage());
			}
		}else if(action.equalsIgnoreCase(GET_LAST_KNOWN_LOCATION)){
			try{
				if(mService != null){
					Location loc = mService.getLastKnownLocation();
					org.yajl.JSONObject obj = new org.yajl.JSONObject(loc);
					JSONObject resultobject = new JSONObject(obj.toString());
					result = new PluginResult(PluginResult.Status.OK,resultobject);
				}
			}catch(Exception e){
				result = new PluginResult(Status.ERROR, e.getMessage());
			}
		}else if(action.equalsIgnoreCase(SET_CALLBACKS)){
			try{
				AUTH_SUCCESS_CALLBACK = data.getString(0);
				AUTH_FAILURE_CALLBACK = data.getString(1);
				GEOFENCE_ENTRY_CALLBACK = data.getString(2);
				GEOFENCE_EXIT_CALLBACK = data.getString(3);
				SERVICE_FAILURE_CALLBACK = data.getString(4);
				result = new PluginResult(Status.OK, "Callbacks setup Successfully.");
			}catch(Exception e){
				result = new PluginResult(Status.ERROR, e.getMessage());
			}
		}else if(action.equalsIgnoreCase(ENABLE)){
			try{
				mService.enable();
				result = new PluginResult(Status.OK, "Service Enabled Successfully.");
			}catch(Exception e){
				result = new PluginResult(Status.ERROR, e.getMessage());
			}
		}else if(action.equalsIgnoreCase(DISABLE)){
			try{
				mService.disable();
				result = new PluginResult(Status.OK, "Service Disabled Successfully.");
			}catch(Exception e){
				result = new PluginResult(Status.ERROR, e.getMessage());
			}
		}
		
		return result;
	}
	public void TriggeredGeofence(Bundle extras){
		BorderEvent borderEvent = (BorderEvent) extras.get(BorderEvent.EXTRA_BORDER_EVENT);
        Geofence geofence = (Geofence) extras.get(Geofence.EXTRA_GEOFENCE);
        if (borderEvent == null || geofence == null) {
            Log.w(LOG, "Geofence fired, but report is incomplete.  Will not notify user: " + extras);
        } else {
        	if(borderEvent.getCrossingType() == Geofence.CROSSING_TYPE_ENTER){
        		TriggeredEntryGeofence(geofence);
        	}else if(borderEvent.getCrossingType() == Geofence.CROSSING_TYPE_EXIT){
        		TriggeredExitGeofence(geofence);
        	}
        }
         
	}
	public void TriggeredEntryGeofence(Geofence g){
		org.yajl.JSONObject obj = new org.yajl.JSONObject(g);
		this.webView.loadUrl("javascript:"+GEOFENCE_ENTRY_CALLBACK+"(" + obj.toString()  + ")");
		
	}
	public void TriggeredExitGeofence(Geofence g){
		org.yajl.JSONObject obj = new org.yajl.JSONObject(g);
		this.webView.loadUrl("javascript:"+GEOFENCE_EXIT_CALLBACK+"(" + obj.toString()  + ")");
		
	}
	public void AuthSuccess(){
		this.webView.loadUrl("javascript:"+AUTH_SUCCESS_CALLBACK+"('Success')");
	}
	public void AuthFailure(){
		this.webView.loadUrl("javascript:"+AUTH_FAILURE_CALLBACK+"('Failure')");
	}
	private Geofence AddGeofence(double latitude, double longitude, float radius, int crossingType) {
		Geofence geofence = null;
		if (mService != null) {
            // see comments above in ServiceConnection.onServiceConnected()
            
            // a geofence is always added at the center of the map
        	//Geofence.CROSSING_TYPE_ENTER | Geofence.CROSSING_TYPE_EXIT
                int confirmationInterval = 10;
            
                CircularGeofenceSpec spec = new CircularGeofenceSpec(latitude,
                                                                     longitude,
                                                                     radius,
                                                                     crossingType);
                geofence =
                    mService.createGeofence(spec, confirmationInterval, GEOFENCE_FIRED, GeofenceReceiver.class);
            
        } else {
            Log.w(LOG, "GeofenceService not set, can not add geofence");
        }
        return geofence;
    }
	private void DeleteGeofence(long id) {
        if (mService != null) {
            if (mService.findGeofence(id) != null) {
                Log.i(LOG, "Deleting geofence by id : "+ id);
                mService.deleteById(id);
               
            } else {
                Log.i(LOG, "There are no geofences to delete");
            }
        } else {
            Log.w(LOG, "GeofenceService not set, can not delete all geofences");
        }
    }
	
	private Geofence FindGeofence(long id){
		if (mService != null) {
            return mService.findGeofence(id);
        } else {
            Log.w(LOG, "GeofenceService not set, can not delete all geofences");
        }
		return null;
	}
    private void DeleteAllGeofences() {
        if (mService != null) {
            if (mService.getAllGeofences().size() > 0) {
                Log.i(LOG, "Deleting all (" + mService.getAllGeofences().size() + ") geofences");
                for (Geofence geofence: mService.getAllGeofences()) {
                    try {
                        mService.delete(geofence);
                    } catch (IllegalArgumentException iae) {
                        Log.w(LOG, "Attempted to remove geofence for which no such one exists");
                    }
                }
               
            } else {
                Log.i(LOG, "There are no geofences to delete");
            }
        } else {
            Log.w(LOG, "GeofenceService not set, can not delete all geofences");
        }
    }
    private ArrayList<Geofence> GetAllGeofences(){
    	if (mService != null) {
            return mService.getAllGeofences();
    	}else {
            Log.w(LOG, "GeofenceService not set, can not delete all geofences");
        }
    	return null;
    }
    
    private void Disable() {
        if (mService != null) {
            if (!mService.isEnabled()) {
                Log.w(LOG, "Disabling GeofenceService, but it is already disabled.");
            }
            Log.i(LOG, "Disabling GeofenceService");
            mService.disable();
            if (!mService.isEnabled()) {
                Log.v(LOG, "GeofenceService successfully disabled");
            } else {
                Log.w(LOG, "GeofenceService disable failed");
            }
        } else {
            Log.w(LOG, "GeofenceService not set, can not disable geofences");
        }
    }

    private void Enable() {
        if (mService != null) {
            if (mService.isEnabled()) {
                Log.w(LOG, "Enabling GeofenceService, but it is already enabled.");
            }
            Log.i(LOG, "Enabling GeofenceService");
            mService.enable();
            if (mService.isEnabled()) {
                Log.v(LOG, "GeofenceService successfully enabled");
            } else {
                Log.w(LOG, "GeofenceService enable failed");
            }
        } else {
            Log.w(LOG, "GeofenceService not set, can not enable geofences");
        }
    }

    
    
    private void geofenceFired(Bundle extras) {
        BorderEvent borderEvent = (BorderEvent) extras.get(BorderEvent.EXTRA_BORDER_EVENT);
        Geofence geofence = (Geofence) extras.get(Geofence.EXTRA_GEOFENCE);
        if (borderEvent == null || geofence == null) {
            Log.w(LOG, "Geofence fired, but report is incomplete.  Will not notify user: " + extras);
        } else {
            GeofenceSpec spec = geofence.getSpec();
            if (spec == null) {
                Log.w(LOG, "GeofenceSpec not available");
            } else {
                if (spec instanceof CircularGeofenceSpec) {
                    CircularGeofenceSpec circSpec = (CircularGeofenceSpec) spec;
                    // location of BorderEvent would be another option
                } else {
                    Log.w(LOG, "Unknown type of GeofenceSpec: " + spec.getClass().getName());
                }
            }
            
            //alert(title.toString(), msg.toString());
        }
    }

    private void alert(String title, String msg) {
        AlertDialog b  = new Builder((Match)ctx)
            .setTitle(title)
            .setMessage(msg)
            .setNeutralButton("Ok", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        // do nothing - it will close on its own
                    }
                })
            .show();
    }
	

}
