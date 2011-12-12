//
//  Geofence.m
//  USVIHA
//
//  Created by OmarHussain on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Geofence.h"
#import "XMLRPCWebServices.h"
#import "USVIHAAppDelegate.h"
@implementation Geofence

#define DEFAULT_QUERY_RADIUS 90
#define APP_PARAM_OAUTH_CONSUMER_KEY @"<Your Consumer Key>"
#define APP_PARAM_OAUTH_CONSUMER_SECRET @"<Your Consumer Secret>"

@synthesize entryTriggerCallback, exitTriggerCallback, serviceFailureCallback, engineFailureCallback, receivedCredentialsCallback;



-(PhoneGapCommand*) initWithWebView:(UIWebView*)theWebView
{
    self = (Geofence *)[super initWithWebView:theWebView];
    if (self) 
	{
        
        pointsOfInterest = [[NSArray array] retain];
        BOOL enabled =  [LLGeofence enableWithDelegate:self 
                                           consumerKey:APP_PARAM_OAUTH_CONSUMER_KEY
                                             andSecret:APP_PARAM_OAUTH_CONSUMER_SECRET];
        NSLog(@"LLGeofence enableWithDelegate returned %d", enabled);
        [LLGeofence setQualityOfService:LLGeofenceQOSAggressive];
        [LLGeofence queryPointsOfInterestWithinDistance:DEFAULT_QUERY_RADIUS];
    }
    return self;
}

-(void)setupCallbacks:(NSArray *)arguments withDict:(NSDictionary *)options{
    entryTriggerCallback = [[options valueForKey:@"onEntry"] retain];
    exitTriggerCallback = [[options valueForKey:@"onExit"] retain];
    receivedCredentialsCallback = [[options valueForKey:@"onRecievedCredentials"] retain];
    serviceFailureCallback = [[options valueForKey:@"onServiceFailure"] retain];
    engineFailureCallback = [[options valueForKey:@"onEngineFailure"] retain];
    NSLog(@"Key: %@, Secret: %@",[[NSUserDefaults standardUserDefaults] valueForKey:APP_PARAM_OAUTH_CONSUMER_KEY],[[NSUserDefaults standardUserDefaults] valueForKey:APP_PARAM_OAUTH_CONSUMER_SECRET]);
    if([[NSUserDefaults standardUserDefaults] valueForKey:APP_PARAM_OAUTH_CONSUMER_KEY] != nil
       && [[NSUserDefaults standardUserDefaults] valueForKey:APP_PARAM_OAUTH_CONSUMER_SECRET] != nil){
        [self writeJavascript:[NSString stringWithFormat:@"%@()",receivedCredentialsCallback]]; 
    }
}

-(void)createAndEnterCircularGeofence:(NSArray *)arguments withDict:(NSDictionary *)options{
    double lat = [[arguments objectAtIndex:0] doubleValue];
    double lng = [[arguments objectAtIndex:1] doubleValue];    
    int radius = [[arguments objectAtIndex:2] intValue];
    LLCircularGeofence * circularGeofence = [LLCircularGeofence circularGeofenceWithLongitude:lat withLatitude:lng andRadius:radius];
    if(circularGeofence != nil){
        [self writeJavascript:[NSString stringWithFormat:@"%@(%@)",[options valueForKey:@"onSuccess"],@"Success"]];
    }else{
        [self writeJavascript:[NSString stringWithFormat:@"%@(%@)",[options valueForKey:@"onError"],@"Failure"]];
    }
}
-(void)setFakeLocation:(NSArray *)arguments withDict:(NSDictionary *)options{
    double latitude = [[arguments objectAtIndex:0] doubleValue];
    double longitude = [[arguments objectAtIndex:1] doubleValue]; 
    CLLocation *fakeLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [LLFakeLocation set:fakeLocation];
    
}
-(void)clearFakeLocation:(NSArray *)arguments withDict:(NSDictionary *)options{
    [LLFakeLocation clear];
}
-(void)dealloc{
    [pointsOfInterest release];
    [super dealloc];
}
-(void)getAllGeofences:(NSArray *)arguments withDict:(NSDictionary *)options{
    
    NSArray *geofences = [self circularGeofencesToArray:[LLGeofence allGeofences]];
    [self writeJavascript:[NSString stringWithFormat:@"%@(%@)",[options valueForKey:@"onResults"],[geofences JSONRepresentation]]];
}
-(void)getSubscribedLayers:(NSArray *)arguments withDict:(NSDictionary *)options{
    NSArray *_subscriptions = [self layerSubscriptionsToArray:[LLGeofence  subscriptions]];
    NSLog(@"%@",[_subscriptions JSONRepresentation]);
    [self writeJavascript:[NSString stringWithFormat:@"%@(%@)",[options valueForKey:@"onResults"],[_subscriptions JSONRepresentation]]];
    
}
-(void)queryLayers:(NSArray *)arguments withDict:(NSDictionary *)options{
    [LLGeofence queryLayerNames];
    queryLayernameSuccessCallback = [[options valueForKey:@"onSuccess"] retain];
}

