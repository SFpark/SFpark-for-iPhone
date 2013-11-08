//
//  GarageDetailsViewController.m
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
#import "MyAnnotation.h"
#import "DetailCell.h"

@protocol GarageDetailsViewControllerDelegate;


@interface GarageDetailsViewController : UIViewController <UITableViewDelegate, UIWebViewDelegate>
{
	id				<GarageDetailsViewControllerDelegate> __weak delegate;
	IBOutlet		UIWebView *myWebView;
	MyAnnotation	*thisGarage;
	NSDictionary	*infoDict;
	
	IBOutlet		UIScrollView	*infoScrollView;
	
	IBOutlet		UILabel			*nameLabel;
	IBOutlet		UILabel			*garageUse;

	IBOutlet		UILabel			*addressLabel;
	IBOutlet		UITextView		*phoneTextView;
	
	IBOutlet		UIView			*infoHeaderView;
	IBOutlet		UITableView		*infoTableView;
	
	//street table header
	IBOutlet		UIView			*streetHeaderView;
	IBOutlet		UILabel			*streetLabel;
	IBOutlet		UILabel			*streetUse;

	__weak IBOutlet UIButton *backButton;
	
	int hoursRows;
	int ratesRows;
	int infoRows;
	
	int i,j;
	int infoRowsHeights[20];
	int hoursNow;
	int ratesNow;

	
	NSMutableArray	*hoursRowsText;
	NSMutableArray	*ratesRowsText;
	NSMutableArray	*infoRowsText;
	NSMutableArray	*rateqRowsText;


	NSMutableArray	*pricesText;	//for right hand side beg/end
	NSMutableArray	*pricesText2;	//for right hand side desc
	NSMutableArray	*raterRowsText;	//rate restrictions

	
	NSString *row,*beg,*end,*from,*to,*rate, *desc, *rq, *rr;
	
	BOOL	onStreetParking;
	
}


- (IBAction)doneWithDetails:(id)sender;
- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)recognizer;
//@property(nonatomic) UISwipeGestureRecognizerDirection direction;

- (void)viewAppeared; 

- (NSString*)fixDay:(NSString*)dstr;

- (void)parseHours;
- (void)parseRates;
- (void)parseInfo;

@property (nonatomic, weak) id <GarageDetailsViewControllerDelegate> delegate;
@property (nonatomic, strong) UIWebView *myWebView;
@property (nonatomic, strong) MyAnnotation* thisGarage;


@end

@protocol GarageDetailsViewControllerDelegate
- (void)garageDetailsViewControllerDidFinish:(GarageDetailsViewController *)controller;
@end

