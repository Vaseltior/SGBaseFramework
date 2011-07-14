//
//  SharedCLController.h
//
//  Created by Samuel Grau on 10/07/10.
//  Copyright 2011 Samuel Grau. 
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
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