-(void)querySubscriptions:(NSArray *)arguments withDict:(NSDictionary *)options{
    [LLGeofence querySubscriptions];
    querySubscriptionSuccessCallback = [[options valueForKey:@"onSuccess"] retain];
}
-(void)refreshPOIs:(NSArray *)arguments withDict:(NSDictionary *)options{
    @try {
        //if has coordinates
        queryPOIsSuccessCallback = [[options valueForKey:@"onSuccess"] retain];
        int radius = [[arguments objectAtIndex:2] intValue];
        if((NSString *)[arguments objectAtIndex:0] != @"" && (NSString *)[arguments objectAtIndex:1] != @""){
            double lat = [[arguments objectAtIndex:0] doubleValue];
            double lng = [[arguments objectAtIndex:1] doubleValue];
            CLLocationCoordinate2D  coordinates = CLLocationCoordinate2DMake((CLLocationDegrees)lat , (CLLocationDegrees)lng);
            [LLGeofence queryPointsOfInterestWithinDistance:radius
                                               ofCoordinate:coordinates];
        }else{
            [LLGeofence queryPointsOfInterestWithinDistance:radius];
        }
    }
    @catch (NSException *exception) {
        NSLog([exception description]);
    }
    @finally {
        
    }
    
    
}

-(void)subscribeToLayer:(NSArray *)arguments withDict:(NSDictionary *)options{
    NSString * layer = (NSString *)[arguments objectAtIndex:0];
    NSArray * filteredSubscriptions = [[LLGeofence subscriptions] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" layerName LIKE[c] %@",layer]];
    if([filteredSubscriptions count] == 0){
        int radius = [[arguments objectAtIndex:1] intValue];
        [LLGeofence subscribeToLayer:layer withAlertRadius:radius];
        
    }
    addLayerSuccessCallback = [[options valueForKey:@"onSuccess"] retain];
}
-(void)unsubscribeFromLayer:(NSArray *)arguments withDict:(NSDictionary *)options{
    NSString * layer = (NSString *)[arguments objectAtIndex:0];
    NSArray * filteredSubscriptions = [[LLGeofence subscriptions] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" layerName LIKE[c] %@",layer]];
    if([filteredSubscriptions count] > 0){
        for(LLGeofenceLayerSubscription * subscription in filteredSubscriptions){
            [LLGeofence unsubscribeFromLayer:subscription];
            removeLayerSuccessCallback = [[options valueForKey:@"onSuccess"] retain];
        }
        
    }
    
}
-(void)unsubscribeFromAllLayers:(NSArray *)arguments withDict:(NSDictionary *)options{
    NSArray * _subscriptions = [LLGeofence subscriptions];
    if([_subscriptions count] > 0){
        for(LLGeofenceLayerSubscription * subscription in _subscriptions){
            [LLGeofence unsubscribeFromLayer:subscription];
            removeLayerSuccessCallback = [[options valueForKey:@"onSuccess"] retain];
        }
        
    }
}
-(void)geofence:(LLGeofence*)geofence didTriggerAtLocation:(CLLocation*)location{
    //JS Entry to notify of trigger    
}

