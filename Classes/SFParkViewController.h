//
//  SFParkViewController.h
//  SFPark
//
// iPhone development by Brian VanderZanden and Mark S. Morris ( http://mmorrisdev.com )
// 

/*
 * Copyright 2011 SFMTA
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

@import UIKit;
@import MapKit;
@import AudioToolbox;

#include <sys/types.h>
#include <sys/sysctl.h>
#include <mach/mach_time.h>

//#import "TestFlight.h"
#import "Flurry.h"
#import "MBProgressHUD.h"
#import "SpeedingViewController.h"
#import "FlipsideViewController.h"
#import "IntroViewController.h"
#import "GarageDetailsViewController.h"

// For v1.5 debugging to toggle different data sources
#define VERSIONA 0
#define VERSIONB 1
#define ORIGINAL 2

#define MPSTOMPH  3600 / 1610.3 * 1000 / 1000; // Convert meters per second to miles per hour. 

@interface SFParkViewController : UIViewController <MBProgressHUDDelegate, MKMapViewDelegate, FlipsideViewControllerDelegate,CLLocationManagerDelegate, SpeedingViewControllerDelegate, IntroViewControllerDelegate, GarageDetailsViewControllerDelegate>
{

	IBOutlet UILabel *label;
	IBOutlet UILabel *ageOfData;
	IBOutlet UIImageView *legend;
	IBOutlet UILabel *legendlabel;
	IBOutlet UILabel *buildNumber;
	IBOutlet UIButton *priceButton;
	IBOutlet UIButton *availabilityButton;
	__weak IBOutlet UIButton *infoButton;
//	__weak IBOutlet UISegmentedControl *dataSourceToggle;
//	__weak IBOutlet UILabel *buildName;
	
	MBProgressHUD *HUD;
	NSMutableData *responseData;
	MKMapView *_mapView;
	CLLocationManager *locationManager;
    
	UIColor * lineColor;
	NSMutableArray* interestAreas;
	NSMutableArray* blockfaces;
	NSDictionary* returnData;
	NSDate* startTime;
	NSTimeInterval howLong;
	NSString * serviceURL;
	
	BOOL stillLoading;
	BOOL stillDisplayingIntroView;
	BOOL showPrice;
	BOOL seenDisclaimer;
	BOOL displayingDetails;
	BOOL lowMemoryMode;
	BOOL veryLowMemoryMode;
	
	UIImage *iconArray[14];
	uint64_t startDataTime;
}
@property (nonatomic, retain) IBOutlet MKMapView* mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) UIButton * availabilityButton;
@property (nonatomic, retain) UIButton *priceButton;
@property (nonatomic, retain) UIColor * lineColor;
@property (nonatomic, retain) NSMutableArray* interestAreas;
@property (nonatomic, retain) NSMutableArray* blockfaces;
@property (nonatomic, retain) NSDictionary* returnData;
@property (nonatomic, retain) NSDate* startTime;

@property (nonatomic, copy)     NSString* serviceURL;


- (IBAction) refresh: (id)sender;
- (IBAction) showInfo:(id)sender;
- (IBAction) showAvailability: (id)sender;
- (IBAction) showPricing: (id)sender;


- (BOOL) inClose;
- (void) HUDrefreshing;
- (void) loadData;
- (void) displayData;
- (void) speedWarning;
- (NSString *) platform;
- (void) showDisclaimer;
- (void) hideAllActivityIndicators;
- (BOOL) isOldHardware:(NSString *) platformString;
- (BOOL) isMovingTooFastNewLocation:(CLLocation *) newLocation OldLocation: (CLLocation *) oldLocation;
- (NSUInteger)zoomLevelForMapRect:(MKMapRect)mRect withMapViewSizeInPixels:(CGSize)viewSizeInPixels;

@end