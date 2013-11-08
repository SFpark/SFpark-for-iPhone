//
//  IntroViewController.h
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

@protocol IntroViewControllerDelegate;


@interface IntroViewController : UIViewController
{
	id <IntroViewControllerDelegate> __weak delegate;

}

@property (nonatomic, weak) id <IntroViewControllerDelegate> delegate;
@property (nonatomic, strong) UIWebView *myWebView;

- (IBAction)doneIntro:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *accept;
@end

@protocol IntroViewControllerDelegate
- (void)introViewControllerDidFinish:(IntroViewController *)controller;
@end