- (void) geofence: (LLGeofence*)geofence didTriggerAtLocation: (CLLocation*)location
    withEventType: (LLGeofenceEventType)eventType{
    
}
-(void)getCurrentLocation:(NSArray *)arguments withDict:(NSDictionary *)options{
    CLLocation * loc = [LLGeofence currentLocation];
    NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithDouble:loc.coordinate.latitude],[NSNumber numberWithDouble:loc.coordinate.longitude],nil] forKeys:[NSArray arrayWithObjects:@"Latitude",@"Longitude",nil]];
    [self writeJavascript:[NSString stringWithFormat:@"%@(%@)",[options valueForKey:@"onSuccess"],[dict JSONRepresentation]]];
}
- (void) authorizationStateNotification:(BOOL)authorized{
    NSString * message = nil;
    if(authorized) {
        message = @"We are now authorized";
    } else {
        message = @"We are no longer authorized";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void)engineDidFailWithError:(NSError*)error{
    NSLog(@"Error: %@",[error description]);
    [self writeJavascript:[NSString stringWithFormat:@"%@(%@)",engineFailureCallback,[error description]]];
}
-(void)applicationWillBecomeSuspendedInBackground{
    
    NSLog(@"Application running in background");
}

- (void) didEnterAlertRadiusForPointOfInterest: (LLGeofencePOI*)poi
                                    atLocation: (CLLocation*)location{
    NSMutableDictionary * poiDict = [NSMutableDictionary dictionaryWithDictionary:[self poiToDictionary:poi]];

                UILocalNotification *notif = [[UILocalNotification alloc] init];
                notif.alertBody = [NSString stringWithFormat:
                                   @"Entered a geofence radius."
                notif.alertAction = @"OK";
                notif.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObject:poiDict] forKeys:[NSArray arrayWithObject:@"POI"]];
                [[UIApplication sharedApplication] scheduleLocalNotification: notif];
                [notif release];
                [self writeJavascript:[NSString stringWithFormat:@"%@(%@)",entryTriggerCallback,[poiDict JSONRepresentation]]];

        
    }
    
    
    
    
    
    
}

- (void) didExitAlertRadiusForPointOfInterest: (LLGeofencePOI*)poi
                                   atLocation: (CLLocation*)location{
    NSArray * comps = [poi.pointID componentsSeparatedByString:@"::"];
    NSMutableDictionary * poiDict = [NSMutableDictionary dictionaryWithDictionary:[self poiToDictionary:poi]];
    [self writeJavascript:[NSString stringWithFormat:@"%@(%@)",exitTriggerCallback,[poiDict JSONRepresentation]]];
    NSString * message =  [NSString stringWithFormat:
                           @"No longer near %@ at (%.4f, %.4f)",
                           poi.name,
                           location.coordinate.longitude,
                           location.coordinate.latitude];

    NSLog(@"%@",message);
    
}

- (void) didReceiveNearbyCredentials{
    NSLog(@"Received nearby credentials");
    [[NSUserDefaults standardUserDefaults] setValue:[LLGeofence performSelector:@selector(tokenValue)] forKey:APP_PARAM_OAUTH_CONSUMER_KEY];
    [[NSUserDefaults standardUserDefaults] setValue:[LLGeofence performSelector:@selector(tokenSecret)] forKey:APP_PARAM_OAUTH_CONSUMER_SECRET];
    [self writeJavascript:[NSString stringWithFormat:@"%@()",receivedCredentialsCallback]];
}

- (void) didAddNearbyLayerSubscription: (LLGeofenceLayerSubscription*)subscription{
    NSString * message = [NSString stringWithFormat:
                          @"Successfully subscribed to %@ [%@]",
                          subscription.layerName, subscription.subscriptionID];
    NSDictionary * _subscription = [self layerSubscriptionToDictionary:subscription];
    [self writeJavascript:[NSString stringWithFormat:@"%@(%@)",addLayerSuccessCallback,[_subscription JSONRepresentation]]];
    
    NSLog(@"%@",message);
}

- (void) didRemoveNearbyLayerSubscription: (LLGeofenceLayerSubscription*)subscription{
    NSString * message = [NSString stringWithFormat:
                          @"Successfully unsubscribed from %@ [%@]",
                          subscription.layerName, subscription.subscriptionID];
    NSDictionary * _subscription = [self layerSubscriptionToDictionary:subscription];
    [self writeJavascript:[NSString stringWithFormat:@"%@(%@)",removeLayerSuccessCallback,[_subscription JSONRepresentation]]];
    
    NSLog(@"%@",message);
}
- (void) didReceiveNearbyLayerNames: (NSArray*)list{
    layers = [list retain];
    NSString * message = [NSString stringWithFormat:
                          @"Received %d layer names", [list count]];
    [self writeJavascript:[NSString stringWithFormat:@"%@(%@)",queryLayernameSuccessCallback,[layers JSONRepresentation]]];
    NSLog(@"%@",message);
}

