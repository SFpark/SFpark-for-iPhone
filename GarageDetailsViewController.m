//
//  GarageDetailsViewController.m
//  SFpark
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


#import "GarageDetailsViewController.h"

#ifdef DEBUG
#define CMDLOG	NSLog(@"%@ : %@",[self description],NSStringFromSelector(_cmd))
#else
#define CMDLOG
#endif

#ifdef DEBUG
#define MYLOG(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define MYLOG(format, ...)
#endif

@implementation GarageDetailsViewController

@synthesize delegate;
@synthesize myWebView;
@synthesize thisGarage;

#define HOURS_SECTION		0
#define RATES_SECTION		1
#define INFO_SECTION		2

#define SUBTITLE			1
#define ROWH				35

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	CMDLOG;
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		// Custom initialization
		thisGarage = nil;
		infoDict = nil;
		
		hoursRows = 0;
		ratesRows = 0;
		infoRows = 0;
		i = 0;
		
		hoursRowsText = 0;
		ratesRowsText = 0;
		infoRowsText = 0;
		
		row	 = nil;
		
		beg	 = nil;		// Indicates the begin time for this rate schedule (or hours schedule use same var for both)
		end	 = nil;		// Indicates the end time for this rate schedule (or hours schedule use same var for both)
		from = nil;		// Start day for this schedule, e.g., Monday
		to   = nil;		// End day for this schedule, e.g., Friday
		rate = nil;		// Applicable rate for this rate schedule
		desc = nil;		// Used for descriptive rate information when not possible to specify using BEG or END times for this rate schedule
		rq   = nil;		
		rr   = nil;		
		
		onStreetParking = NO;		// YES = parking garage .. defunct?
		
		hoursNow = 0;		//the row number of the hours range that the current time is in
		ratesNow = 0;		//the row number of the rates range that the current time is in
		
	}
	return self;
}

- (void)viewDidLoad
{

	UISwipeGestureRecognizer *recognizer;
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	[recognizer setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft )];
	[[self view] addGestureRecognizer:recognizer];

	if(!IS_IPHONE_5)
	{
		CGRect backNewFrame = CGRectMake(0, 113, 73, 37);
		[backButton setFrame:backNewFrame];
	}
	
	CMDLOG;
	
	[super viewDidLoad];
	
	if (!thisGarage)
		return;			//thats as far as we get with no garage data!
	
	infoDict = thisGarage.allGarageData;
	
	MYLOG(@"Got dict %@",infoDict);
	
	nameLabel.text = infoDict[@"NAME"];
	garageUse.text = thisGarage.subtitle;
	
	streetLabel.text = thisGarage.title;
	streetUse.text = thisGarage.subtitle;

	NSString *addr = infoDict[@"DESC"];
	
	//change to est. ## of ## spaces available 
	
	if (addr)
	{ //fixes "null" for on street parking detail
		addressLabel.text = [NSString stringWithFormat:@"%@ (%@)",addr, infoDict[@"INTER"]];
	}else
	{
		onStreetParking = YES;
		addressLabel.text = @"";	//[NSString stringWithFormat:@"  %@ spaces occupied", [infoDict objectForKey:@"OCC"]];
	}
	
	NSString *tel = infoDict[@"TEL"];
	
	if (tel)
	{	//fixes "null" for on street parking detail
		phoneTextView.text = tel;
	}else
	{
		phoneTextView.text = @"";	//[NSString stringWithFormat:@"%@ spaces operational", [infoDict objectForKey:@"OPER"]];
	}
	// move tableView up??
		
	//	[self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationBottom];
	//	- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
	
	[self performSelector:@selector(viewAppeared) withObject:nil afterDelay:0.0];  //emulating viewwdidappear like behaviour without push navigation controller?
	//	[self viewAppeared];

	if (thisGarage.onStreet)
	{
		infoTableView.tableHeaderView = streetHeaderView;
	}else
	{
		infoTableView.tableHeaderView = infoHeaderView;
	}
	infoTableView.backgroundColor = [UIColor clearColor];
	infoTableView.allowsSelection = NO;	//even though this is set to NO in Interface Builder
	
	[self parseHours];
	[self parseRates];
	[self parseInfo];
	
}

- (void)viewAppeared
{
	CMDLOG;
	
	infoTableView.showsVerticalScrollIndicator = YES;
	[infoTableView flashScrollIndicators];
		
	[infoTableView reloadData];

}


