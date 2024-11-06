//
//  AboutViewController.h
//  MyTube
//
//  Created by Harrison White on 5/9/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UITableView *theTableView;
	BOOL isAdObserver;
}

@property (nonatomic, assign) IBOutlet UITableView *theTableView;
@property (readwrite) BOOL isAdObserver;

- (void)adDidLoad;
- (void)adDidFailLoad;

@end
