//
//  SearchViewController.m
//  MyTube
//
//  Created by Harrison White on 4/3/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "SearchViewController.h"
#import "MyTubeAppDelegate.h"
#import "MetadataLoader.h"
#import "Video.h"
#import "VideoCell.h"
#import "LoadMoreCell.h"
#import "ContainerViewController.h"
#import "NetworkStatusChangeNotifier.h"

#define THUMB_UP_COLOR_RED											(50.0 / 255.0)
#define THUMB_UP_COLOR_GREEN										(130.0 / 255.0)
#define THUMB_UP_COLOR_BLUE											0

#define THUMB_DOWN_COLOR_RED										(180.0 / 255.0)
#define THUMB_DOWN_COLOR_GREEN										0.1372549
#define THUMB_DOWN_COLOR_BLUE										(15.0 / 255.0)

#define LOAD_MORE_COLOR_RED											(41.0 / 255.0)
#define LOAD_MORE_COLOR_GREEN										(96.0 / 255.0)
#define LOAD_MORE_COLOR_BLUE										(217.0 / 255.0)

#define ROW_HEIGHT													90
#define MINIMUM_RATING_COUNT										1
#define SEARCH_MASK_MAX_ALPHA										0.8
#define SEARCH_MASK_FADE_DURATION									0.25
#define VIDEO_BATCH_SIZE											25

#define MAX_CONCURRENT_OPERATION_COUNT								6

#define FEATURED_TAG												0
#define SEARCH_TAG													1
#define TOP_RATED_TAG												4
#define MOST_VIEWED_TAG												5
#define MOST_RECENT_TAG												6

#define TODAY_FILTER_INDEX											0
#define THIS_WEEK_FILTER_INDEX										1
#define ALL_FILTER_INDEX											2

#define DESKTOP_INDEX												0
#define MOBILE_INDEX												1

#define BEST_QUALITY_INDEX											0
#define STANDARD_DEFINITION_INDEX									1

static NSString *kFeedPrefixPrefixStr								= @"http://gdata.youtube.com/feeds/";
static NSString *kFeedPrefixDesktopSuffixStr						= @"api";
static NSString *kFeedPrefixMobileSuffixStr							= @"mobile";
static NSString *kCategoryPrefixStr									= @"standardfeeds";

static NSString *kSearchFeedStr										= @"videos?q=%@&orderby=relevance&";
static NSString *kFeaturedFeedStr									= @"recently_featured?";
static NSString *kTopRatedFeedStr									= @"top_rated?";
static NSString *kMostViewedFeedStr									= @"most_viewed?";
static NSString *kMostRecentFeedStr									= @"most_recent?";
static NSString *kFeedSuffixStr										= @"start-index=%i&max-results=25%@%@&format=6";
static NSString *kResultFilterSuffix								= @"&time=%@";

static NSString *kNullStr											= @"";

static NSString *kLatestQueryKey									= @"Latest Query";
static NSString *kTopRatedTimeIndexKey								= @"Top Rated Time Index";
static NSString *kMostViewedTimeIndexKey							= @"Most Viewed Time Index";
static NSString *kCountryCodeKey									= @"Country Code";
static NSString *kLanguageCodeKey									= @"Language Code";

static NSString *kTodayFilterStr									= @"today";
static NSString *kThisWeekFilterStr									= @"this_week";
static NSString *kAllFilterStr										= @"all_time";

static NSString *kThumbnailPlaceholderImageTitleStr					= @"Thumbnail-Placeholder";
static NSString *kThumbUpImageNameStr								= @"Thumb-Up";
static NSString *kThumbUpSelectedImageNameStr						= @"Thumb-Up-Selected";
static NSString *kThumbDownImageNameStr								= @"Thumb-Down";
static NSString *kThumbDownSelectedImageNameStr						= @"Thumb-Down-Selected";
static NSString *kPercentRatingStr									= @"%i%%";
static NSString *kViewCountStr										= @"%i view%@";

static NSString *kWebsiteSegmentedControlSelectedSegmentIndexKey	= @"Website Segmented Control Selected Segment Index";

static NSString *kQualitySettingsSection1SelectedRowStr				= @"Quality Settings Section 1 Selected Row";
static NSString *kQualitySettingsSection2SelectedRowStr				= @"Quality Settings Section 2 Selected Row";

static NSString *kSpaceStr											= @" ";
static NSString *kSpaceReplacementStr								= @"+";

static NSString *kLoadingStr										= @"Loading...";
static NSString *kLoadMoreStr										= @"Load More...";
static NSString *kNoVideosStr										= @"No Videos";

static NSString *kHUDTitleStr										= @"Loading...";
static NSString *kHUDProcessingSubtitleStr							= @"Tap to Cancel";
static NSString *kHUDCanceledSubtitleStr							= @"Canceled.";

@implementation SearchViewController

