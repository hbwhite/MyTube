//
//  SearchViewController.h
//  MyTube
//
//  Created by Harrison White on 4/3/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchMask.h"
#import "VideoFetcher.h"
#import "ThumbnailLoader.h"
#import "DataLoader.h"
#import "HUDView.h"
#import "ContainerViewController.h"

@class SearchMask;
@class VideoFetcher;
@class DataLoader;
@class NetworkStatusChangeNotifier;
@class Video;
@class VideoCell;
@class LoadMoreCell;
@class HUDView;

enum {
	kSearchModeNone,
	kSearchModeSearch,
	kSearchModeTimeOrder
};
typedef NSUInteger kSearchMode;

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SearchMaskDelegate, VideoFetcherDelegate, ThumbnailLoaderDelegate, DataLoaderDelegate, HUDViewDelegate, ContainerViewControllerDelegate, UIActionSheetDelegate> {
	IBOutlet UIView *placeholderView;
	IBOutlet UIActivityIndicatorView *maskActivityIndicator;
	IBOutlet UILabel *maskLabel;
	IBOutlet UIView *containerView;
	IBOutlet UISearchBar *theSearchBar;
	IBOutlet UISegmentedControl *timeSelectSegmentedControl;
    IBOutlet UITableView *theTableView;
	IBOutlet SearchMask *searchMask;
	NSOperationQueue *thumbnailLoadQueue;
	VideoFetcher *currentVideoFetcher;
	DataLoader *dataLoader;
	NetworkStatusChangeNotifier *networkStatusChangeNotifier;
	NSMutableArray *results;
	NSMutableArray *thumbnailFetchArray;
	HUDView *hud;
	NSIndexPath *pendingIndexPath;
	NSMutableArray *pendingQualityOptions;
	NSInteger pendingButtonIndex;
	LoadMoreCell *loadMoreCell;
	kSearchMode searchMode;
	BOOL noAdditionalVideos;
	BOOL contentIsPresent;
	// BOOL viewDidAppear;
	BOOL isAdObserver;
}

@property (nonatomic, retain) IBOutlet UIView *placeholderView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *maskActivityIndicator;
@property (nonatomic, retain) IBOutlet UILabel *maskLabel;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UISearchBar *theSearchBar;
@property (nonatomic, retain) IBOutlet UISegmentedControl *timeSelectSegmentedControl;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) IBOutlet SearchMask *searchMask;
@property (nonatomic, assign) NSOperationQueue *thumbnailLoadQueue;
@property (nonatomic, assign) VideoFetcher *currentVideoFetcher;
@property (nonatomic, assign) DataLoader *dataLoader;
@property (nonatomic, assign) NetworkStatusChangeNotifier *networkStatusChangeNotifier;
@property (nonatomic, assign) Video *currentVideo;
@property (nonatomic, assign) NSMutableArray *results;
@property (nonatomic, assign) NSMutableArray *thumbnailFetchArray;
@property (nonatomic, assign) HUDView *hud;
@property (nonatomic, assign) NSIndexPath *pendingIndexPath;
@property (nonatomic, assign) NSMutableArray *pendingQualityOptions;
@property (nonatomic, assign) NSInteger pendingButtonIndex;
@property (nonatomic, assign) LoadMoreCell *loadMoreCell;
@property (nonatomic) kSearchMode searchMode;
@property (readwrite) BOOL noAdditionalVideos;
@property (readwrite) BOOL contentIsPresent;
// @property (readwrite) BOOL viewDidAppear;
@property (readwrite) BOOL isAdObserver;

- (IBAction)timeSelectSegmentedControlValueChanged;

- (BOOL)viewIsVisible;
- (void)fadeInMask;
- (void)fadeOutMask;
- (void)showNoVideosMask;
- (void)searchWithQuery:(NSString *)query;
- (NSString *)feedPrefix;
- (NSString *)categoryURL;
- (NSString *)mutualFeedSuffix;
- (void)fetchVideosForQuery:(NSString *)query;
- (void)_fetchVideosWithFeedURL:(NSString *)url;
- (void)networkStatusDidChange:(NSNotification *)notification;
- (void)adDidLoad;
- (void)adDidFailLoad;
- (void)loadResults;
- (void)clearResults;
- (void)clearCache;
- (void)_clearCache;
- (void)hideHUDAnimated:(BOOL)animated;
- (void)processMetadataForVideo:(Video *)video;
- (void)processVideo:(Video *)video isDownload:(BOOL)isDownload quality:(kVideoDefinition)quality;

@end
