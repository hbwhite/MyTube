//
//  SettingsViewController.h
//  MyTube
//
//  Created by Harrison White on 3/20/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewController.h"
#import "FBConnect.h"

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, ListViewControllerDelegate, FBDialogDelegate> {
	IBOutlet UITableView *theTableView;
	NSString *countryTitle;
	NSString *languageTitle;
    NSInteger localizationSelectedRow;
	BOOL isAdObserver;
}

@property (nonatomic, assign) IBOutlet UITableView *theTableView;
@property (nonatomic, assign) NSString *countryTitle;
@property (nonatomic, assign) NSString *languageTitle;
@property (nonatomic) NSInteger localizationSelectedRow;
@property (readwrite) BOOL isAdObserver;

- (void)adDidLoad;
- (void)adDidFailLoad;
- (void)switchValueChanged:(id)sender;

@end
