//
//  VideosViewController.h
//  MyTube
//
//  Created by Harrison White on 3/2/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ContainerViewController.h"
#import "DownloadedVideoCell.h"

@interface VideosViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UIActionSheetDelegate, ContainerViewControllerDelegate> {
	IBOutlet UITableView *theTableView;
	UIBarButtonItem *editButton;
	NSManagedObject *pendingVideo;
	BOOL searching;
	BOOL viewIsVisible;
	BOOL isAdObserver;
	
	NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

@end
