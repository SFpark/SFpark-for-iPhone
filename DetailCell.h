//
//  DetailCell.h
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

#import <UIKit/UIKit.h>


@interface DetailCell : UITableViewCell{
	// adding the 4 labels we want to show in the cell
	UILabel *cellLabel1;
	UILabel *cellLabel2;
	UILabel *cellLabel3;
	UILabel *cellLabel4;
	
}

@property (nonatomic, retain) UILabel *cellLabel1;
@property (nonatomic, retain) UILabel *cellLabel2;
@property (nonatomic, retain) UILabel *cellLabel3;
@property (nonatomic, retain) UILabel *cellLabel4;

@end
