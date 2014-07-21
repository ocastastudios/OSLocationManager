//
//  OSLocationManager.m
//  Ocasta Studios
//
//  Created by Chris Birch on 26/02/2013.
//  Copyright (c) 2013 Ocasta Studios. All rights reserved.
//

#import "OSLocationManager.h"

#define POST_NOTIFICATION(NAME,OBJ,USERINFO) [[NSNotificationCenter defaultCenter] postNotificationName:NAME object:OBJ userInfo:USERINFO]

/**
 * Defines the maximum number of seconds a gps lock is valid for.
 * This is just the default value, a custom value can be set using the validityPeriod property
 */
#define DEFAULT_VALIDITY_PERIOD 60.0

@interface OSLocationManager ()
{
    /**
     * Used to turn on location manager after a set amount of time after it being turned off
     */
    NSTimer* timer;
}

/**
 * Occurs when the timer has elapsed. Re-enables the location manager updates.
 */
-(void)timerElasped;

@end
@implementation OSLocationManager

static OSLocationManager* sharedInstance;

+(OSLocationManager*)defaultManager
{
    @synchronized(sharedInstance)
    {
        if (!sharedInstance)
            sharedInstance = [[OSLocationManager alloc] init];
    }

    
    return sharedInstance;
}



#pragma mark -
#pragma mark Properties

-(CLAuthorizationStatus)authStatus
{
    return [CLLocationManager authorizationStatus];
}

-(CLLocationAccuracy)desiredAccuracy
{
    return _locationManager.desiredAccuracy;
}

-(void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy
{
    _locationManager.desiredAccuracy = desiredAccuracy;
}


#pragma mark -
#pragma mark Constructors

-(id)init
{
    if (self = [super init])
    {
        _validityDuration = DEFAULT_VALIDITY_PERIOD;
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [_locationManager startUpdatingLocation];
        _logDebugMessages = YES;
    }
    
    return self;
}


#pragma mark -
#pragma mark Timer stuff

-(void)timerElasped
{
    [_locationManager startUpdatingLocation];
    timer = nil;
}


-(void)stopUpdatingLocation
{
    //Stop location manager
    [_locationManager stopUpdatingLocation];
}

-(void)startUpdatingLocation
{
    [_locationManager startUpdatingLocation];
}


#pragma mark -
#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    POST_NOTIFICATION(OSNOTIFICATION_LOCATION_AUTH_STATE_CHANGED, nil, nil);
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    
}

-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = manager.location;
    
    if (_lastKnownLocation.horizontalAccuracy < 0)
    {
        //this is invalid
        //throw it away

        //alert developer if we logging is enabled
        [self debugLog:@"Received invalid location. Discarding."];

    }
    else
    {
        //only post if the location is valid
        
        _lastKnownLocation = location;
        POST_NOTIFICATION(OSNOTIFICATION_LOCATION_UPDATED, location, nil);
        
        //if user code has specified a validity duration then
        //we need to check whether we have reached the desired accuracy before
        //disabling updates
        if (_validityDuration > 0)
        {
            //handle the edge cases:
            CLLocationAccuracy desired = _locationManager.desiredAccuracy;
            if (desired == kCLLocationAccuracyBestForNavigation)
            {
                //we never want to stop updating location if this is the case
                return;
            }
            else if(desired == kCLLocationAccuracyBest)
            {
                desired = kCLLocationAccuracyNearestTenMeters;
            }
            
            //Now determine whether we have reached the accuracy required
            CLLocationAccuracy accuracy =_lastKnownLocation.horizontalAccuracy;
            
            if (accuracy <= desired)
            {            
                //Stop location manager
                [_locationManager stopUpdatingLocation];
                
                 //start timer so we can update
                [timer invalidate];
                timer = [NSTimer scheduledTimerWithTimeInterval:_validityDuration target:self selector:@selector(timerElasped) userInfo:nil repeats:NO];

                //alert developer if we logging is enabled
                [self debugLog:[[NSString alloc] initWithFormat:@"GPS Lock achieved. Accurate to %.2f meters. Turning off GPS for: %.2f second(s)",accuracy,_validityDuration]];
                
            }
        }
    }
}


-(void)debugLog:(NSString*)message
{
    if (_logDebugMessages)
    {
        NSLog(@"%@",message);
    }
}




@end
