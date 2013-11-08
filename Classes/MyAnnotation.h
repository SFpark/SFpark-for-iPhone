//
//  MyAnnotation.h
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

@import Foundation;
@import	MapKit;

@interface MyAnnotation : NSObject<MKAnnotation>
{
	
	CLLocationCoordinate2D	coordinate;
	NSString*				title;
	NSString*				subtitle;
	NSDictionary*           allGarageData;
	NSString*				type;
	NSString*				uniqueID;
	BOOL					onStreet;
	NSString                *row,*beg,*end,*from,*to,*rate, *desc, *rq, *rr;
	NSDate*					timeStamp;
	float					pricePerHour;
	NSString*				rateQualifier;


}

@property BOOL                                          onStreet;

@property float                                         pricePerHour;

@property (nonatomic, assign)	CLLocationCoordinate2D	coordinate;

@property (nonatomic, strong)	NSDate*                 timeStamp;
@property (nonatomic, strong)	NSDictionary*           allGarageData;

@property (nonatomic, copy)		NSString*               type;
@property (nonatomic, copy)		NSString*				title;
@property (nonatomic, copy)		NSString*				subtitle;
@property (nonatomic, copy)		NSString*               uniqueID;
@property (nonatomic, copy)		NSString*               rateQualifier;

- (UIColor *)   bucketFinder:                       (float) price;
- (int)         iconFinder:                         (BOOL)showPrice;
- (void)        rateStructureHandle:                (id) rateStructure;
- (NSDate *)    createDateFromString:               (NSString *) dateString;
- (UIColor *)   blockfaceColorizerWithShowPrice:    (BOOL)showPrice;
- (NSString *)  availabilityDescriptionShowingPrice:(BOOL) shouldShowPrice;
- (int)         nameFinderWithOnStreet:             (BOOL) isOnStreet           andPrice:(float) phr;
- (BOOL)        inThisBucketBegin:                  (NSString *) bucketBegin    End:(NSString *) bucketEnd;
- (id)          initWithData:                       (NSDictionary *) element    andLocation:(CLLocationCoordinate2D ) location;
@end