//
//  SharedCLController.m
//
//  Created by Samuel Grau on 10/07/10.
//  Copyright 2010 Samuel GRAU. All rights reserved.
//

#import "SharedCLController.h"

#import "GTMObjectSingleton.h"
#import "SGSafeRelease.h"

#define SECS_OLD_MAX	2

@implementation SharedCLController

@synthesize delegate, locationManager;
@synthesize bestEffortAtLocation;
@synthesize stoppedLocalization;

#pragma mark -
#pragma mark Singleton definition

GTMOBJECT_SINGLETON_BOILERPLATE( SharedCLController, sharedInstance )

- (id)init {
	self = [super init];
	if (self != nil) {
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		// Tells the location manager to send updates to this object
        self.locationManager.delegate = self; 
        
		[self setStoppedLocalization:[NSNumber numberWithBool:YES]];
	}
	return self;
}

// Called when the location is updated
- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {
    
	self.bestEffortAtLocation = newLocation;
	
	NSDate *eventDate = newLocation.timestamp; 
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    // Is the event recent and accurate enough ?
    if (fabs(howRecent) < SECS_OLD_MAX) {
        // WORK WITH IT !
    }
	
	NSMutableString *update = [[[NSMutableString alloc] init] autorelease];
	
	// Timestamp
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	[update appendFormat:@"%@\n\n", [dateFormatter stringFromDate:newLocation.timestamp]];
	
	// Horizontal coordinates
	if (signbit(newLocation.horizontalAccuracy)) {
		// Negative accuracy means an invalid or unavailable measurement
		[update appendString:sgLocStr(@"LatLongUnavailable")];
	} else {
		// CoreLocation returns positive for North & East, negative for South & West
		[update appendFormat:sgLocStr(@"LatLongFormat"), // This format takes 4 args: 2 pairs of the form coordinate + compass direction
		 fabs(newLocation.coordinate.latitude), signbit(newLocation.coordinate.latitude) ? sgLocStr(@"South") : sgLocStr(@"North"),
		 fabs(newLocation.coordinate.longitude), signbit(newLocation.coordinate.longitude) ? sgLocStr(@"West") : sgLocStr(@"East")];
		[update appendString:@"\n"];
		[update appendFormat:sgLocStr(@"MeterAccuracyFormat"), newLocation.horizontalAccuracy];
	}
	[update appendString:@"\n\n"];
	
	// Altitude
	if (signbit(newLocation.verticalAccuracy)) {
		// Negative accuracy means an invalid or unavailable measurement
		[update appendString:sgLocStr(@"AltUnavailable")];
	} else {
		// Positive and negative in altitude denote above & below sea level, respectively
		[update appendFormat:sgLocStr(@"AltitudeFormat"), fabs(newLocation.altitude),	(signbit(newLocation.altitude)) ? sgLocStr(@"BelowSeaLevel") : sgLocStr(@"AboveSeaLevel")];
		[update appendString:@"\n"];
		[update appendFormat:sgLocStr(@"MeterAccuracyFormat"), newLocation.verticalAccuracy];
	}
	[update appendString:@"\n\n"];

#pragma GCC diagnostic ignored "-Wformat"

	// Calculate distance moved and time elapsed, but only if we have an "old" location
	//
	// NOTE: Timestamps are based on when queries start, not when they return. CoreLocation will query your
	// location based on several methods. Sometimes, queries can come back in a different order from which
	// they were placed, which means the timestamp on the "old" location can sometimes be newer than on the
	// "new" location. For the example, we will clamp the timeElapsed to zero to avoid showing negative times
	// in the UI.
	//
	if (oldLocation != nil) {
		CLLocationDistance distanceMoved;
		if ([newLocation respondsToSelector:@selector(distanceFromLocation:)] ) {
			distanceMoved = [newLocation distanceFromLocation:oldLocation];
		} else {
			distanceMoved = [newLocation distanceFromLocation:oldLocation];
		}
		
		NSTimeInterval timeElapsed = [newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp];
		
		[update appendFormat:sgLocStr(@"LocationChangedFormat"), distanceMoved];
		if (signbit(timeElapsed)) {
			[update appendString:sgLocStr(@"FromPreviousMeasurement")];
		} else {
			[update appendFormat:sgLocStr(@"TimeElapsedFormat"), timeElapsed];
		}
		[update appendString:@"\n\n"];
	}

#pragma GCC diagnostic warning "-Wformat"
	
	// Send the update to our delegate
	[self.delegate newLocationUpdate:update];
	[self.delegate updateLocation:newLocation];
	
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    NSLog(@"HA : %f %@", newLocation.horizontalAccuracy, [NSNumber numberWithDouble:locationAge]);
	
    // test the measurement to see if it is more accurate than the previous measurement
    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy >= newLocation.horizontalAccuracy) 
	{
        // store the location as the "best effort"
        self.bestEffortAtLocation = newLocation;
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue 
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of 
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        if ((newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) || (locationAge < 2.0)){
            // we have a measurement that meets our requirements, so we can stop updating the location
            // 
            // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
            //
            [self stopUpdatingLocation];
			
            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation) object:nil];
        }
    }
}

- (void)startUpdatingLocation {
	[self setStoppedLocalization:[NSNumber numberWithBool:NO]];
	[locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
	[self setStoppedLocalization:[NSNumber numberWithBool:YES]];
	[locationManager stopUpdatingLocation];
	[delegate updateLocationWillStop:bestEffortAtLocation];
}

- (void)updateLocationWillStop:(CLLocation *)location {
	
}

// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSMutableString *errorString = [[[NSMutableString alloc] init] autorelease];
	
	if ([error domain] == kCLErrorDomain) {
		
		// We handle CoreLocation-related errors here
		
		switch ([error code]) {
				// This error code is usually returned whenever user taps "Don't Allow" in response to
				// being told your app wants to access the current location. Once this happens, you cannot
				// attempt to get the location again until the app has quit and relaunched.
				//
				// "Don't Allow" on two successive app launches is the same as saying "never allow". The user
				// can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
				//
			case kCLErrorDenied:
				[errorString appendFormat:@"%@\n", NSLocalizedString(@"LocationDenied", nil)];
				break;
				
				// This error code is usually returned whenever the device has no data or WiFi connectivity,
				// or when the location cannot be determined for some other reason.
				//
				// CoreLocation will keep trying, so you can keep waiting, or prompt the user.
				//
			case kCLErrorLocationUnknown:
				[errorString appendFormat:@"%@\n", NSLocalizedString(@"LocationUnknown", nil)];
				break;
				
				// We shouldn't ever get an unknown error code, but just in case...
				//
			default:
				[errorString appendFormat:@"%@ %d\n", NSLocalizedString(@"GenericLocationError", nil), [error code]];
				break;
		}
	} else {
		// We handle all non-CoreLocation errors here
		// (we depend on localizedDescription for localization)
		[errorString appendFormat:@"Error domain: \"%@\"  Error code: %d\n", [error domain], [error code]];
		[errorString appendFormat:@"Description: \"%@\"\n", [error localizedDescription]];
	}
	
	// Send the update to our delegate
	[self.delegate newLocationUpdate:errorString];
}

- (void)dealloc {
	[bestEffortAtLocation release];
    [super dealloc];
}

@end
