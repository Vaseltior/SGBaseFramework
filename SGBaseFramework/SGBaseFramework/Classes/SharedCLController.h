//
//  SharedCLController.h
//
//  Created by Samuel Grau on 10/07/10.
//  Copyright 2010 Samuel GRAU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

// This protocol is used to send the text for location updates back to another view controller
@protocol SharedCLControllerDelegate <NSObject>

@required

- (void)newLocationUpdate:(NSString *)text;
- (void)newError:(NSString *)text;
- (void)updateLocation:(CLLocation *)location;
- (void)updateLocationWillStop:(CLLocation *)location;

@end


@interface SharedCLController : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
 	id<SharedCLControllerDelegate> delegate;
	CLLocation *bestEffortAtLocation;
	NSNumber *stoppedLocalization;
}


@property (nonatomic, retain) CLLocationManager	*locationManager;
@property (nonatomic, assign) id <SharedCLControllerDelegate> delegate;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;
@property (nonatomic, retain) NSNumber *stoppedLocalization;


- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error;

#pragma mark -
#pragma mark Singleton object methods

+ (SharedCLController *)sharedInstance;

- (void)updateLocationWillStop:(CLLocation *)location;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
