var Geofence = function(){

};


Geofence.prototype.setupCallbacks = function(entryCallback,exitCallback,recievedCredentialsCallback,serviceFailureCallback,engineFailureCallback){
var options = {
                onServiceFailure:GetFunctionName(serviceFailureCallback),
                onEngineFailure:GetFunctionName(engineFailureCallback),
                onRecievedCredentials: GetFunctionName(recievedCredentialsCallback),
                onEntry:GetFunctionName(entryCallback),
                onExit:GetFunctionName(exitCallback)
                };
    PhoneGap.exec("Geofence.setupCallbacks",options);
};

Geofence.prototype.setFakeLocation = function(lat,lng){
    PhoneGap.exec("Geofence.setFakeLocation",lat,lng);
};

Geofence.prototype.clearFakeLocation = function(){
    PhoneGap.exec("Geofence.clearFakeLocation");
};                                              
Geofence.prototype.getAllGeofences = function(resultsCallback){
    PhoneGap.exec("Geofence.getAllGeofences",{
                  onResults:GetFunctionName(resultsCallback)});
};

Geofence.prototype.getSubscribedLayers = function(resultsCallback){
    PhoneGap.exec("Geofence.getSubscribedLayers",{
    onResults:GetFunctionName(resultsCallback)});
};

Geofence.prototype.subscribeToLayer = function(layerName,circularRadius,successCallback){
    PhoneGap.exec("Geofence.subscribeToLayer",layerName, circularRadius,{
                  onSuccess:GetFunctionName(successCallback),
                  });
};
Geofence.prototype.unsubscribeFromLayer = function(layerName,successCallback){
    PhoneGap.exec("Geofence.unsubscribeFromLayer",layerName,{
                  onSuccess:GetFunctionName(successCallback)
                  });
};
Geofence.prototype.unsubscribeFromAllLayers = function(successCallback){
    PhoneGap.exec("Geofence.unsubscribeFromAllLayers",{
        onSuccess:GetFunctionName(successCallback)
    });
};
Geofence.prototype.queryLayers = function(successCallback){
    PhoneGap.exec("Geofence.queryLayers",
                  {
                  onSuccess:GetFunctionName(successCallback),
                });
};
Geofence.prototype.createAndEnterCircularGeofence = function(lat,lng,radius,successCallback,errorCallback){
    PhoneGap.exec("Geofence.createAndEnterCircularGeofence",lat,lng,radius,
                  {
                  onSuccess:GetFunctionName(successCallback),
                  onError:GetFunctionName(errorCallback)
                  });
};

Geofence.prototype.refreshPOIs = function(lat,lng,radius,successCallback){
    PhoneGap.exec("Geofence.refreshPOIs", lat,lng,radius,
                  {
                  onSuccess:GetFunctionName(successCallback)
                });
                                           
};
Geofence.prototype.querySubscriptions = function(successCallback){
    PhoneGap.exec("Geofence.querySubscriptions",
                  {
                  onSuccess:GetFunctionName(successCallback),
                  });
};                                           
Geofence.prototype.getCurrentLocation = function(successCallback){
    PhoneGap.exec("Geofence.getCurrentLocation",
    {
        onSuccess:GetFunctionName(successCallback),
    });
};  

PhoneGap.addConstructor(function()  {
    if(!window.plugins) {
        window.plugins = {};
    }
    window.plugins.geofence = new Geofence();
});
