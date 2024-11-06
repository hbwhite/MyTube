//
//  TwitterPostViewController.m
//  MyTube
//
//  Created by Harrison White on 5/30/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "TwitterPostViewController.h"
#import "MyTubeAppDelegate.h"
#import "SA_OAuthTwitterEngine.h"
#import "NetworkStatusChangeNotifier.h"

#define MAXIMUM_CHARACTER_COUNT 140

static NSString *kIntegerFormatSpecifierStr		= @"%i";
static NSString *kNegativeCharactersPrefixStr	= @"-";

@implementation TwitterPostViewController

@synthesize cancelButton;
@synthesize postButton;
@synthesize postTextView;
@synthesize charactersRemainingLabel;
@synthesize message;

- (IBAction)cancelButtonPressed {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)postButtonPressed {
	[self postTweet];
}

- (void)postTweet {
	if ([postTextView.text length] > 0) {
		if ([postTextView.text length] > MAXIMUM_CHARACTER_COUNT) {
			UIAlertView *tweetExceedsLimitAlert = [[UIAlertView alloc]
												   initWithTitle:@"Cannot Post Tweet"
												   message:[NSString stringWithFormat:@"This tweet exceeds Twitter's limit of %i characters. Please shorten your message and try again.", MAXIMUM_CHARACTER_COUNT]
												   delegate:nil
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			[tweetExceedsLimitAlert show];
			[tweetExceedsLimitAlert release];
		}
		else {
			if ([[NetworkStatusChangeNotifier defaultNotifier]currentNetworkStatus] == kNetworkStatusNotConnected) {
				UIAlertView *cannotConnectAlert = [[UIAlertView alloc]
												   initWithTitle:@"Cannot Connect to Twitter"
												   message:@"Please check your Internet connection status and try again."
												   delegate:nil
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
				[cannotConnectAlert show];
				[cannotConnectAlert release];
			}
			else {
				[(SA_OAuthTwitterEngine *)[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]twitterEngine]sendUpdate:postTextView.text];
				[self.parentViewController dismissModalViewControllerAnimated:YES];
			}
		}
	}
	else {
		UIAlertView *nullTweetAlert = [[UIAlertView alloc]
										initWithTitle:@"No Text Entered"
										message:@"You must enter text in order to post a tweet."
										delegate:nil
										cancelButtonTitle:@"OK"
										otherButtonTitles:nil];
		[nullTweetAlert show];
		[nullTweetAlert release];
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)textViewDidChange:(UITextView *)textView {
	[self updateCharactersRemainingLabel];
}

- (void)updateCharactersRemainingLabel {
	if ([postTextView.text length] > 0) {
		postButton.enabled = YES;
	}
	else {
		postButton.enabled = NO;
	}
	if ([postTextView.text length] > MAXIMUM_CHARACTER_COUNT) {
		// charactersRemainingLabel.textColor = [UIColor colorWithRed:0.75 green:0 blue:0 alpha:1];
		charactersRemainingLabel.text = [NSString stringWithFormat:[kNegativeCharactersPrefixStr stringByAppendingString:kIntegerFormatSpecifierStr], ([postTextView.text length] - MAXIMUM_CHARACTER_COUNT)];
	}
	else {
		// charactersRemainingLabel.textColor = [UIColor colorWithRed:0 green:0.35 blue:0 alpha:1];
		charactersRemainingLabel.text = [NSString stringWithFormat:kIntegerFormatSpecifierStr, (MAXIMUM_CHARACTER_COUNT - [postTextView.text length])];
	}
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	postTextView.text = message;
	[self updateCharactersRemainingLabel];
	[postTextView becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.cancelButton = nil;
	self.postButton = nil;
	self.postTextView = nil;
	self.charactersRemainingLabel = nil;
}

- (void)dealloc {
	[cancelButton release];
	[postButton release];
	[postTextView release];
	[charactersRemainingLabel release];
    [super dealloc];
}

@end
