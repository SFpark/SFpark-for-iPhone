//
//  SpeedingViewController.m
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

#import "SpeedingViewController.h"

@implementation SpeedingViewController

@synthesize delegate;
@synthesize acceptWarning;
@synthesize myWebView;

- (void) viewDidLoad
{
	[super viewDidLoad];

	CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
	webFrame.origin.y = 108.0;
	webFrame.size.height = 340.0;
	webFrame.size.width =  320.0;
	if (IS_IPHONE_5)
	{
		int iphone5heightaddition = 40;
		webFrame.size.height += iphone5heightaddition;
	}
	
	if(!IS_IPHONE_5)
	{
		CGRect acceptFrame = CGRectMake(10, 420, 240, 37);
		[acceptWarning setFrame:acceptFrame];
	}


	self.myWebView = [[UIWebView alloc] initWithFrame:webFrame];
	self.myWebView.backgroundColor = [UIColor whiteColor];
	self.myWebView.scalesPageToFit = NO;
	self.myWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.myWebView.delegate = self;
	[self.view addSubview: self.myWebView];
	NSString *imagePath = [[NSBundle mainBundle] resourcePath];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"speeding" ofType:@"html"];
	NSData *htmlData = [NSData dataWithContentsOfFile:htmlFile];
	[myWebView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" 	baseURL:[NSURL URLWithString: [NSString stringWithFormat:@"file:/%@//",imagePath]]];
}

-(IBAction) acceptWarningPressed
{
	[self.delegate speedViewControllerDidFinish:self];	
}

- (void) dealloc
{
	myWebView.delegate = nil;
}

@end