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

//Create geofence
//Delete all geofences
//Delete geofence by id
//Disable
//Enable
//Find geofence
//Get all geofences

var Geofence = function(){
	
};
Geofence.prototype.initializeService = function(successCallback,errorCallback){
		return PhoneGap.exec(successCallback,  
	 	errorCallback,     
	 	'GeofencePlugin',  
	 	'initialize_service',   
	 	[]);
};
Geofence.prototype.setupCallbacks = function(authSuccessCallback, authFailureCallback, entryTriggerCallback,exitTriggerCallback,serviceFailureCallback,successCallback,errorCallback){
		return PhoneGap.exec(successCallback,  
	 	errorCallback,     
	 	'GeofencePlugin',  
	 	'setup_callbacks',   
	 	[GetFunctionName(authSuccessCallback),GetFunctionName(authFailureCallback),GetFunctionName(entryTriggerCallback),GetFunctionName(exitTriggerCallback),GetFunctionName(serviceFailureCallback)]);
};
Geofence.prototype.createGeofence = function(eid,lat,lng,rad,type,successCallback,errorCallback){
		return PhoneGap.exec(successCallback,  
	 	errorCallback,     
	 	'GeofencePlugin',  
	 	'create_geofence',   
	 	[eid,lat,lng,rad,type]);
};
Geofence.prototype.deleteAllGeofences = function(successCallback,errorCallback){
		return PhoneGap.exec(successCallback,  
	 	errorCallback,     
	 	'GeofencePlugin',  
	 	'delete_all_geofences',   
	 	[]);
};
Geofence.prototype.deleteGeofence = function(id,successCallback,errorCallback){
		return PhoneGap.exec(successCallback,  
	 	errorCallback,     
	 	'GeofencePlugin',  
	 	'delete_geofence',   
	 	[id]);
};
Geofence.prototype.disable = function(successCallback,errorCallback){
		return PhoneGap.exec(successCallback,  
	 	errorCallback,     
	 	'GeofencePlugin',  
	 	'disable',   
	 	[]);
};
Geofence.prototype.enable = function(successCallback,errorCallback){
		return PhoneGap.exec(successCallback,  
	 	errorCallback,     
	 	'GeofencePlugin',  
	 	'enable',   
	 	[]);
};
Geofence.prototype.findGeofence = function(id,successCallback,errorCallback){
		return PhoneGap.exec(successCallback,  
	 	errorCallback,     
	 	'GeofencePlugin',  
	 	'find_geofence',   
	 	[id]);
};
Geofence.prototype.getAllGeofences = function(successCallback,errorCallback){
		return PhoneGap.exec(successCallback,  
	 	errorCallback,     
	 	'GeofencePlugin',  
	 	'get_all_geofences',   
	 	[]);
};
Geofence.prototype.getCurrentLocation = function(successCallback,errorCallback){
		return PhoneGap.exec(successCallback,  
	 	errorCallback,     
	 	'GeofencePlugin',  
	 	'get_current_location',   
	 	[]);
};
Geofence.prototype.getLastKnownLocation = function(successCallback,errorCallback){
		return PhoneGap.exec(successCallback,  
	 	errorCallback,     
	 	'GeofencePlugin',  
	 	'get_last_known_location',   
	 	[]);
};
PhoneGap.addConstructor(function() {
//Register the javascript plugin with PhoneGap
PhoneGap.addPlugin('geofence', new Geofence());
//Register the native class of plugin with PhoneGap
PluginManager.addService("GeofencePlugin","com.sortaprecisiontech.llgeofence.GeofencePlugin");
});
