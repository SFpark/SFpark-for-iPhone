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


#import "MyAnnotation.h"

#define garage_invalid              0
#define street_invalid              1
#define garage_availability_high    2
#define street_availability_high    3
#define street_availability_medium  4
#define garage_availability_medium	5	
#define garage_availability_low     6
#define street_availability_low     7
#define street_price_low            8
#define street_price_medium         9
#define street_price_high           10
#define garage_price_low            11
#define garage_price_medium         12
#define garage_price_high           13

@implementation MyAnnotation

@synthesize allGarageData;
@synthesize coordinate;
@synthesize subtitle;
@synthesize title;
@synthesize type;
@synthesize uniqueID;
@synthesize onStreet;
@synthesize timeStamp;
@synthesize pricePerHour;
@synthesize rateQualifier;


- (id)initWithData:(NSDictionary *) element andLocation:(CLLocationCoordinate2D ) location
{
  self = [super init];
	if (self){
		if (element[@"BFID"])
		{
			uniqueID = element[@"BFID"];
		} else if (element[@"OSPID"])
		{
			uniqueID = element[@"OSPID"];
		}
		title = element[@"NAME"];
		coordinate = location;
		allGarageData = element;
		if([element[@"TYPE"] isEqualToString:@"ON"])
		{
			onStreet = YES;
			type = @"blockface";
		} else
		{
			onStreet = NO;
			type = @"garage";
		}
		beg	 = nil;		// Indicates the begin time for this rate schedule (or hours schedule use same var for both)
		end	 = nil;		// Indicates the end time for this rate schedule (or hours schedule use same var for both)
		rate = nil;
		rq   = nil;
		pricePerHour = 0.00;
		rateQualifier = @"";
	}
	return self;
}

- (NSString *) availabilityDescriptionShowingPrice:(BOOL) shouldShowPrice
{
	NSString * descriptionOfAvailability;
	rateQualifier =@"";
	if(shouldShowPrice)
	{
		[self blockfaceColorizerWithShowPrice:YES]; // side-effect (using it to set the pricePerHour)
		[self iconFinder:YES]; // side-effect (using it to set the pricePerHour for Garages...)
		if (pricePerHour == 0.00)
		{
			descriptionOfAvailability = rateQualifier;
		} else
		{
			descriptionOfAvailability = [NSString stringWithFormat:@"$%5.2f/hr", pricePerHour];
		}

		if(!onStreet)
		{
			if (pricePerHour > 0.0)
			{
				descriptionOfAvailability = [NSString stringWithFormat:@"$%5.2f/hr", pricePerHour];
			} else
			{
				descriptionOfAvailability = @"";
			}


		}
	} else
	{
		int numberOfOperationalSpaces = [allGarageData[@"OPER"] intValue];
		if( allGarageData[@"OCC"] == nil && allGarageData[@"OPER"] == nil)
		{
			//This case should never be hit according to sending rule adjustments from MTA.
			return @"No availability data";
		}
		int numberOfOccupiedSpaces = [allGarageData[@"OCC"] intValue];
		if (numberOfOccupiedSpaces > numberOfOperationalSpaces)
		{
			//descriptionOfAvailability = @"occ is > than oper (debg code for 'no data')";
			descriptionOfAvailability = @"";
			// v1.4 change. (When there is a garage reporting more occupied spaces than available spaces, the
			// garage is in "valet" mode and shall be considered full. This change 'undefines' the previous
			// meaning, of 'no data'.)
			// 'On the map garage call out boxes, if the number of spaces occupied exceeds the number of
			// spaces available, change "Estimated ___ of ___ spaces available" to "Full".'
			if (!onStreet)
			{
				descriptionOfAvailability = @"Full";
			}
		} else if (numberOfOperationalSpaces == 0 && numberOfOccupiedSpaces == 0)
		{
			descriptionOfAvailability = @"Restricted";
		} else
		{
			descriptionOfAvailability = [NSString stringWithFormat:@"Estimated %d of %d spaces available", (numberOfOperationalSpaces-numberOfOccupiedSpaces),numberOfOperationalSpaces];
		}
	}
	return descriptionOfAvailability;
}