- (void) didReceiveNearbySubscriptions: (NSArray*)list{
    layers = [list retain];
    NSLog(@"Recieved %d subscription names",[list count]);
    [self writeJavascript:[NSString stringWithFormat:@"%@(%@)",querySubscriptionSuccessCallback,[layers JSONRepresentation]]];
    
}

- (void) didReceiveNearbyPointsOfInterest: (NSArray*)list{
        [pointsOfInterest release];
       	pointsOfInterest = (NSMutableArray *)[self poisToArray:list];
        [self writeJavascript:[NSString stringWithFormat:@"%@(%@)",queryPOIsSuccessCallback,[pointsOfInterest JSONRepresentation]]];
                                                           
}

- (void) didReceiveNearbyServiceError:(NSError*)error forSubscription:(LLGeofenceLayerSubscription*)subscription{
    NSString *message = [NSString stringWithFormat: @"Error (%d) - %@",
                         [error code], [[error userInfo] objectForKey: @"message"]];
    [self writeJavascript:[NSString stringWithFormat:@"%@(%@)",serviceFailureCallback,message]];
    NSLog(@"%@",message);
}

-(NSDictionary *)layerSubscriptionToDictionary:(LLGeofenceLayerSubscription *)layerSubscription{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjects:
                           [NSArray arrayWithObjects:layerSubscription.subscriptionID,
                            layerSubscription.layerName,
                            [NSString stringWithFormat:@"%d",layerSubscription.alertRadius],
                            nil] 
                                                        forKeys:
                           [NSArray arrayWithObjects:@"layerSubscriptionID",
                            @"layerName",
                            @"alertRadius",
                            nil]];
    return dict;
}
-(NSArray *)layerSubscriptionsToArray:(NSArray *)layerSubscriptions{
    NSMutableArray * convertedLayerSubscriptions = [[NSMutableArray alloc] init];
    for(LLGeofenceLayerSubscription * layerSubscription  in layerSubscriptions){
        [convertedLayerSubscriptions addObject:[self layerSubscriptionToDictionary:layerSubscription]];
    }
    return convertedLayerSubscriptions;
}
-(NSDictionary *)circularGeofenceToDictionary:(LLCircularGeofence *)circularGeofence{
    NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInteger:circularGeofence.tag],[NSNumber numberWithInteger:circularGeofence.radius ], [NSNumber numberWithDouble:circularGeofence.center.coordinate.latitude ],[NSNumber numberWithDouble:circularGeofence.center.coordinate.longitude ], nil] 
                                                      forKeys:[NSArray arrayWithObjects:@"Tag",@"Radius",@"Latitude",@"Longitude", nil]];
    return  dict;
}
-(NSArray *)circularGeofencesToArray:(NSArray *)circularGeofences{
    NSMutableArray * convertedCircularGeofences = [[NSMutableArray alloc] init];
    for(LLCircularGeofence * circularGeofence  in circularGeofences){
        [convertedCircularGeofences addObject:[self circularGeofenceToDictionary:circularGeofence]];
    }
    return convertedCircularGeofences;    
}
-(NSDictionary *)poiToDictionary:(LLGeofencePOI *)poi{
    NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:poi.pointID,poi.name, [NSNumber numberWithDouble:poi.coordinate.latitude ],[NSNumber numberWithDouble:poi.coordinate.longitude ], nil] 
                                                      forKeys:[NSArray arrayWithObjects:@"PointID",@"Name",@"Latitude",@"Longitude", nil]];
    return dict;
}
-(NSArray *)poisToArray:(NSArray *)pois{
    NSMutableArray * convertedPOIs = [[NSMutableArray alloc] init];
    for(LLGeofencePOI * poi  in pois){
        NSArray * comps = [poi.pointID componentsSeparatedByString:@"::"];
        NSMutableDictionary * poiDict = [NSMutableDictionary dictionaryWithDictionary:[self poiToDictionary:poi]];
        if([comps count] == 3)
            [poiDict setValue:[comps objectAtIndex:1] forKey:@"PointID"];

        [convertedPOIs addObject:poiDict];
    }
    return convertedPOIs;    
}


@end
