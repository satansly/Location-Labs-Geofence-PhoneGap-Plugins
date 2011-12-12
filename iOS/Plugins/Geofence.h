//
//  Geofence.h
//  USVIHA
//
//  Created by OmarHussain on 6/4/11.
//  Copyright 2011 Omar Hussain. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PhoneGapCommand.h"
#import "JSON.h"
#import <LLGeofence/LLGeofence.h>
#import <LLGeofence/LLFakeLocation.h>

@interface Geofence : PhoneGapCommand<LLGeofenceDelegate> {
    NSMutableArray *pointsOfInterest;
    NSMutableArray *layers;
    NSMutableArray *subscriptions;
    NSString * entryTriggerCallback;
    NSString * exitTriggerCallback;
    NSString * serviceFailureCallback;
    NSString * engineFailureCallback;
    NSString * receivedCredentialsCallback;
    NSString * queryLayernameSuccessCallback;
    NSString * querySubscriptionSuccessCallback;
    NSString *  queryPOIsSuccessCallback;
    NSString *  addLayerSuccessCallback;
    NSString *  removeLayerSuccessCallback;
    BOOL isForeground;
}


@property (nonatomic, retain) NSString * entryTriggerCallback;
@property (nonatomic, retain) NSString * exitTriggerCallback;
@property (nonatomic, retain) NSString * serviceFailureCallback;
@property (nonatomic, retain) NSString * engineFailureCallback;
@property (nonatomic, retain) NSString * receivedCredentialsCallback;

-(void)setupCallbacks:(NSArray *)arguments withDict:(NSDictionary *)options;
-(void)createAndEnterCircularGeofence:(NSArray *)arguments withDict:(NSDictionary *)options;
-(void)setFakeLocation:(NSArray *)arguments withDict:(NSDictionary *)options;
-(void)clearFakeLocation:(NSArray *)arguments withDict:(NSDictionary *)options;
-(void)queryLayers:(NSArray *)arguments withDict:(NSDictionary *)options;
-(void)refreshPOIs:(NSArray *)arguments withDict:(NSDictionary *)options;
-(void)getAllGeofences:(NSArray *)arguments withDict:(NSDictionary *)options;
-(void)getSubscribedLayers:(NSArray *)arguments withDict:(NSDictionary *)options;
-(void)querySubscriptions:(NSArray *)arguments withDict:(NSDictionary *)options;
-(void)subscribeToLayer:(NSArray *)arguments withDict:(NSDictionary *)options;
-(void)unsubscribeFromLayer:(NSArray *)arguments withDict:(NSDictionary *)options;
-(void)unsubscribeFromAllLayers:(NSArray *)arguments withDict:(NSDictionary *)options;
-(void)getCurrentLocation:(NSArray *)arguments withDict:(NSDictionary *)options;
-(NSDictionary *)layerSubscriptionToDictionary:(LLGeofenceLayerSubscription *)layerSubscription;
-(NSArray *)layerSubscriptionsToArray:(NSArray *)layerSubscriptions;
-(NSDictionary *)circularGeofenceToDictionary:(LLCircularGeofence *)circularGeofence;
-(NSArray *)circularGeofencesToArray:(NSArray *)circularGeofences;
-(NSDictionary *)poiToDictionary:(LLGeofencePOI *)poi;
-(NSArray *)poisToArray:(NSArray *)pois;
@end