- (int) iconFinder:(BOOL)showPrice
{
	int itemImageName = -1;
	int numberOfOperationalSpaces = [allGarageData[@"OPER"] intValue];
	int occupied = [allGarageData[@"OCC"] intValue];
	NSDictionary *rates = allGarageData[@"RATES"];
	id rateStructure = rates[@"RS"];
	double usedpercent;
	BOOL invalidData = YES;
	
	if (!showPrice && !onStreet)
	{
		if( allGarageData[@"OCC"] == nil && allGarageData[@"OPER"] == nil)
		{
			// If occ and oper aren't returned, force the garage's icon to invalid coloration rules.
			return garage_invalid;
		}
	}
	
	//v1.4 change. Force invalid iconography if returns are < 0. (Out of band return value indicating known bad data, or otherwise invalid data)
	if(!showPrice  && occupied < 0)
	{
		//NSLog(@"onStreet and number of operationalspaces < 0. %d %@",occupied,[allGarageData description]);
		if (onStreet)
		{
			return street_invalid;
		}else
		{
			return garage_invalid;
		}

	}
	
	if (numberOfOperationalSpaces == 0)
	{
		usedpercent = 0.0;
		invalidData = YES;
	} else
	{
		usedpercent = (double) (occupied * 1.0/numberOfOperationalSpaces);
		invalidData = NO;
	}
	if (invalidData)
	{
		itemImageName = garage_invalid;
		if(onStreet)
		{
			itemImageName = street_invalid;
			if(numberOfOperationalSpaces == 0 && occupied == 0 && ! showPrice)
			{
				if(allGarageData[@"OCC"] == NULL && allGarageData[@"OPER"] == NULL)
				{
					return street_invalid;
				}
				return street_availability_low;
			}
		}
	}
	//v1.4 change. Garage's coloration buckets are now going to be 0-10,10-30, >30.
	//		Street parking shall stay colored at 0-15, 15-30, >30.
	//"On the map, change GARAGE occupancy display rules to the following:
	//0-10%  = red
	//10-30% = dark blue
	//> 30% = light blue (same as current)"
	if(onStreet)
	{
		// street bucket breaks here
		if (usedpercent >= 0.00 && usedpercent < 0.70)
		{
			itemImageName = street_availability_high;
		} else if(usedpercent >= 0.70 && usedpercent <= 0.85)
		{
			itemImageName = street_availability_medium;
		} else if (usedpercent > 0.85)
		{
			itemImageName = street_availability_low;
		}
	} else
	{ // Garage buckets
		if (usedpercent >= 0.00 && usedpercent < 0.70)
		{
			itemImageName = garage_availability_high;
		} else if(usedpercent >= 0.70 && usedpercent <= 0.90)
		{
			itemImageName = garage_availability_medium;
		} else if (usedpercent > 0.90)
		{
			itemImageName = garage_availability_low;
		}
	}
	int numberOfAvailableSpaces = numberOfOperationalSpaces - occupied;
	if(onStreet)
	{
		// Special cases handling.
		if ((numberOfAvailableSpaces == 1 && numberOfOperationalSpaces == 3) ||
            (numberOfAvailableSpaces == 1 && numberOfOperationalSpaces == 1) ||
            (numberOfAvailableSpaces == 1 && numberOfOperationalSpaces == 2)){
			itemImageName = street_availability_medium;
		}
	}
	
	if(occupied > numberOfOperationalSpaces)
	{
		//v1.4 "On map garage icons, if the number of spaces occupied exceeds the number of spaces available (i.e., overcapacity), icon should appear red, not grey."
		if(onStreet)
		{
			itemImageName =  street_availability_low;
		}else
		{
			itemImageName =  garage_availability_low;
		}
	}
    
	if (showPrice)
	{
		if (onStreet)
		{
			//Handle on street data parsing...
			itemImageName = street_invalid; //default to grey
			if (rates)
			{
				if ([rateStructure isKindOfClass:[NSArray class]] )
				{
					int rsc = [rateStructure count];
					for (int i =0; i < rsc; i++)
					{
						NSDictionary *st1 = rateStructure[i];
						[self rateStructureHandle:st1];
						float phr = [rate floatValue];
						//check to see if the current bucket applies.
						if ([self inThisBucketBegin: beg End:end])
						{
							itemImageName = [self nameFinderWithOnStreet:YES andPrice:phr];
							pricePerHour = phr;
							break;
						}
					}
				} else
				{
					[self rateStructureHandle:rateStructure];
					float phr = [rate floatValue];
					//check to see if the current bucket applies.
					if ([self inThisBucketBegin: beg End:end])
					{
						itemImageName = [self nameFinderWithOnStreet:YES andPrice:phr];
						pricePerHour = phr;
					}
				}
			}
			rateQualifier = rq;
		} else
		{
            // garages
			if (rates)
			{
                if ([rateStructure isKindOfClass:[NSArray class]])
								{
                    BOOL isDynamicPricing = YES;
                    int rsc = [rateStructure count];
                    for (int i =0; i < rsc; i++)
										{
                        NSDictionary *st1 = rateStructure[i];
                        id description	 = st1[@"DESC"];
                        float phr =  [st1[@"RATE"] floatValue];
                        if ([description rangeOfString:@"Incremental"].location !=  NSNotFound && description != nil)
												{
                            itemImageName = [self nameFinderWithOnStreet:NO andPrice:phr];
                            isDynamicPricing = NO;
                            pricePerHour = phr;
                            break;
                        }
                    }
            
                    if(isDynamicPricing)
										{
                        for (int i =0; i < rsc; i++)
												{
                            NSDictionary *st1 = rateStructure[i];
                            float phr =  [st1[@"RATE"] floatValue];
                            [self rateStructureHandle:st1];
                            if ([self inThisBucketBegin: beg End:end])
														{
                                itemImageName = [self nameFinderWithOnStreet:NO andPrice:phr];
                                pricePerHour = phr;
                                break;
                            }
                        }
                    }
                } //else rateStructure is NOT NSArray
			}
		}
	}
	rateQualifier = rq;
	return itemImageName;
}