- (NSString*)fixDay:(NSMutableString*)dstr
{

	CMDLOG;
	
	if  ([dstr length] < 6)
	{
		return dstr;
	}
	
	[dstr replaceOccurrencesOfString:@"Monday"    withString:@"Mon" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [dstr length])];
	[dstr replaceOccurrencesOfString:@"Tuesday"   withString:@"Tue" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [dstr length])];
	[dstr replaceOccurrencesOfString:@"Wednesday" withString:@"Wed" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [dstr length])];
	[dstr replaceOccurrencesOfString:@"Thursday"  withString:@"Thu" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [dstr length])];
	[dstr replaceOccurrencesOfString:@"Friday"    withString:@"Fri" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [dstr length])];	
	[dstr replaceOccurrencesOfString:@"Saturday"  withString:@"Sat" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [dstr length])];
	[dstr replaceOccurrencesOfString:@"Sunday"    withString:@"Sun" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [dstr length])];

	return (NSString*)dstr;
}


- (void)parseHours
{
	CMDLOG;
	
	
	hoursRowsText = [NSMutableArray arrayWithCapacity:20];		//meh. no retain == crash
	hoursRows = 0;	//default

	//tests...
	NSDictionary *ophrs = infoDict[@"OPHRS"];
	
	if (!ophrs)
	{
		return;
	}
	
	id ops = ophrs[@"OPS"];	//could be NSArray or NSDict if just one entry
	
	if (![ops isKindOfClass:[NSArray class]])
	{
		//huge assumptions here! (fixed..ish)
		beg  = ops[@"BEG"];
		end	 = ops[@"END"];
		from = ops[@"FROM"];
		to	 = ops[@"TO"];
		
		if (end)
		{
			end = [NSString stringWithFormat:@"- %@", end];
		}else
		{
			end = @"";
		}
		
		if (to)
		{
			to = [self fixDay:to];
			to = [NSString stringWithFormat:@"- %@", to];
		}else
		{
			to = @"";
		}
		
		if (!beg)
		{
			beg = @"";
		}
		if (!from)
		{
			from = @"";
		}

		row = [NSString stringWithFormat:@"%@ %@: %@ %@",[self fixDay:from],to,beg,end];	

		[hoursRowsText insertObject:row atIndex:0];
		hoursRows = 1;
		return;
	}
	
	hoursRows = [ops count];

	for (i =0; i < hoursRows; i++)
	{
		NSDictionary *st1 = ops[i];
	
		//objectForKey Return Value - The value associated with aKey, or nil if no value is associated with aKey.
	
		beg  = st1[@"BEG"];
		end	 = st1[@"END"];
		from = st1[@"FROM"];
		to	 = st1[@"TO"];
	
		if ([thisGarage inThisBucketBegin: beg End:end])
		{
			hoursNow = i + SUBTITLE;
		}

		if (to)
		{
			row = [NSString stringWithFormat:@"%@ - %@: %@ - %@",[self fixDay:from],[self fixDay:to],beg,end];
		}else
		{
			row = [NSString stringWithFormat:@"%@: %@ - %@",[self fixDay:from],beg,end];
		}
		[hoursRowsText insertObject:row atIndex:i];
		
		MYLOG(row,nil);
	}
}

//RS + BEG/END goes to Rates bucket. If DESCs only, don't display section?

