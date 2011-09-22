//
//  IntroViewController.m
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

#import "IntroViewController.h"


@implementation IntroViewController

@synthesize delegate;
@synthesize myWebView;


- (void) viewDidLoad {
	[super viewDidLoad];
	[self performSelector:@selector(doneIntro:) withObject:nil afterDelay:60 * 10]; // Timeout and load the main display eventually.
	
	//The UIWebView looks a little bit better but takes a LONG time to load.  Switching to a text view for now.
	/* 
	CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
	webFrame.origin.y = 80.0;
	webFrame.size.height = 340.0;
	webFrame.size.width =  320.0;	
	self.myWebView = [[[UIWebView alloc] initWithFrame:webFrame] autorelease];
	self.myWebView.backgroundColor = [UIColor whiteColor];
	self.myWebView.scalesPageToFit = NO;
	self.myWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.myWebView.delegate = self;
	[self.view addSubview: self.myWebView];
	NSString *imagePath = [[NSBundle mainBundle] resourcePath];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"intro" ofType:@"html"];
	NSData *htmlData = [NSData dataWithContentsOfFile:htmlFile];
	[myWebView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" 	baseURL:[NSURL URLWithString: [NSString stringWithFormat:@"file:/%@//",imagePath]]];
	*/
}


- (IBAction) doneIntro:(id)sender {
	[self.delegate introViewControllerDidFinish:self];
	//NSLog(@"Done pressed on the introViewController");
}


- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
}


- (void) viewDidUnload {
}


- (void) dealloc {
	[super dealloc];
}


@end