// Figure out which parking garage icon to display.
- (int) nameFinderWithOnStreet:(BOOL) isOnStreet andPrice:(float) phr
{
	int imageName = 0;
	if (isOnStreet)
	{
		if (phr <= 2.00 && phr >=0.00)
		{
			if(phr == 0.00)
			{
				if (![rq isEqualToString:@"No charge"])
				{
					imageName = street_invalid;
				}else
				{
					imageName = street_price_low;
				}
			} else
			{
				imageName = street_price_low;
			}
		} else if(phr > 2.00 && phr <= 4.00)
		{
			imageName = street_price_medium;
		} else if (phr > 4.00)
		{
			imageName = street_price_high;
		} else
		{
			imageName = street_invalid;
		}
	} else
	{
		if (phr <= 2.00 && phr >= 0.00)
		{
			imageName = garage_price_low;
		} else if (phr > 2.00 && phr <= 4.00)
		{
			imageName = garage_price_medium;
		} else if (phr > 4.00)
		{
			imageName = garage_price_high;
		}
	}
	return imageName;
}

// Update properties of start and end times for the current rate.
- (void)rateStructureHandle:(id) rateStructure
{
	if ([rateStructure isKindOfClass:[NSDictionary class]])
	{
		beg  = nil;
		end  = nil;
		rate = nil;
		rq	 = nil;
		beg  = rateStructure[@"BEG"];
		end	 = rateStructure[@"END"];
		rate = rateStructure[@"RATE"];
		rq   = rateStructure[@"RQ"];
	}
}

// Create an NSDate from the passed in string like: 7:00 AM, 12:00 AM or 12:00 PM
- (NSDate *) createDateFromString: (NSString *) dateString
{
	int minutes,hour;
	NSArray* parts,* subparts;
	parts = [dateString componentsSeparatedByString:@":"];
	subparts = [parts[1] componentsSeparatedByString:@" "];
	minutes = [subparts[0] intValue];
	if ([subparts[1] isEqualToString:@"PM"] )
	{
		if ([parts[0] intValue] != 12 )
		{
			hour = [parts[0] intValue] + 12;
		} else
		{
			hour = [parts[0] intValue];
		}
	} else
	{
		hour = [parts[0] intValue];
		if (hour == 12)
		{
			hour = 0;
		}
	}
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *comps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit 
																				fromDate:timeStamp];
	[comps setHour:hour];
	[comps setMinute:minutes];
	[comps setSecond:0];
	return [calendar dateFromComponents:comps];
}