- (void)parseRates
{
	CMDLOG;
		
	ratesRows = 0;	//default = 1
	
	//tests...
	NSDictionary *rates = infoDict[@"RATES"];
	
	if (!rates)
	{
		return;
	}
	
	id rs = rates[@"RS"];	//could be NSArray or NSDict if just one entry
	
	
	if (![rs isKindOfClass:[NSArray class]])
	{
		//[ratesRowsText insertObject:@"Invalid data structure" atIndex:0];		//dont know what to do yet if its not an NSArray, just choke for now.
        
        //just one dictionary, not array of dictionaries
        //lets just assume beg and end and rate for now
        
		beg  = rs[@"BEG"];
		end	 = rs[@"END"];
		rate = rs[@"RATE"];
		rq   = rs[@"RQ"];
		
		float phr = [rate floatValue]; i = 0;
		

		if (beg)
		{
			
			if ([thisGarage inThisBucketBegin: beg End:end])
			{
				ratesNow = i + SUBTITLE;
			}
      
			if (!ratesRowsText)
			{
				ratesRowsText = [NSMutableArray arrayWithCapacity:20];		//meh. no retain == crash
				pricesText = [NSMutableArray arrayWithCapacity:20];		//meh. no retain == crash
			}
            
			ratesRows++;
			row = [NSString stringWithFormat:@"%@ - %@",beg,end];
			[ratesRowsText insertObject:row atIndex:i];
			
			if (phr == 0)
			{
				[pricesText insertObject:rq atIndex:i];
			}else
			{
				[pricesText insertObject:[NSString stringWithFormat:@"$%.2f hr",phr] atIndex:i];
			}
      
			MYLOG(row,nil);
		}
		return;
	}
	
	int rsc = [rs count];
	
	for (i =0; i < rsc; i++)
	{
		NSDictionary *st1 = rs[i];
		
		//lets just assume beg and end and rate for now
				
		beg  = st1[@"BEG"];
		end	 = st1[@"END"];
		rate = st1[@"RATE"];
		rq   = st1[@"RQ"];
		
		float phr = [rate floatValue];
		
		if (beg)
		{
			
			if ([thisGarage inThisBucketBegin: beg End:end])
			{
				ratesNow = i + SUBTITLE;
			}
			if (!ratesRowsText)
			{
				ratesRowsText = [NSMutableArray arrayWithCapacity:20];		//meh. no retain == crash
				pricesText = [NSMutableArray arrayWithCapacity:20];		//meh. no retain == crash
			}

			ratesRows++;
			row = [NSString stringWithFormat:@"%@ - %@",beg,end];
			[ratesRowsText insertObject:row atIndex:i];
			
			if (phr == 0)
			{
				[pricesText insertObject:rq atIndex:i];
			}else
			{
				[pricesText insertObject:[NSString stringWithFormat:@"$%.2f hr",phr] atIndex:i];
			}
		
			MYLOG(row,nil);
		}
	}
}

//RS + DESC goes to Information bucket.

- (void)parseInfo
{
	CMDLOG;
		
	infoRows = 1;	//default = 1
	
	for (i = 1; i < 20; i++)
	{
		infoRowsHeights[i] = ROWH * 2;		//TEMP
	}
		//infoRowsHeights[i] = ROWH * 2;		//default table row height to all 4 lines, subtract as needed when rows found to be empty?
	infoRowsHeights[0] = ROWH;		//default table row height

	
	//tests...
	NSDictionary *rates = infoDict[@"RATES"];
	
	if (!rates)
	{
		return;
	}
	
	id rs = rates[@"RS"];	//could be NSArray or NSDict if just one entry
	
	
	if (![rs isKindOfClass:[NSArray class]])
	{
		//[ratesRowsText insertObject:@"Invalid data structure" atIndex:0];		//dont know what to do yet if its not an NSArray, just choke for now.
		return;
	}
	
	int rsc = [rs count];
	
	for (i = 0; i < rsc; i++)
	{
		NSDictionary *st1 = rs[i];
		
		//lets just assume desc for now
		
		desc  = st1[@"DESC"];
		rate = st1[@"RATE"];
		rq   = st1[@"RQ"];			// rate qualifier ... could be null
		rr   = st1[@"RR"];			// rate restriction need to scan for semi-colon -> new line ETC!
		
		float phr = [rate floatValue];
		
		if (desc)
		{
			if (!infoRowsText)
			{
				infoRowsText = [NSMutableArray arrayWithCapacity:20];		//meh. no retain == crash
				pricesText2 = [NSMutableArray arrayWithCapacity:20];		//meh. no retain == crash
				raterRowsText = [NSMutableArray arrayWithCapacity:20];		//meh. no retain == crash
				for (j=0; j <20; j++)
				{
					[infoRowsText insertObject:@"" atIndex:j];				//some rows of this will be blank, hint the table drawing
					[pricesText2 insertObject:@"" atIndex:j];				//some rows of this will be blank, hint the table drawing
					[raterRowsText insertObject:@"" atIndex:j];				//some rows of this will be blank, hint the table drawing, or something.
				}
			}
			
			row = [NSString stringWithFormat:@"%@:",desc];		//TEMP 
			[infoRowsText insertObject:row atIndex:infoRows];
				
			if (phr == 0)
			{
				[pricesText2 insertObject:rq atIndex:infoRows];
			}else
			{
				if (rq)
				{
					row = [NSString stringWithFormat:@"$%.2f %@",phr, rq];
				}else
				{
					row = [NSString stringWithFormat:@"$%.2f",phr];
				}
				[pricesText2 insertObject:row atIndex:infoRows];	//dunno yet...
			}
			
			if (rr)
			{
				//check for semi colon
				NSMutableString *sinfo = [NSMutableString stringWithString:rr];
				[sinfo replaceOccurrencesOfString:@";" withString:@". " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [sinfo length])];
				//				[sinfo replaceOccurrencesOfString:@";" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [sinfo length])];		//put a new line in like the docs say? nah...
				
				[raterRowsText insertObject:sinfo atIndex:infoRows];	
				
				CGSize maxsz = CGSizeMake(296,9999);	//Calculate the expected size based on the font and linebreak mode
				
				CGSize newsz = [sinfo sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0] constrainedToSize:maxsz lineBreakMode:NSLineBreakByWordWrapping]; //    [cell.textLabel sizeToFit]?
								
//				infoRowsHeights[infoRows] += (newsz.height/20)*ROWH;		//should be (newh/[UIFont height])*ROWH
				infoRowsHeights[infoRows] += ceil((newsz.height/20)*ROWH);		//should be (newh/[UIFont height])*ROWH
				
				NSLog(@"%d --- inforowsheights",infoRowsHeights[infoRows]);
				MYLOG(@"'%@' new width %f new height %f",sinfo,newsz.width,newsz.height);

			}
			
			infoRows++;

			MYLOG(row,nil);
		}
	}
	
}