@synthesize placeholderView;
@synthesize maskActivityIndicator;
@synthesize maskLabel;
@synthesize containerView;
@synthesize theSearchBar;
@synthesize timeSelectSegmentedControl;
@synthesize theTableView;
@synthesize searchMask;
@synthesize thumbnailLoadQueue;
@synthesize currentVideoFetcher;
@synthesize dataLoader;
@synthesize networkStatusChangeNotifier;
@synthesize currentVideo;
@synthesize results;
@synthesize thumbnailFetchArray;
@synthesize hud;
@synthesize pendingIndexPath;
@synthesize pendingQualityOptions;
@synthesize pendingButtonIndex;
@synthesize loadMoreCell;
@synthesize searchMode;
@synthesize noAdditionalVideos;
@synthesize contentIsPresent;
// @synthesize viewDidAppear;
@synthesize isAdObserver;

#pragma mark - View lifecycle

- (IBAction)timeSelectSegmentedControlValueChanged {
	if (placeholderView.hidden) {
		placeholderView.hidden = NO;
	}
	
	NSInteger tag = self.tabBarItem.tag;
	NSString *key = nil;
	if (tag == TOP_RATED_TAG) {
		key = kTopRatedTimeIndexKey;
	}
	else {
		key = kMostViewedTimeIndexKey;
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:timeSelectSegmentedControl.selectedSegmentIndex forKey:key];
	[defaults synchronize];
	
	MyTubeAppDelegate *delegate = (MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate];
	if (delegate.cannotConnectAlertShown) {
		delegate.cannotConnectAlertShown = NO;
	}
	
	[self loadResults];
}

- (BOOL)viewIsVisible {
	return [[((UINavigationController *)self.tabBarController.selectedViewController) topViewController]isEqual:self];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	if (searchMask.alpha > 0) {
		searchMask.alpha = 0;
	}
	[self fadeInMask];
}

- (void)fadeInMask {
	[UIView beginAnimations:@"Fade In" context:nil];
	[UIView setAnimationDuration:SEARCH_MASK_FADE_DURATION];
	searchMask.alpha = SEARCH_MASK_MAX_ALPHA;
	[UIView commitAnimations];
}

- (void)fadeOutMask {
	[UIView beginAnimations:@"Fade Out" context:nil];
	[UIView setAnimationDuration:SEARCH_MASK_FADE_DURATION];
	searchMask.alpha = 0;
	[UIView commitAnimations];
}

- (void)searchMaskTouchesBegan {
	[theSearchBar resignFirstResponder];
	if ([theSearchBar.text length] <= 0) {
		[[NSUserDefaults standardUserDefaults]setObject:kNullStr forKey:kLatestQueryKey];
	}
	[self fadeOutMask];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self showNoVideosMask];
	/*
	if (theTableView.contentOffset.y != 0) {
		[theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	}
	*/
}