// Determine if we are in the time period given by beg and end.
- (BOOL) inThisBucketBegin:(NSString *) beginString End:(NSMutableString *) endString
{
	if (beginString == nil || endString == nil)
	{
		return NO;
	}
	[endString replaceOccurrencesOfString:@"12:00 AM" withString:@"11:59 PM" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [endString length])];
	BOOL inBucket = NO;
	NSDate *bucketBeginDate, *bucketEndDate;

	bucketBeginDate = [self createDateFromString:beginString];
	bucketEndDate   = [self createDateFromString:endString];

	NSComparisonResult resultStart = [timeStamp compare:bucketBeginDate];
	if (resultStart == NSOrderedAscending)
	{
		inBucket = NO; // Timestamp is before bucketBeginDate
	} else if (resultStart == NSOrderedDescending)
	{
		NSComparisonResult resultEnd = [timeStamp compare:bucketEndDate];
		if (resultEnd == NSOrderedAscending)
		{
			inBucket = YES;
		} else if (resultEnd == NSOrderedDescending)
		{
			//timestamp is after bucketEndDate
			inBucket = NO;
		} else
		{
			// Timestamp is equal to  bucketEndDate
			inBucket = YES;
		}
	}  else
	{
		// Timestamp is equal to  bucketBeginDate
		inBucket = YES;
	}

	// Double forehead slap. There's insistence that 12:00 AM be treated as the last minute of the day rather than the first. 
	[endString replaceOccurrencesOfString:@"11:59 PM" withString:@"12:00 AM" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [endString length])];
	
	/*
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd'T'H:mm:ss'.'SSSZZZZ"];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MM/dd/yy 'at' hh:mm:ss.SSa"];
	NSString *strDateBegin = [dateFormatter stringFromDate:bucketBeginDate];
	NSString *strDateTimestamp = [dateFormatter stringFromDate:timeStamp];
	NSString *strDateEnd = [dateFormatter stringFromDate:bucketEndDate];
	if (inBucket) {
		NSLog(@"\nstrDateBegin, strDateTimestamp, strDateEnd  %@ %@ %@", strDateBegin,strDateTimestamp,strDateEnd);
	}
	[dateFormatter release];
	[df release];
	*/
	//NSLog(@"\nbegin | timestamp | end\n%@|%@|%@",bucketBeginDate,timeStamp,bucketEndDate);
	//NSLog(@"\nbegin | timestamp | end\n%@|%@|%@\n",beginString,timeStamp,endString);
	//NSLog(@"\nbegin | timestamp | end\n%@|%@|%@\n\n",beginString,timeStamp,endString);
	
	
	return inBucket;
}

// Determine which price bucket we are in.
- (UIColor *) bucketFinder: (float) price
{
	UIColor * lineColor;

    // v1.3 and forward price colorations (Round three)
    UIColor * priceLow = [[UIColor alloc] initWithRed:0/255.0      green:218/255.0 blue:2/255.0    alpha:1.0];
    UIColor * priceMed = [[UIColor alloc] initWithRed:28/255.0     green:116/255.0 blue:30/255.0   alpha:1.0];
    UIColor * priceHigh= [[UIColor alloc] initWithRed:31/255.0     green:74/255.0  blue:31/255.0   alpha:1.0];
	UIColor * grey     = [[UIColor alloc] initWithRed:141/255.0    green:141/255.0 blue:141/255.0  alpha:1.0];
	
	if (price <= 2.00 && price >= 0.00)
	{
		if(price == 0.00)
		{
			if (![rq isEqualToString:@"No charge"])
			{
				lineColor = grey;
			}else
			{
				lineColor = priceLow;
			}
			rateQualifier = rq;
		} else
		{
			lineColor = priceLow;
		}
		pricePerHour = price;
	} else if(price > 2.00 && price <= 4.00)
	{
		lineColor = priceMed;
		pricePerHour = price;
	} else if (price > 4.00)
	{
		lineColor = priceHigh;
		pricePerHour = price;
	} else
	{
		//NSLog(@"%@ %f",rq,price);
		lineColor = grey;
		pricePerHour = price;
	}
	return lineColor;
}


