//
//  FlipsideViewController.m
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

#import "FlipsideViewController.h"


@implementation FlipsideViewController

@synthesize delegate;
@synthesize myWebView;


NSURL *URL;
- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	
	CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
	webFrame.origin.y = 88.0;
	webFrame.size.height = 400.0;
	webFrame.size.width =  320.0;
	if (IS_IPHONE_5)
	{
		int iphone5heightaddition = 176;
		webFrame.size.height += iphone5heightaddition;
	}
	self.myWebView = [[UIWebView alloc] initWithFrame:webFrame];
	self.myWebView.backgroundColor = [UIColor whiteColor];
	self.myWebView.scalesPageToFit = NO;
	//self.myWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

	self.myWebView.delegate = self;
	[self.view addSubview: self.myWebView];
	NSString *imagePath = [[NSBundle mainBundle] resourcePath];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"credits" ofType:@"html"];
	NSData *htmlData = [NSData dataWithContentsOfFile:htmlFile];
	[myWebView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" 	baseURL:[NSURL URLWithString: [NSString stringWithFormat:@"file:/%@//",imagePath]]];
}

//Handle user clicks on the links on this page.
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
		URL = [request URL];	
		if ([[URL scheme] isEqualToString:@"http"] || [[URL scheme] isEqualToString:@"https"] )
		{
			
			UIActionSheet *sheet =
			[[UIActionSheet alloc] initWithTitle:@"Visit this website in Safari?"
                                        delegate:self
                               cancelButtonTitle:@"No Thanks"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"Yes",
			 nil];
			[sheet showInView:self.view];

		}	 
		return NO;
	}	
	return YES;   
}

//Launch the specifcied URL in Safari if the user selects to do so.
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex)
	{
		case 0:
		{
			[[UIApplication sharedApplication] openURL:URL];
		} break;
		default:
			break;
	}
}

- (IBAction)done:(id)sender
{
	[self.delegate flipsideViewControllerDidFinish:self];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
 {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 //return YES;
 }
 */

@end