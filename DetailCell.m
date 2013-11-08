//
//  DetailCell.m
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

#import "DetailCell.h"


@implementation DetailCell

@synthesize cellLabel1,cellLabel2,cellLabel3,cellLabel4;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self)
	{
		// Initialization code.
		
		
		CGRect defaultFrame = CGRectZero;
		UIColor * cellBackgroundColor = [UIColor clearColor];
		
		//alloc the labels here, once only, then configure them later on.
		
		cellLabel1 = [[UILabel alloc] initWithFrame:defaultFrame];
		cellLabel2 = [[UILabel alloc] initWithFrame:defaultFrame];
		cellLabel3 = [[UILabel alloc] initWithFrame:defaultFrame];
		cellLabel4 = [[UILabel alloc] initWithFrame:defaultFrame];
		
		cellLabel1.backgroundColor = cellBackgroundColor;
		cellLabel2.backgroundColor = cellBackgroundColor;
		cellLabel3.backgroundColor = cellBackgroundColor;
		cellLabel4.backgroundColor = cellBackgroundColor;
		
		//apparently cell.textLabel.font  = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
		//     		 cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
		
		cellLabel1.font = [UIFont fontWithName:@"Helvetica" size:16.0];
		cellLabel2.font = [UIFont fontWithName:@"Helvetica" size:16.0];
		cellLabel3.font = [UIFont fontWithName:@"Helvetica" size:16.0];
		cellLabel4.font = [UIFont fontWithName:@"Helvetica" size:16.0];

		//could hide them if necessary
		
		[self.contentView addSubview:cellLabel1];
		[self.contentView addSubview:cellLabel2];
		[self.contentView addSubview:cellLabel3];
		[self.contentView addSubview:cellLabel4];
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
  
	// Configure the view for the selected state.
}

@end