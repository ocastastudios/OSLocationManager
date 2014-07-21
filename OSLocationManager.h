//
//  OSLocationManager.h
//  Ocasta Studios
//
//  Created by Chris Birch on 26/02/2013.
//  Copyright (c) 2013 Ocasta Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


#define OSNOTIFICATION_LOCATION_USER_DISABLED @"OS Location User Disabled"
#define OSNOTIFICATION_LOCATION_UPDATED @"OS Location Updated"
#define OSNOTIFICATION_LOCATION_AUTH_STATE_CHANGED @"OS Auth State Updated"
#define OSNOTIFICATION_LOCATION_UPDATES_PAUSED @"OS Location Updates Paused"
#define OSNOTIFICATION_LOCATION_UPDATES_RESUMED @"OS Location Updates Resumed"

@interface OSLocationManager : NSObject<CLLocationManagerDelegate>


@property(nonatomic,assign) BOOL logDebugMessages;
/**
 * Describes the current authorisation status.
 */
@property(nonatomic,readonly) CLAuthorizationStatus authStatus;

@property(nonatomic,strong) CLLocationManager* locationManager;

/**
 * The maximum amount of time that coordinates stay valid. This is the time from achieving a
 * lock (meeting desired accuracy criteria) that the updates will be disabled for.
 * Passing a value of 0 means that the manager will never turn off location updates.
 */
@property(nonatomic,assign) NSTimeInterval validityDuration;

/**
 * The coordinates of the last known position
 */
@property(nonatomic,readonly) CLLocation* lastKnownLocation;

/**
 * a kCLLocationAccuracy value
 */
@property(nonatomic,assign) CLLocationAccuracy desiredAccuracy;


-(void)stopUpdatingLocation;
-(void)startUpdatingLocation;

/**
 * Pointer to the default manager.
 */
+(OSLocationManager*)defaultManager;
@end