- (void)showNoVideosMask {
	if ([[UIApplication sharedApplication]isNetworkActivityIndicatorVisible]) {
		[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
	}
	if (!maskActivityIndicator.hidden) {
		maskActivityIndicator.hidden = YES;
		[maskActivityIndicator stopAnimating];
	}
	if (maskLabel.frame.origin.x != 115) {
		maskLabel.frame = CGRectMake(115, 174, 90, 20);
	}
	if (![maskLabel.text isEqualToString:kNoVideosStr]) {
		maskLabel.text = kNoVideosStr;
	}
	if (placeholderView.hidden) {
		placeholderView.hidden = NO;
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([searchBar.text length] > 0) {
		[defaults setObject:searchBar.text forKey:kLatestQueryKey];
		[self searchWithQuery:searchBar.text];
	}
	else {
		[defaults setObject:kNullStr forKey:kLatestQueryKey];
	}
	[defaults synchronize];
}

- (void)searchWithQuery:(NSString *)query {
	if (![[UIApplication sharedApplication]isNetworkActivityIndicatorVisible]) {
		[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
	}
	if (!placeholderView.hidden) {
		placeholderView.hidden = YES;
	}
	if (![maskActivityIndicator isAnimating]) {
		[maskActivityIndicator startAnimating];
	}
	if (maskActivityIndicator.hidden) {
		maskActivityIndicator.hidden = NO;
	}
	if (maskLabel.frame.origin.x != 125) {
		maskLabel.frame = CGRectMake(125, 174, 90, 20);
	}
	if (![maskLabel.text isEqualToString:kLoadingStr]) {
		maskLabel.text = kLoadingStr;
	}
	if (placeholderView.hidden) {
		placeholderView.hidden = NO;
	}
	if (theTableView.contentOffset.y != 0) {
		[theTableView setContentOffset:CGPointMake(0, 0) animated:NO];
	}
	[results removeAllObjects];
	[thumbnailLoadQueue cancelAllOperations];
	[thumbnailFetchArray removeAllObjects];
	[self fetchVideosForQuery:query];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	[self fadeOutMask];
}

- (NSString *)feedPrefix {
	NSMutableString *feedPrefix = [NSMutableString stringWithString:kFeedPrefixPrefixStr];
	if ([[NSUserDefaults standardUserDefaults]integerForKey:kWebsiteSegmentedControlSelectedSegmentIndexKey] == DESKTOP_INDEX) {
		[feedPrefix appendString:kFeedPrefixDesktopSuffixStr];
	}
	else {
		[feedPrefix appendString:kFeedPrefixMobileSuffixStr];
	}
	return [NSString stringWithString:feedPrefix];
}

- (NSString *)categoryURL {
	NSString *countryCode = [[NSUserDefaults standardUserDefaults]objectForKey:kCountryCodeKey];
	if ([countryCode length] > 0) {
		return [[self feedPrefix]stringByAppendingPathComponent:[kCategoryPrefixStr stringByAppendingPathComponent:countryCode]];
	}
	else {
		return [[self feedPrefix]stringByAppendingPathComponent:kCategoryPrefixStr];
	}
}

- (NSString *)mutualFeedSuffix {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger startIndex = ([results count] + 1);
	NSMutableString *countryRestrictions = [NSMutableString stringWithString:[defaults objectForKey:kCountryCodeKey]];
	if ([countryRestrictions length] > 0) {
		[countryRestrictions setString:[@"&restriction=" stringByAppendingString:countryRestrictions]];
	}
	NSMutableString *languageRestrictions = [NSMutableString stringWithString:[defaults objectForKey:kLanguageCodeKey]];
	if ([languageRestrictions length] > 0) {
		[languageRestrictions setString:[@"&lr=" stringByAppendingString:languageRestrictions]];
	}
	return [NSString stringWithFormat:kFeedSuffixStr, startIndex, countryRestrictions, languageRestrictions];
}

- (void)fetchVideosForQuery:(NSString *)query {
	// [NSThread cancelPreviousPerformRequestsWithTarget:self];
	NSInteger tag = self.tabBarItem.tag;
	NSMutableString *feedURL = [[NSMutableString alloc]init];
	if (tag == SEARCH_TAG) {
		[feedURL setString:[[self feedPrefix]stringByAppendingPathComponent:[NSString stringWithFormat:[kSearchFeedStr stringByAppendingString:[self mutualFeedSuffix]], [[query stringByReplacingOccurrencesOfString:kSpaceStr withString:kSpaceReplacementStr]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
	}
	else if (tag == FEATURED_TAG) {
		[feedURL setString:[[self categoryURL]stringByAppendingPathComponent:[kFeaturedFeedStr stringByAppendingString:[self mutualFeedSuffix]]]];
	}
	else if ((tag == TOP_RATED_TAG) || (tag == MOST_VIEWED_TAG)) {
		NSString *resultFilter = nil;
		switch (timeSelectSegmentedControl.selectedSegmentIndex) {
			case TODAY_FILTER_INDEX:
				resultFilter = kTodayFilterStr;
				break;
			case THIS_WEEK_FILTER_INDEX:
				resultFilter = kThisWeekFilterStr;
				break;
			case ALL_FILTER_INDEX:
				resultFilter = kAllFilterStr;
				break;
		}
		if (tag == TOP_RATED_TAG) {
			[feedURL setString:[[self categoryURL]stringByAppendingPathComponent:[NSString stringWithFormat:[[kTopRatedFeedStr stringByAppendingString:[self mutualFeedSuffix]]stringByAppendingString:kResultFilterSuffix], resultFilter]]];
		}
		else if (tag == MOST_VIEWED_TAG) {
			[feedURL setString:[[self categoryURL]stringByAppendingPathComponent:[NSString stringWithFormat:[[kMostViewedFeedStr stringByAppendingString:[self mutualFeedSuffix]]stringByAppendingString:kResultFilterSuffix], resultFilter]]];
		}
	}
	else if (tag == MOST_RECENT_TAG) {
		[feedURL setString:[[self categoryURL]stringByAppendingPathComponent:[kMostRecentFeedStr stringByAppendingString:[self mutualFeedSuffix]]]];
	}
	// NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
	// [mainQueue cancelAllOperations];
	// [mainQueue addOperationWithBlock:^{
	//	[mainQueue cancelAllOperations];
		[self performSelectorInBackground:@selector(_fetchVideosWithFeedURL:) withObject:feedURL];
	// }];
	[feedURL release];
}

- (void)_fetchVideosWithFeedURL:(NSString *)url {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	if (currentVideoFetcher) {
		if ([currentVideoFetcher respondsToSelector:@selector(setDelegate:)]) {
			[currentVideoFetcher setDelegate:nil];
		}
		if ([currentVideoFetcher respondsToSelector:@selector(cancel)]) {
			[currentVideoFetcher cancel];
		}
	}
	VideoFetcher *videoFetcher = [[VideoFetcher alloc]init];
	currentVideoFetcher = videoFetcher;
	[videoFetcher setDelegate:self];
	[videoFetcher fetchVideosWithFeedURL:url startingAtIndex:[results count]];
	[videoFetcher release];
	[pool release];
}

- (void)videoFetcher:(VideoFetcher *)videoFetcher didLoadVideos:(NSArray *)videos error:(NSError *)error {
	if ([videoFetcher isEqual:currentVideoFetcher]) {
		currentVideoFetcher = nil;
		// dispatch_queue_t mainQueue = dispatch_get_main_queue();
		// dispatch_async(mainQueue, ^{
			if (loadMoreCell) {
				loadMoreCell.loadMoreLabel.text = kLoadMoreStr;
				loadMoreCell.loadMoreLabel.textColor = [UIColor colorWithRed:LOAD_MORE_COLOR_RED green:LOAD_MORE_COLOR_GREEN blue:LOAD_MORE_COLOR_BLUE alpha:1];
				loadMoreCell.loadMoreActivityIndicator.hidden = YES;
				[loadMoreCell.loadMoreActivityIndicator stopAnimating];
				loadMoreCell = nil;
			}
			if ([[UIApplication sharedApplication]isNetworkActivityIndicatorVisible]) {
				[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
			}
			if ([maskActivityIndicator isAnimating]) {
				[maskActivityIndicator stopAnimating];
			}
			if (!placeholderView.hidden) {
				placeholderView.hidden = YES;
			}
			if ([videos count] > 0) {
				if (!error) {
					[results addObjectsFromArray:videos];
					[theTableView reloadData];
				}
			}
			else if ([results count] > 0) {
				noAdditionalVideos = YES;
			}
			else {
				[self showNoVideosMask];
			}
			if (error) {
				[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]displayCannotConnectAlert:YES];
			}
		// });
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	theTableView.rowHeight = ROW_HEIGHT;
	results = [[NSMutableArray alloc]init];
	thumbnailFetchArray = [[NSMutableArray alloc]init];
	pendingQualityOptions = [[NSMutableArray alloc]init];
	thumbnailLoadQueue = [[NSOperationQueue alloc]init];
	[thumbnailLoadQueue setMaxConcurrentOperationCount:MAX_CONCURRENT_OPERATION_COUNT];
	
	NSInteger tag = self.tabBarItem.tag;
	if (tag == SEARCH_TAG) {
		searchMode = kSearchModeSearch;
		NSString *latestQuery = [[NSUserDefaults standardUserDefaults]stringForKey:kLatestQueryKey];
		if ([latestQuery length] > 0) {
			theSearchBar.text = latestQuery;
		}
	}
	else if ((tag == TOP_RATED_TAG) || (tag == MOST_VIEWED_TAG)) {
		searchMode = kSearchModeTimeOrder;
		NSString *key = nil;
		if (tag == TOP_RATED_TAG) {
			key = kTopRatedTimeIndexKey;
		}
		else if (tag == MOST_VIEWED_TAG) {
			key = kMostViewedTimeIndexKey;
		}
		timeSelectSegmentedControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults]integerForKey:key];
	}
	else {
		searchMode = kSearchModeNone;
	}
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkStatusDidChange:) name:kNetworkStatusDidChangeNotification object:nil];
	networkStatusChangeNotifier = [[NetworkStatusChangeNotifier defaultNotifier]retain];
	[networkStatusChangeNotifier startNotifier];
}

- (void)adDidLoad {
	CGRect revisedFrame = CGRectMake(0, 0, 320, 317);
	theTableView.frame = revisedFrame;
	placeholderView.frame = revisedFrame;
	searchMask.frame = revisedFrame;
}

- (void)adDidFailLoad {
	CGRect originalFrame = CGRectMake(0, 0, 320, 367);
	theTableView.frame = originalFrame;
	placeholderView.frame = originalFrame;
	searchMask.frame = originalFrame;
}

- (void)networkStatusDidChange:(NSNotification *)notification {
	kNetworkStatus networkStatus = [networkStatusChangeNotifier currentNetworkStatus];
	if (networkStatus == kNetworkStatusNotConnected) {
		if ([self viewIsVisible]) {
			[self clearCache];
		}
		else {
			[self clearResults];
		}
	}
	else {
		if ([results count] > 0) {
			[theTableView reloadData];
		}
		else {
			[self loadResults];
		}
	}
}

- (void)loadResults {
	if (searchMode == kSearchModeSearch) {
		if ([theSearchBar.text length] > 0) {
			[self searchWithQuery:theSearchBar.text];
		}
	}
	else {
		[self searchWithQuery:nil];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	if (!isAdObserver) {
		isAdObserver = YES;
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(adDidLoad) name:kAdDidLoadNotification object:nil];
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(adDidFailLoad) name:kAdDidFailLoadNotification object:nil];
		if (![[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]bannerViewContainer]isHidden]) {
			[self adDidLoad];
		}
	}
	if (searchMode != kSearchModeNone) {
		if ([[[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]tabBarItemIndexDictionary]objectForKey:[NSNumber numberWithInteger:self.tabBarItem.tag]]integerValue] < 4) {
			if (containerView.frame.size.width != 309) {
				containerView.frame = CGRectMake(0, 0, 309, 44);
			}
			if (searchMode == kSearchModeTimeOrder) {
				CGRect frame = timeSelectSegmentedControl.frame;
				if (frame.size.width != 244) {
					frame.size.width = 244;
					timeSelectSegmentedControl.frame = frame;
				}
			}
		}
		else {
			if (containerView.frame.size.width != 245) {
				containerView.frame = CGRectMake(0, 0, 245, 44);
			}
			if (searchMode == kSearchModeTimeOrder) {
				CGRect frame = timeSelectSegmentedControl.frame;
				if (frame.size.width != 220) {
					frame.size.width = 220;
					timeSelectSegmentedControl.frame = frame;
				}
			}
		}
	}
	if ([results count] <= 0) {
		kNetworkStatus networkStatus = [networkStatusChangeNotifier currentNetworkStatus];
		if (networkStatus != kNetworkStatusNotConnected) {
			[self loadResults];
		}
	}
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	if ((searchMode == kSearchModeSearch) && ([theSearchBar isFirstResponder])) {
		[theSearchBar resignFirstResponder];
	}
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	kNetworkStatus networkStatus = [networkStatusChangeNotifier currentNetworkStatus];
	if (networkStatus == kNetworkStatusNotConnected) {
		[self clearResults];
	}
	else {
		[self clearCache];
	}
    [super viewDidDisappear:animated];
}

- (void)clearResults {
	[results removeAllObjects];
	[thumbnailLoadQueue cancelAllOperations];
	[thumbnailFetchArray removeAllObjects];
	if ([[UIApplication sharedApplication]isNetworkActivityIndicatorVisible]) {
		[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
	}
	[theTableView reloadData];
	[self showNoVideosMask];
}

- (void)clearCache {
	[self performSelectorInBackground:@selector(_clearCache) withObject:nil];
}

- (void)_clearCache {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	for (int i = 0; i < [results count]; i++) {
		if (![[theTableView indexPathsForVisibleRows]containsObject:[NSIndexPath indexPathForRow:i inSection:0]]) {
			Video *video = (Video *)[results objectAtIndex:i];
			video.thumbnailData = nil;
			video.metadata = nil;
		}
	}
	[pool release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if ([results count] > 0) {
		if ((noAdditionalVideos) || (([results count] % VIDEO_BATCH_SIZE) != 0)) {
			return [results count];
		}
		else {
			return ([results count] + 1);
		}
	}
	else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [results count]) {
		static NSString *CellIdentifier = @"Load More Cell";
		
		LoadMoreCell *cell = (LoadMoreCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[LoadMoreCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		}
		
		// Configure the cell...
		
		cell.loadMoreLabel.text = kLoadMoreStr;
		
		return cell;
	}
	else {
		// static NSString *CellIdentifier = @"Cell 2";
		NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %i", indexPath.row];
		
		VideoCell *cell = (VideoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[VideoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		}
		
		// Configure the cell...
		
		if ([results count] > indexPath.row) {
			Video *video = [results objectAtIndex:indexPath.row];
			if (video.ratingCount < MINIMUM_RATING_COUNT) {
				cell.thumbImageView.hidden = YES;
				cell.ratingPercentLabel.hidden = YES;
				cell.viewCountLabel.frame = CGRectMake(130, 39, 157, 22);
			}
			if (video.thumbnailData) {
				cell.thumbnailImageView.image = [UIImage imageWithData:video.thumbnailData];
			}
			else {
				cell.thumbnailImageView.image = [UIImage imageNamed:kThumbnailPlaceholderImageTitleStr];
				if ([networkStatusChangeNotifier currentNetworkStatus] != kNetworkStatusNotConnected) {
					[thumbnailLoadQueue addOperationWithBlock:^{
						// dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
						// dispatch_async(backgroundQueue, ^{
							ThumbnailLoader *thumbnailLoader = [[ThumbnailLoader alloc]init];
							thumbnailLoader.delegate = self;
							[thumbnailLoader fetchThumbnailForVideo:video withCell:cell inTableView:tableView withResults:results];
							[thumbnailLoader release];
						// });
					}];
				}
			}
			
			cell.titleLabel.text = video.title;
			if (video.percentRating >= 50) {
				cell.thumbImageView.image = [UIImage imageNamed:kThumbUpImageNameStr];
				cell.thumbImageView.highlightedImage = [UIImage imageNamed:kThumbUpSelectedImageNameStr];
				cell.ratingPercentLabel.textColor = [UIColor colorWithRed:THUMB_UP_COLOR_RED green:THUMB_UP_COLOR_GREEN blue:THUMB_UP_COLOR_BLUE alpha:1];
				cell.ratingPercentLabel.text = [NSString stringWithFormat:kPercentRatingStr, video.percentRating];
			}
			else {
				cell.thumbImageView.image = [UIImage imageNamed:kThumbDownImageNameStr];
				cell.thumbImageView.highlightedImage = [UIImage imageNamed:kThumbDownSelectedImageNameStr];
				cell.ratingPercentLabel.textColor = [UIColor colorWithRed:THUMB_DOWN_COLOR_RED green:THUMB_DOWN_COLOR_GREEN blue:THUMB_DOWN_COLOR_BLUE alpha:1];
				cell.ratingPercentLabel.text = [NSString stringWithFormat:kPercentRatingStr, (100 - video.percentRating)];
			}
			cell.viewCountLabel.text = [NSString stringWithFormat:kViewCountStr, video.viewCount, video.viewCount == 1 ? @"" : @"s"];
			cell.durationLabel.text = video.duration;
			cell.submitterLabel.text = video.submitter;
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		}
		
		return cell;
	}
}

- (void)thumbnailLoaderDidFinishFetchForThumbnailForVideo:(Video *)video {
	if (video) {
		if ([video description]) {
			[thumbnailFetchArray removeObject:[video description]];
		}
	}
	if (([thumbnailFetchArray count] <= 0) || ([networkStatusChangeNotifier currentNetworkStatus] == kNetworkStatusNotConnected)) {
		if ([[UIApplication sharedApplication]isNetworkActivityIndicatorVisible]) {
			[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
		}
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ROW_HEIGHT;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.row == [results count]) {
		loadMoreCell = (LoadMoreCell *)[tableView cellForRowAtIndexPath:indexPath];
		if (loadMoreCell.loadMoreActivityIndicator.hidden) {
			loadMoreCell.loadMoreLabel.textColor = [UIColor grayColor];
			loadMoreCell.loadMoreActivityIndicator.hidden = NO;
			[loadMoreCell.loadMoreActivityIndicator startAnimating];
			[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
			[self fetchVideosForQuery:theSearchBar.text];
		}
	}
	else {
		pendingIndexPath = indexPath;
		[pendingIndexPath retain];
		UIActionSheet *optionsActionSheet = [[UIActionSheet alloc]
											 initWithTitle:[[results objectAtIndex:indexPath.row]title]
											 delegate:self
											 cancelButtonTitle:@"Cancel"
											 destructiveButtonTitle:@"Download"
											 otherButtonTitles:@"Stream", nil];
		optionsActionSheet.tag = 0;
		optionsActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		[optionsActionSheet showInView:self.tabBarController.view];
		[optionsActionSheet release];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	Video *video = [results objectAtIndex:indexPath.row];
    [(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]presentOptionsActionSheetForVideoWithID:video.videoID title:video.title];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	Video *video = [results objectAtIndex:pendingIndexPath.row];
	if (actionSheet.tag == 0) {
		if (buttonIndex == actionSheet.cancelButtonIndex) {
			if (pendingIndexPath) {
				[pendingIndexPath release];
				pendingIndexPath = nil;
			}
		}
		else if ([results count] > pendingIndexPath.row) {
			UIView *rootView = [[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]rootViewController]view];
			// hud = [[HUDView alloc]initWithFrame:CGRectMake(0, 0, 161, 135)];
			hud = [[HUDView alloc]initWithFrame:CGRectMake(80, 158, 160, 135)];
			hud.delegate = self;
			hud.hudLabel.text = kHUDTitleStr;
			hud.hudSubtitleLabel.text = kHUDProcessingSubtitleStr;
			// hud.center = CGPointMake(rootView.center.x, (rootView.center.y - 20));
			[rootView addSubview:hud];
			[hud release];
			
			pendingButtonIndex = buttonIndex;
			[[[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]theTabBarController]view]setUserInteractionEnabled:NO];
			theTableView.scrollsToTop = NO;
			if (((buttonIndex == 0) && ((video.thumbnailData) && (video.metadata))) || ((buttonIndex == 1) && (video.metadata))) {
				[self processMetadataForVideo:video];
			}
			else {
				kDataLoadType loadType = kDataLoadTypeMetadata;
				if (buttonIndex == 0) {
					loadType = kDataLoadTypeAll;
				}
				dataLoader = [[DataLoader alloc]init];
				dataLoader.delegate = self;
				[dataLoader fetchDataForVideo:video loadType:loadType];
				// [dataLoader release];
			}
		}
	}
	else if (actionSheet.tag < 3) {
		if (buttonIndex == actionSheet.cancelButtonIndex) {
			[self hideHUDAnimated:YES];
		}
		else {
			kVideoDefinition quality = [[pendingQualityOptions objectAtIndex:buttonIndex]integerValue];
			if (actionSheet.tag == 1) {
				[self processVideo:video isDownload:YES quality:quality];
			}
			else if (actionSheet.tag == 2) {
				[self processVideo:video isDownload:NO quality:quality];
			}
			if (pendingIndexPath) {
				[pendingIndexPath release];
				pendingIndexPath = nil;
			}
		}
	}
}

- (void)hudViewTouchesBegan:(HUDView *)hudView {
	if (dataLoader) {
		if ([dataLoader respondsToSelector:@selector(setDelegate:)]) {
			[dataLoader setDelegate:nil];
		}
		if ([dataLoader respondsToSelector:@selector(cancelFetch)]) {
			[dataLoader cancelFetch];
		}
		[dataLoader release];
		dataLoader = nil;
	}
	[[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]rootViewController]cancelPlayback];
	hud.hudSubtitleLabel.text = kHUDCanceledSubtitleStr;
	[self hideHUDAnimated:YES];
}

- (void)dataLoaderDidFetchDataForVideo:(Video *)video {
	[self processMetadataForVideo:video];
	[dataLoader release];
	dataLoader = nil;
}

- (void)dataLoaderFetchDidFailForVideo:(Video *)video {
	if ([networkStatusChangeNotifier currentNetworkStatus] == kNetworkStatusNotConnected) {
		[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]displayCannotConnectAlert:NO];
	}
	else {
		UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle:@"Restricted Content"
								   message:@"The data for this video could not\nbe retrieved. This can be due to\nthe video having been restricted\nby its submitter. However, you\ncan still view the video on the YouTube mobile website by selecting the blue arrow and choosing \"View in Safari\"."
								   delegate:nil
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert release];
	}
	[dataLoader release];
	dataLoader = nil;
	[self hideHUDAnimated:YES];
}

- (void)moviePlayerDidLoadVideo {
	[self hideHUDAnimated:NO];
}

- (void)moviePlayerDidFailLoad {
	UIAlertView *loadFailedAlert = [[UIAlertView alloc]
									initWithTitle:@"Load Failed"
									message:@"The video could not be played. This can be the result of a slow Internet connection. Please check your Internet connection status and try again."
									delegate:nil
									cancelButtonTitle:@"OK"
									otherButtonTitles:nil];
	[loadFailedAlert show];
	[loadFailedAlert release];
	[self hideHUDAnimated:YES];
}

- (void)hideHUDAnimated:(BOOL)animated {
	[[[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]theTabBarController]view]setUserInteractionEnabled:YES];
	theTableView.scrollsToTop = YES;
	if (animated) {
		hud.userInteractionEnabled = NO;
		[UIView beginAnimations:@"Fade Out" context:nil];
		[UIView setAnimationDuration:0.25];
		hud.alpha = 0;
		[UIView commitAnimations];
	}
	else {
		[hud removeFromSuperview];
	}
	hud = nil;
}

- (void)processMetadataForVideo:(Video *)video {
	if (video.metadata) {
		[pendingQualityOptions removeAllObjects];
		/*
		 if ([pendingMetadata rangeOfString:kSearchStrHD3072p].length > 0) {
		 [pendingQualityOptions addObject:[NSNumber numberWithInt:kVideoDefinitionHD3072p]];
		 }
		 */
		if ([video.metadata rangeOfString:kSearchStrHD1080p].length > 0) {
			[pendingQualityOptions addObject:[NSNumber numberWithInt:kVideoDefinitionHD1080p]];
		}
		if ([video.metadata rangeOfString:kSearchStrHD720p].length > 0) {
			[pendingQualityOptions addObject:[NSNumber numberWithInt:kVideoDefinitionHD720p]];
		}
		if ([video.metadata rangeOfString:kSearchStrSD].length > 0) {
			[pendingQualityOptions addObject:[NSNumber numberWithInt:kVideoDefinitionSD]];
		}
		if ([pendingQualityOptions count] > 0) {
			BOOL isDownload = (pendingButtonIndex == 0);
			if ([pendingQualityOptions count] == 1) {
				[self processVideo:video isDownload:isDownload quality:[[pendingQualityOptions objectAtIndex:0]integerValue]];
			}
			else {
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				NSInteger qualityOptionsIndex = 0;
				if (pendingButtonIndex == 0) {
					qualityOptionsIndex = [defaults integerForKey:kQualitySettingsSection2SelectedRowStr];
				}
				else if (pendingButtonIndex == 1) {
					qualityOptionsIndex = [defaults integerForKey:kQualitySettingsSection1SelectedRowStr];
				}
				if (qualityOptionsIndex == BEST_QUALITY_INDEX) {
					[self processVideo:video isDownload:isDownload quality:[[pendingQualityOptions objectAtIndex:0]integerValue]];
				}
				else if (qualityOptionsIndex == STANDARD_DEFINITION_INDEX) {
					[self processVideo:video isDownload:isDownload quality:[[pendingQualityOptions lastObject]integerValue]];
				}
				else {
					NSString *prefix = (pendingButtonIndex == 0) ? @"Download in " : @"Stream in ";
					UIActionSheet *qualityOptionsActionSheet = [[UIActionSheet alloc]init];
					qualityOptionsActionSheet.title = @"This video is available in multiple qualities.";
					for (NSNumber *quality in pendingQualityOptions) {
						[qualityOptionsActionSheet addButtonWithTitle:[prefix stringByAppendingString:[MetadataLoader stringForQuality:[quality integerValue]]]];
					}
					[qualityOptionsActionSheet addButtonWithTitle:@"Cancel"];
					qualityOptionsActionSheet.cancelButtonIndex = [pendingQualityOptions count];
					qualityOptionsActionSheet.delegate = self;
					qualityOptionsActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
					qualityOptionsActionSheet.tag = (pendingButtonIndex == 0) ? 1 : 2;
					[qualityOptionsActionSheet showInView:self.tabBarController.view];
					[qualityOptionsActionSheet release];
				}
			}
		}
		else {
			video.metadata = nil;
			UIAlertView *errorAlert = [[UIAlertView alloc]
									   initWithTitle:@"Error"
									   message:@"Corrupt metadata. This can be due to the video having been restricted by its submitter. However, you can still view the video on the YouTube mobile website by selecting the blue arrow and choosing \"View in Safari\"."
									   delegate:nil
									   cancelButtonTitle:@"OK"
									   otherButtonTitles:nil];
			[errorAlert show];
			[errorAlert release];
			[self hideHUDAnimated:YES];
		}
	}
	else {
		kNetworkStatus networkStatus = [networkStatusChangeNotifier currentNetworkStatus];
		if (networkStatus == kNetworkStatusNotConnected) {
			[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]displayCannotConnectAlert:NO];
		}
		else {
			UIAlertView *errorAlert = [[UIAlertView alloc]
									   initWithTitle:@"Error"
									   message:@"The metadata for this video could not be retrieved. This can be the result of a slow Internet connection. Please check your Internet connection status and try again."
									   delegate:nil
									   cancelButtonTitle:@"OK"
									   otherButtonTitles:nil];
			[errorAlert show];
			[errorAlert release];
		}
		[self hideHUDAnimated:YES];
	}
}

