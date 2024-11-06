//
//  MyTubeAppDelegate.h
//  MyTube
//
//  Created by Harrison White on 2/18/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>
#import <AVFoundation/AVFoundation.h>
#import <Twitter/Twitter.h>
#import "DataLoader.h"
#import "HUDView.h"
#import "GADBannerView.h"

#import "FBConnect.h"
#import "SA_OAuthTwitterController.h"

@class ContainerViewController;
@class DataLoader;
@class HUDView;

@class Facebook;
@class SA_OAuthTwitterEngine;

#define kAdDidLoadNotification		@"kAdDidLoadNotification"
#define kAdDidFailLoadNotification	@"kAdDidFailLoadNotification"

#define kCountryCodesArray	[NSArray arrayWithObjects:@"US", @"AR", @"AU", @"BR", @"CA", @"CZ", @"FR", @"DE", @"GB", @"HK", @"IN", @"IE", @"IL", @"IT", @"JP", @"MX", @"NL", @"NZ", @"PL", @"RU", @"ZA", @"KR", @"ES", @"SE", @"TW", /* @"US", */ nil]
#define kLanguageCodesArray	[NSArray arrayWithObjects:@"en", @"fr", @"de", @"ja", @"nl", @"it", @"es", @"pt", /* @"\"pt-PT\"", */ @"da", @"fi", @"nb", @"sv", @"ko", /* @"\"zh-Hans\"", */ @"zh-Hans", /* @"\"zh-Hant\"", */ @"zh-Hant", @"ru", @"pl", @"tr", @"uk", @"ar", @"hr", @"cs", @"el", @"he", @"ro", @"sk", @"th", @"id", @"ms", /* @"\"en-GB\"", */ @"ca", @"hu", @"vi", nil]

// DOWNLOAD CODE

#import "DownloadCell.h"
#import "MetadataLoader.h"

#define UPDATE_INTERVAL 0.75

enum {
	kDownloadStateInProgress = 0,
	kDownloadStatePending,
	kDownloadStateCanceled,
	kDownloadStateFailed
};
typedef NSUInteger kDownloadState;

@class Video;
@class NetworkStatusChangeNotifier;

// END DOWNLOAD CODE

@interface MyTubeAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, FBSessionDelegate, FBDialogDelegate, SA_OAuthTwitterControllerDelegate /* DOWNLOAD CODE */, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, DataLoaderDelegate, HUDViewDelegate, GADBannerViewDelegate> {
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
    IBOutlet UIWindow *window;
	IBOutlet ContainerViewController *rootViewController;
    IBOutlet UITabBarController *theTabBarController;
	UIView *bannerViewContainer;
	GADBannerView *bannerView;
	NSMutableDictionary *tabBarItemIndexDictionary;
	NSInteger selectedTabBarItemIndex;
	NSString *pendingVideoTitle;
	NSString *pendingVideoID;
	
	NetworkStatusChangeNotifier *networkStatusChangeNotifier;
	
	Facebook *facebook;
	SA_OAuthTwitterEngine *twitterEngine;
	BOOL pendingTwitterPostRequest;
	NSString *pendingTweet;
	
	// DOWNLOAD CODE
	
	NSFetchedResultsController *fetchedResultsController;
	NSFetchedResultsController *downloadFetchedResultsController;
	
	NSInteger downloadsTabIndex;
	UITableView *theTableView;
	NSManagedObject *currentDownload;
	NSURLConnection *currentConnection;
	NSMutableData *receivedData;
	NSUInteger currentFileSize;
	NSFileHandle *currentFileHandle;
	NSTimer *downloadUpdateTimer;
	NSIndexPath *pendingIndexPath;
	UIActionSheet *cancelActionSheet;
	NSDecimalNumberHandler *decimalNumberHandler;
	DataLoader *dataLoader;
	HUDView *hud;
	BOOL massOperationInProgress;
	BOOL cannotConnectAlertShown;
	BOOL viewIsVisible;
	BOOL didLoadAd;
	BOOL isRunningInBackground;
	
	// END DOWNLOAD CODE
	
