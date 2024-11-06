//
//  DownloadsViewController.h
//  MyTube
//
//  Created by Harrison White on 2/18/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyTubeAppDelegate;

@interface DownloadsViewController : UIViewController {
	IBOutlet UIBarButtonItem *actionBarButtonItem;
	UITableView *theTableView;
	MyTubeAppDelegate *delegate;
	BOOL isAdObserver;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionBarButtonItem;
@property (nonatomic, assign) UITableView *theTableView;
@property (nonatomic, assign) MyTubeAppDelegate *delegate;
@property (readwrite) BOOL isAdObserver;

- (IBAction)actionBarButtonItemPressed;
- (void)adDidLoad;
- (void)adDidFailLoad;

@end