- (void)processVideo:(Video *)video isDownload:(BOOL)isDownload quality:(kVideoDefinition)quality {
	NSString *videoURL = [MetadataLoader urlForVideo:video metadata:video.metadata quality:quality];
	if ([videoURL length] > 0) {
		MyTubeAppDelegate *appDelegate = (MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate];
		if (isDownload) {
			[appDelegate downloadVideo:video atURL:videoURL quality:quality];
			[self hideHUDAnimated:YES];
		}
		else {
			ContainerViewController *containerViewController = appDelegate.rootViewController;
			containerViewController.delegate = self;
			[containerViewController playVideoAtURL:[NSURL URLWithString:videoURL] initialPlaybackTime:0];
		}
	}
	else {
		UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle:@"Error"
								   message:@"An error occurred while parsing the metadata of this video.\nPlease restart your device and try again."
								   delegate:nil
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert release];
		[self hideHUDAnimated:YES];
	}
}

// Workaround for the mysterious unloading of some objects contained within and
// used by the search-type instance of SearchViewController, rendering them unusable.
/*
- (void)setView:(UIView *)view {
	if (!viewDidAppear) {
		viewDidAppear = YES;
		[super setView:view];
	}
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
	
	if ([self viewIsVisible]) {
		[self clearCache];
	}
	else {
		[self clearResults];
	}
}

// Less memory-consuming alternative to the workaround mentioned above.

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	/*
	self.placeholderView = nil;
	self.maskActivityIndicator = nil;
	self.maskLabel = nil;
	self.containerView = nil;
	self.theSearchBar = nil;
	self.timeSelectSegmentedControl = nil;
	self.theTableView = nil;
	self.searchMask = nil;
	self.thumbnailLoadQueue = nil;
	self.networkStatusChangeNotifier = nil;
	self.results = nil;
	self.thumbnailFetchArray = nil;
	self.pendingQualityOptions = nil;
	*/
}

- (void)dealloc {
	[placeholderView release];
	[maskActivityIndicator release];
	[maskLabel release];
	[containerView release];
	[theSearchBar release];
	[timeSelectSegmentedControl release];
	[theTableView release];
	[searchMask release];
	[thumbnailLoadQueue release];
	[networkStatusChangeNotifier release];
	[results release];
	[thumbnailFetchArray release];
	[pendingQualityOptions release];
    [super dealloc];
}

@end