- (IBAction)doneWithDetails:(id)sender
{
	CMDLOG;
	
	[self dismissViewControllerAnimated:YES completion:nil];
	//[self.delegate garageDetailsViewControllerDidFinish:self];
}

- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
	if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
	{
		NSLog(@"left");
		[self performSelector:@selector(doneWithDetails:) withObject:nil afterDelay:0.0];
	}else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight)
	{
		NSLog(@"right");
	}else
	{
		NSLog(@"%d",recognizer.direction);
	}
}

// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 // self.navigationItem.rightBarButtonItem = self.editButtonItem;


/*
 - (void)viewWillAppear:(BOOL)animated 
 {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated 
 {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated 
 {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated 
 {
 [super viewDidDisappear:animated];
 }
 */
/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
 {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
	
	if (onStreetParking)
	{
		return 1;
	}
	
//	if (!ratesRows)
//	{
//		return 2;
//	}
	
	return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	
	if (onStreetParking)
	{
		if (!ratesRows) return 0;			//dont display the rates section at all.
		return ratesRows + SUBTITLE;
	}
	
	if (section == HOURS_SECTION)
	{
		if (!hoursRows) return 0;			//dont display the hours section at all.
		return hoursRows + SUBTITLE;
	}
	
	if (section == RATES_SECTION)
	{
		if (!ratesRows) return 0;			//dont display the rates section at all.
		return ratesRows + SUBTITLE;
	}
	
	if (section == INFO_SECTION)
	{
		if (infoRows == 1) return 0;			//dont display the descriptions / info / discounts section at all.
		return infoRows;
	}
		
    return 1;	//default
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//some of the extended rate descriptions may be two lines. oh snap!
	
	if (indexPath.section == INFO_SECTION)
	{
		return infoRowsHeights[indexPath.row];		//in case there is a two line row
	}
	
	return ROWH;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIColor * darkgrey = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1];
	UIColor * midgrey = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
	UIColor * lightgrey = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
	static NSString *CellIdentifier = @"Cell";
	
	DetailCell *cell = (DetailCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
	cell = [[DetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];		
	}

	cell.cellLabel1.frame = CGRectZero; cell.cellLabel1.text = @"";
	cell.cellLabel2.frame = CGRectZero; cell.cellLabel2.text = @"";
	cell.cellLabel3.frame = CGRectZero;	cell.cellLabel3.text = @"";
	cell.cellLabel4.frame = CGRectZero;	cell.cellLabel4.text = @"";
    
	cell.cellLabel1.backgroundColor = lightgrey;
	cell.cellLabel2.backgroundColor = lightgrey;
	cell.cellLabel3.backgroundColor = lightgrey;
	cell.cellLabel4.backgroundColor = lightgrey;
	
	// Configure the cell...default the cell background to light grey, black text
	
	cell.textLabel.text = @"";
	cell.textLabel.textColor = [UIColor blackColor];
	cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
	
	[cell setBackgroundColor:lightgrey];

	
	if ((indexPath.section == RATES_SECTION) || onStreetParking)
	{
		if (indexPath.row == 0)
		{
			cell.textLabel.text = @"Rates";
			cell.textLabel.textColor = [UIColor whiteColor];
			[cell setBackgroundColor: darkgrey];
		}else
		{
			if (ratesRowsText)
			{
				if (indexPath.row == ratesNow)
				{
					[cell setBackgroundColor:midgrey];
					cell.cellLabel1.backgroundColor = midgrey;
					cell.cellLabel2.backgroundColor = midgrey;
				}
					
				CGRect tframe = CGRectMake(15, 10, 180, 22);
				[cell.cellLabel1 setFrame:tframe];
				cell.cellLabel1.text = ratesRowsText[indexPath.row-1];
								
				CGRect pframe = CGRectMake(210, 10, 80, 22);
				[cell.cellLabel2 setFrame:pframe];
				cell.cellLabel2.text = pricesText[indexPath.row-1];
							
			}
		}
	}

	if (onStreetParking)
	{
		return cell;
	}
	
	if (indexPath.section == HOURS_SECTION)
	{
		if (indexPath.row == 0)
		{
			cell.textLabel.text = @"Hours of Operation"; 
			cell.textLabel.textColor = [UIColor whiteColor];
			[cell setBackgroundColor: darkgrey];
		}else
		{
			if (hoursRowsText)
			{
				//if (indexPath.row == hoursNow)
				//	[cell setBackgroundColor:midgrey];
				cell.textLabel.text = hoursRowsText[indexPath.row-1];
			}
		}
	}
	
	
	if (indexPath.section == INFO_SECTION)
	{
		if (indexPath.row == 0)
		{
            if (ratesRows)
						{
				cell.textLabel.text = @"Information";
            }else
						{
				cell.textLabel.text = @"Rates";
            }
			cell.textLabel.textColor = [UIColor whiteColor];
			[cell setBackgroundColor: darkgrey];
		}else
		{
			if (infoRowsText)
			{
				//pro tempore - we need more formatting here.
				
				//		---------------------
				//		| DESC				|
				//		---------------------
				//		| RATE		|	RQ	|
				//		---------------------
				//		| RR LINE 1			|
				//		| RR LINE 2			|
				//		---------------------
							
				CGRect dframe = CGRectMake(15, 10, 280, 22);
				[cell.cellLabel1 setFrame:dframe];
				cell.cellLabel1.text  = infoRowsText[indexPath.row];

	
				CGRect rframe = CGRectMake(15, 10+ROWH, 280, 22);
				[cell.cellLabel2 setFrame:rframe];
				cell.cellLabel2.text = pricesText2[indexPath.row];
				
				//rate restriction .. extract and parse for multiline here
				
				CGRect rrframe = CGRectMake(15, 10+(ROWH*2), 280, 100);
				[cell.cellLabel3 setFrame:rrframe];
				cell.cellLabel3.lineBreakMode = NSLineBreakByWordWrapping;
				cell.cellLabel3.numberOfLines = 0;
				cell.cellLabel3.adjustsFontSizeToFitWidth = NO;
		
				NSString *sinfo = raterRowsText[indexPath.row];
				cell.cellLabel3.text = sinfo;
			//	[cell.cellLabel3 sizeToFit];		//but can't duplicate in pre-scan?
			//	cell.cellLabel3.backgroundColor = [UIColor colorWithRed:0.1 green:0.8 blue:0.4 alpha:1];
			//Calculate the expected size based on the font and linebreak mode
				CGSize maximumLabelSize = CGSizeMake(280,9999); //was 296, which was too wide.
				
				CGSize expectedLabelSize = [sinfo sizeWithFont:cell.cellLabel3.font 
												constrainedToSize:maximumLabelSize 
													lineBreakMode:cell.cellLabel3.lineBreakMode]; //    [cell.textLabel sizeToFit]?
				
				MYLOG(@"'%@' new width %f new height %f",sinfo,ceil(expectedLabelSize.width),ceil(expectedLabelSize.height));
				
				//adjust the label to the new height.
				CGRect newFrame = cell.cellLabel3.frame;
				newFrame.size.height = ceil(expectedLabelSize.height);
				newFrame.size.width = ceil(expectedLabelSize.width);
				cell.cellLabel3.frame = newFrame;
			}
		}
	}
	return cell;
}


/*
 // Override to support conditional editing of the table view.
 // dolor brevis, victoria aeterna
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
 {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) 
 {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) 
 {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
 {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

/*
 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
 
 */

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


@end