	UIBackgroundTaskIdentifier backgroundTask;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ContainerViewController *rootViewController;
@property (nonatomic, retain) IBOutlet UITabBarController *theTabBarController;
@property (nonatomic, assign) UIView *bannerViewContainer;
@property (nonatomic, assign) GADBannerView *bannerView;
@property (nonatomic, assign) NSMutableDictionary *tabBarItemIndexDictionary;
@property (nonatomic) NSInteger selectedTabBarItemIndex;
@property (nonatomic, assign) NSString *pendingVideoTitle;
@property (nonatomic, assign) NSString *pendingVideoID;

@property (nonatomic, assign) NetworkStatusChangeNotifier *networkStatusChangeNotifier;

@property (nonatomic, assign) Facebook *facebook;
@property (nonatomic, assign) SA_OAuthTwitterEngine *twitterEngine;
@property (readwrite) BOOL pendingTwitterPostRequest;
@property (nonatomic, assign) NSString *pendingTweet;

// DOWNLOAD CODE

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *downloadFetchedResultsController;

@property (nonatomic) NSInteger downloadsTabIndex;
@property (nonatomic, assign) UITableView *theTableView;
@property (nonatomic, assign) NSManagedObject *currentDownload;
@property (nonatomic, assign) NSURLConnection *currentConnection;
@property (nonatomic, assign) NSMutableData *receivedData;
@property (nonatomic) NSUInteger currentFileSize;
@property (nonatomic, assign) NSFileHandle *currentFileHandle;
@property (nonatomic, assign) NSTimer *downloadUpdateTimer;
@property (nonatomic, assign) NSIndexPath *pendingIndexPath;
@property (nonatomic, assign) UIActionSheet *cancelActionSheet;
@property (nonatomic, assign) NSDecimalNumberHandler *decimalNumberHandler;
@property (nonatomic, assign) DataLoader *dataLoader;
@property (nonatomic, assign) HUDView *hud;
@property (readwrite) BOOL massOperationInProgress;
@property (readwrite) BOOL cannotConnectAlertShown;
@property (readwrite) BOOL viewIsVisible;
@property (readwrite) BOOL didLoadAd;
@property (readwrite) BOOL isRunningInBackground;

// END DOWNLOAD CODE

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

- (void)loadRequest;
- (void)showBannerViewIfApplicable;
- (void)presentOptionsActionSheetForVideoWithID:(NSString *)videoID title:(NSString *)title;
- (void)emailVideo;
- (void)presentMailComposeControllerWithSubject:(NSString *)subject message:(NSString *)message;
- (void)displayCannotSendMailAlert;
- (NSFetchedResultsController *)downloadFetchedResultsController;
- (NSString *)applicationDataStorageDirectory;
- (void)displayCannotConnectAlert:(BOOL)passive;
- (void)presentTwitterViewWithMessage:(NSString *)message;
- (NSString *)applicationDataStorageDirectory;
- (NSString *)applicationDocumentsDirectory;
- (void)clearCache;
- (void)resumeVideoPlayback;
- (void)_resumeVideoPlayback;
- (void)abortWithError:(NSError *)error;

// DOWNLOAD CODE

- (void)actionBarButtonItemPressed;

- (void)fetchDownloads;
- (void)updateCurrentDownload;
- (void)scheduleDownloadUpdateTimer;
- (void)downloadDidFinish;
- (void)connectionDidFail;
- (void)downloadDidFail:(NSManagedObject *)download;
- (void)updateDownloads;
- (NSString *)stringFromDecimalNumber:(NSDecimalNumber *)decimalNumber;
- (void)configureCell:(DownloadCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)downloadVideo:(Video *)video atURL:(NSString *)url quality:(kVideoDefinition)quality;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)didRemoveDownloadAtIndexPath:(NSIndexPath *)indexPath;
- (void)didCancelDownloadAtIndexPath:(NSIndexPath *)indexPath;
- (void)didRestartDownloadAtIndexPath:(NSIndexPath *)indexPath;
- (void)fileCheckSucceeded;
- (void)fileCheckDidFail;
- (void)hideHUD;

// END DOWNLOAD CODE

@end