// Color lookup for polylines.
- (UIColor *) blockfaceColorizerWithShowPrice:(BOOL)showPrice
{
	double usedPercent = 0;
	int numberOfOperationalSpaces = 0;
	int occupied = 0;
	int numberOfAvailableSpaces = 0;
	UIColor *lineColor;

    // v1.3 and forward availability colorations (Round three)
    UIColor * availLow = [[UIColor alloc] initWithRed:253/255.0    green:44/255.0  blue:39/255.0 alpha:1.0];
    UIColor * availMed = [[UIColor alloc] initWithRed:0/255.0      green:60/255.0  blue:88/255.0 alpha:1.0];
    UIColor * availHigh= [[UIColor alloc] initWithRed:16/255.0     green:202/255.0 blue:251/255.0 alpha:1.0];
    
    UIColor * grey = [[UIColor alloc] initWithRed:141/255.0 green:141/255.0 blue:141/255.0 alpha:1.0];

    
	UIColor * red;
    /* v1.3 feature request. switch away from the red. Effectively stops "restricted type spaces" from being red too. */
    red = availLow;

	//lineColor = priceLow;
	lineColor = grey;

	if(allGarageData[@"OPER"])
	{
		numberOfOperationalSpaces = [allGarageData[@"OPER"] intValue];
		if(allGarageData[@"OCC"])
		{
			occupied = [allGarageData[@"OCC"] intValue];
			if(numberOfOperationalSpaces == 0 && occupied == 0 && !showPrice)
			{
				return red;
			}
			if(numberOfOperationalSpaces == 0)
			{
				usedPercent = 0.0;
			} else
			{
				usedPercent = (double) ((occupied * 1.0)/numberOfOperationalSpaces);
			}
		}
	} else
	{
		// OPER # wasn't returned, so we should paint the block with low availability or grey as dictated by price/availability mode.
		if (!showPrice || (occupied != 0 && numberOfOperationalSpaces != 0))
		{
			if(allGarageData[@"OCC"] == NULL && allGarageData[@"OPER"] == NULL)
			{
				return grey;
			}			
			return red;	
		}
	}
	numberOfAvailableSpaces = numberOfOperationalSpaces - occupied;
	if (showPrice)
	{
		NSDictionary *rates = allGarageData[@"RATES"];
		if (rates)
		{
			id rateStructure = rates[@"RS"];
			if ([rateStructure isKindOfClass:[NSArray class]] )
			{
				int rsc = [rateStructure count];
				for (int i = 0; i < rsc; i++)
				{
					NSDictionary *st1 = rateStructure[i];
					[self rateStructureHandle:st1];
					if ([self inThisBucketBegin: beg End:end])
					{
						lineColor = [self bucketFinder: [rate floatValue]];
						break;
					}
				}
			} else if ([rateStructure isKindOfClass:[NSDictionary class]])
			{
				[self rateStructureHandle:rateStructure];
				if ([self inThisBucketBegin: beg End:end])
				{
					lineColor = [self bucketFinder: [rate floatValue]];

				}
			}

		} else
		{
			//NSLog(@"Fail... No rate information...");
		}

	} else
	{
		// color for availability...
		if (usedPercent >= 0.00 && usedPercent < 0.70)
		{
			lineColor = availHigh;
		} else if(usedPercent >= 0.70 && usedPercent <= 0.85)
		{
			lineColor = availMed;
		} else if (usedPercent > 0.85)
		{
			lineColor = availLow;
		}else
		{
			lineColor = grey;
		}
		// Special case handling. (So the user doesn't get 'confused' by coloration on small blocks)
		if ((numberOfAvailableSpaces == 1 && numberOfOperationalSpaces == 3) ||
            (numberOfAvailableSpaces == 1 && numberOfOperationalSpaces == 1) ||
            (numberOfAvailableSpaces == 1 && numberOfOperationalSpaces == 2)){
			lineColor = availMed;
		}

	}
	return lineColor;
}

@end