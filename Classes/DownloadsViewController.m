//
//  DownloadsViewController.m
//  MyTube
//
//  Created by Harrison White on 2/18/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "DownloadsViewController.h"
#import "MyTubeAppDelegate.h"

@implementation DownloadsViewController

@synthesize actionBarButtonItem;
@synthesize theTableView;
@synthesize delegate;
@synthesize isAdObserver;

#pragma mark -
#pragma mark View lifecycle

- (IBAction)actionBarButtonItemPressed {
	[delegate actionBarButtonItemPressed];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	delegate = (MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate];
	[self.view addSubview:delegate.theTableView];
	
	theTableView = delegate.theTableView;
}

- (void)adDidLoad {
	theTableView.frame = CGRectMake(0, 0, 320, 317);
}

- (void)adDidFailLoad {
	theTableView.frame = CGRectMake(0, 0, 320, 367);
}

- (void)viewWillAppear:(BOOL)animated {
	[delegate scheduleDownloadUpdateTimer];
	if (!delegate.viewIsVisible) {
		delegate.viewIsVisible = YES;
	}
	
	if (!isAdObserver) {
		isAdObserver = YES;
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(adDidLoad) name:kAdDidLoadNotification object:nil];
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(adDidFailLoad) name:kAdDidFailLoadNotification object:nil];
		if (![[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]bannerViewContainer]isHidden]) {
			[self adDidLoad];
		}
	}
	[super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/

- (void)viewDidDisappear:(BOOL)animated {
	if (delegate.downloadUpdateTimer) {
		[delegate.downloadUpdateTimer invalidate];
		delegate.downloadUpdateTimer = nil;
	}
	if (delegate.viewIsVisible) {
		delegate.viewIsVisible = NO;
	}
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	// For example: self.myOutlet = nil;
	
	self.actionBarButtonItem = nil;
}


- (void)dealloc {
	[actionBarButtonItem release];
	[super dealloc];
}


@end

