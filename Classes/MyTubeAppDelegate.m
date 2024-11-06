//
//  MyTubeAppDelegate.m
//  MyTube
//
//  Created by Harrison White on 2/18/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "MyTubeAppDelegate.h"
#import "ContainerViewController.h"
#import "SearchViewController.h"
#import "VideosViewController.h"
#import "SettingsViewController.h"
#import "ThumbnailLoader.h"
#import "SA_OAuthTwitterEngine.h"
#import "NetworkStatusChangeNotifier.h"
// #import "AgreementViewController.h"

#define kOAuthConsumerKey						@"PVkrvxgQuhLrXjl2CGdfw"
#define kOAuthConsumerSecret					@"zdmtlVNydOQjO74LNWkFqdk24niZTIm9PyUtCWiEoc"

#define AD_WIDTH_IN_PIXELS						320
#define AD_HEIGHT_IN_PIXELS						50

#define REQUEST_TO_RATE_LAUNCH_COUNT			3
#define ROW_HEIGHT								90

#define kFileNameReplacementStringsArray		[NSArray arrayWithObjects:@"/", @"_", @"[", @"_", @"]", @"_", nil]

#define MB_FLOAT_SIZE							1048576.0
#define MB_WRITE_SIZE							2.5
#define DATA_WRITE_LENGTH						(MB_WRITE_SIZE * MB_FLOAT_SIZE)

#define FAILED_COLOR_RED						(180.0 / 255.0)
#define FAILED_COLOR_GREEN						0.1372549
#define FAILED_COLOR_BLUE						(15.0 / 255.0)

#define FILE_REQUEST_TIMEOUT_INTERVAL			5
#define SUCCEEDED_STATUS_CODE					200

static NSString *kAdUnitID						= @"a14e76128a7883c";

static NSString *kFacebookAppIDStr				= @"116300361807214";
static NSString *kTwitterAuthenticationDataKey	= @"Twitter Authentication Data";

// static NSString *kNotificationVideoKey		= @"Video";

static NSString *kDefaultsSetKey				= @"Defaults Set";
// static NSString *kDidAcceptUserAgreementKey	= @"Did Accept User Agreement";
static NSString *kWelcomeMessageShownKey		= @"Welcome Message Shown";
static NSString *kTabOrderKey					= @"Tab Order";
static NSString *kSelectedTabBarItemIndexKey	= @"Selected Tab Bar Item Index";
static NSString *kCountryCodeKey				= @"Country Code";
static NSString *kLanguageCodeKey				= @"Language Code";
static NSString *kNullStr						= @"";
static NSString *kDownloadAlertsKey             = @"Download Alerts";
static NSString *kBackgroundAudioKey			= @"Background Audio";

static NSString *kSafariOpenURLStr				= @"http://m.youtube.com/#/watch?v=";
static NSString *kFacebookPostPrefixStr			= @"http://www.youtube.com/watch?v=";
static NSString *kTwitterPostPrefixStr			= @"Check out this video on YouTube:\nhttp://youtu.be/";
static NSString *kEmailBodyFormatStr			= @"<html><body>Check out this video on YouTube:<br/><br/><embed id=\"yt\" src=\"http://www.youtube.com/watch?v=%@&feature=youtube_gdata_player\" type=\"application/x-shockwave-flash\" width=\"300\" height=\"200\"></embed><br/><br/><a href=\"http://www.youtube.com/watch?v=%@&feature=youtube_gdata_player\">http://www.youtube.com/watch?v=%@&feature=youtube_gdata_player</a></body></html>";
static NSString *kCannotSendMailOpenURLStr		= @"mailto:";

// DOWNLOAD CODE

#import "DownloadsViewController.h"
#import "Video.h"

static NSString *kBadgeFormatStr				= @"%i";
static NSString *kWaitingStr					= @"Waiting...";
static NSString *kCanceledStr					= @"Canceled";
static NSString *kFailedStr						= @"Failed";
static NSString *kStartingDownloadStr			= @"Starting Download...";
// static NSString *kProcessingStr				= @"Processing...";

static NSString *kHUDTitleStr					= @"Loading...";
static NSString *kHUDProcessingSubtitleStr		= @"Tap to Cancel";
static NSString *kHUDCanceledSubtitleStr		= @"Canceled.";

static NSString *kStringFormatSpecifierStr		= @"%@";
static NSString *kFloatFormatSpecifierStr		= @"%f";

static NSString *kDecimalStr					= @".";
static NSString *kTenthAppendStr				= @"0";
static NSString *kWholeNumberAppendStr			= @".00";
static NSString *kProgressFormatStr				= @"%@ of %@ MB";

static NSString *kFileCopyStr					= @"%@ (%i)";
static NSString *kDownloadPathExtensionStr		= @"download";
static NSString *kFilePathExtensionStr			= @"mp4";

static NSString *kDownloadEntityName			= @"Download";
static NSString *kVideoEntityName				= @"Video";
static NSString *kCacheNameStr					= @"DownloadCache";
static NSString *kCreationTimeKey				= @"creationTime";
static NSString *kDownloadURLKey				= @"downloadURL";
static NSString *kDurationKey					= @"duration";
static NSString *kExpectedSizeKey				= @"expectedSize";
static NSString *kFileNameKey					= @"fileName";
static NSString *kQualityKey					= @"quality";
static NSString *kSizeKey						= @"size";
static NSString *kStateKey						= @"state";
static NSString *kSubmitterKey					= @"submitter";
// static NSString *kSubtitleKey				= @"subtitle";
static NSString *kThumbnailKey					= @"thumbnail";
static NSString *kTitleKey						= @"title";
static NSString *kVideoIDKey					= @"videoID";

// END DOWNLOAD CODE

@implementation MyTubeAppDelegate

@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;

@synthesize window;
@synthesize rootViewController;
@synthesize theTabBarController;
@synthesize bannerViewContainer;
@synthesize bannerView;
@synthesize tabBarItemIndexDictionary;
@synthesize selectedTabBarItemIndex;
@synthesize pendingVideoTitle;
@synthesize pendingVideoID;

@synthesize networkStatusChangeNotifier;

@synthesize facebook;
@synthesize twitterEngine;
@synthesize pendingTwitterPostRequest;
@synthesize pendingTweet;

// DOWNLOAD CODE

@synthesize fetchedResultsController;
@synthesize downloadFetchedResultsController;

@synthesize downloadsTabIndex;
@synthesize theTableView;
@synthesize currentDownload;
@synthesize currentConnection;
@synthesize receivedData;
@synthesize currentFileSize;
@synthesize currentFileHandle;
@synthesize downloadUpdateTimer;
@synthesize pendingIndexPath;
@synthesize cancelActionSheet;
@synthesize decimalNumberHandler;
@synthesize dataLoader;
@synthesize hud;
@synthesize massOperationInProgress;
@synthesize cannotConnectAlertShown;
@synthesize viewIsVisible;
@synthesize didLoadAd;
@synthesize isRunningInBackground;

// END DOWNLOAD CODE

@synthesize backgroundTask;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	// Override point for customization after application launch.
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([defaults boolForKey:kDefaultsSetKey]) {
		BOOL hasChanges = NO;
		NSArray *revisedCountryCodesArray = [[NSArray arrayWithObject:kNullStr]arrayByAddingObjectsFromArray:kCountryCodesArray];
		if (![revisedCountryCodesArray containsObject:[defaults objectForKey:kCountryCodeKey]]) {
			[defaults setObject:kNullStr forKey:kCountryCodeKey];
			hasChanges = YES;
		}
		NSArray *revisedLanguagesArray = [[NSArray arrayWithObject:kNullStr]arrayByAddingObjectsFromArray:kLanguageCodesArray];
		if (![revisedLanguagesArray containsObject:[defaults objectForKey:kLanguageCodeKey]]) {
			[defaults setObject:kNullStr forKey:kLanguageCodeKey];
			hasChanges = YES;
		}
		if (hasChanges) {
			[defaults synchronize];
		}
	}
	else {
		[defaults setValuesForKeysWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Defaults" ofType:@"plist"]]];
		[defaults synchronize];
		
		/*
		NSLocale *locale = [NSLocale currentLocale];
		NSString *currentCountry = [locale objectForKey:NSLocaleCountryCode];
		for (NSString *countryCode in kCountryCodesArray) {
			if ([currentCountry isEqualToString:countryCode]) {
				[defaults setObject:countryCode forKey:kCountryCodeKey];
				[defaults synchronize];
				break;
			}
		}
		NSString *currentLanguage = [locale objectForKey:NSLocaleLanguageCode];
		for (NSString *languageCode in kLanguageCodesArray) {
			if ([currentLanguage isEqualToString:languageCode]) {
				[defaults setObject:languageCode forKey:kLanguageCodeKey];
				[defaults synchronize];
				break;
			}
		}
		*/
	}
	if (![[NSFileManager defaultManager]fileExistsAtPath:[self applicationDocumentsDirectory]]) {
		NSError *error = nil;
		if (![[NSFileManager defaultManager]createDirectoryAtPath:[self applicationDocumentsDirectory] withIntermediateDirectories:NO attributes:nil error:&error]) {
			[self abortWithError:error];
		}
    }
	if (![[NSFileManager defaultManager]fileExistsAtPath:[self applicationDataStorageDirectory]]) {
		NSError *error = nil;
		if (![[NSFileManager defaultManager]createDirectoryAtPath:[self applicationDataStorageDirectory] withIntermediateDirectories:NO attributes:nil error:&error]) {
			[self abortWithError:error];
		}
    }
	
	NSMutableArray *currentTabOrderArray = [NSMutableArray arrayWithObjects:nil];
	for (int i = 0; i < [theTabBarController.viewControllers count]; i++) {
		UITabBarItem *tabBarItem = [[(UINavigationController *)[theTabBarController.viewControllers objectAtIndex:i]topViewController]tabBarItem];
		tabBarItem.tag = i;
		[currentTabOrderArray addObject:[NSNumber numberWithInt:i]];
	}
	tabBarItemIndexDictionary = [[NSMutableDictionary alloc]init];
	NSArray *customTabOrderArray = [defaults arrayForKey:kTabOrderKey];
	NSMutableArray *tabsArray = [NSMutableArray arrayWithObjects:nil];
	for (int i = 0; i < [theTabBarController.viewControllers count]; i++) {
		NSInteger index = 0;
		if ([customTabOrderArray count] > i) {
			index = [[customTabOrderArray objectAtIndex:i]integerValue];
		}
		else {
			index = [[currentTabOrderArray objectAtIndex:i]integerValue];
		}
		UINavigationController *navigationController = [theTabBarController.viewControllers objectAtIndex:index];
		UIViewController *viewController = [navigationController topViewController];
		if ([viewController isKindOfClass:[SearchViewController class]]) {
			[tabBarItemIndexDictionary setObject:[NSNumber numberWithInteger:i] forKey:[NSNumber numberWithInteger:viewController.tabBarItem.tag]];
		}
		else if ([viewController isKindOfClass:[DownloadsViewController class]]) {
			downloadsTabIndex = i;
		}
		[tabsArray addObject:navigationController];
	}
	theTabBarController.viewControllers = tabsArray;
	NSInteger selectedIndex = [defaults integerForKey:kSelectedTabBarItemIndexKey];
	if (selectedIndex < [theTabBarController.viewControllers count]) {
		theTabBarController.selectedIndex = selectedIndex;
	}
	else {
		theTabBarController.selectedViewController = theTabBarController.moreNavigationController;
	}
	
	theTabBarController.view.frame = CGRectMake(0, 0, 320, 460);
	[rootViewController.view addSubview:theTabBarController.view];
	
	bannerView = [[GADBannerView alloc]initWithFrame:CGRectMake(0, 0, AD_WIDTH_IN_PIXELS, AD_HEIGHT_IN_PIXELS)];
	bannerView.adUnitID = kAdUnitID;
	bannerView.delegate = self;
	bannerView.rootViewController = rootViewController;
	
	[self loadRequest];
	
	bannerViewContainer = [[UIView alloc]initWithFrame:CGRectMake(0, (460 - (theTabBarController.tabBar.frame.size.height + AD_HEIGHT_IN_PIXELS)), bannerView.frame.size.width, bannerView.frame.size.height)];
	bannerViewContainer.backgroundColor = [UIColor whiteColor];
	bannerViewContainer.hidden = YES;
	[bannerViewContainer addSubview:bannerView];
	
	[rootViewController.view addSubview:bannerViewContainer];
	
	// [window addSubview:rootViewController.view];
	window.rootViewController = rootViewController;
	
	networkStatusChangeNotifier = [[NetworkStatusChangeNotifier defaultNotifier]retain];
	
	/*
	if (![defaults boolForKey:kDidAcceptUserAgreementKey]) {
		AgreementViewController *agreementViewController = [[AgreementViewController alloc]initWithNibName:@"AgreementViewController" bundle:nil];
        [rootViewController presentModalViewController:agreementViewController animated:NO];
        [agreementViewController release];
    }
	*/
	
	facebook = [[Facebook alloc]initWithAppId:kFacebookAppIDStr];
	
	twitterEngine = [[SA_OAuthTwitterEngine alloc]initOAuthWithDelegate:self];
	twitterEngine.consumerKey = kOAuthConsumerKey;
	twitterEngine.consumerSecret = kOAuthConsumerSecret;
	
	// DOWNLOAD CODE
	
	theTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 367) style:UITableViewStylePlain];
	theTableView.dataSource = self;
	theTableView.delegate = self;
	theTableView.rowHeight = ROW_HEIGHT;
	
	NSError *error = nil;
    if (![[self fetchedResultsController]performFetch:&error]) {
        [self abortWithError:error];
    }
	
	decimalNumberHandler = [[NSDecimalNumberHandler alloc]
							initWithRoundingMode:NSRoundPlain
							scale:2
							raiseOnExactness:NO
							raiseOnOverflow:NO
							raiseOnUnderflow:NO
							raiseOnDivideByZero:NO];
	
	[self updateCurrentDownload];
	
	// END DOWNLOAD CODE
	
	if (![defaults boolForKey:kWelcomeMessageShownKey]) {
		UIAlertView *welcomeAlert = [[UIAlertView alloc]
									 initWithTitle:@"Welcome to MyTube"
									 message:@"Thanks for downloading MyTube! Please visit the settings section to adjust your video preferences.\nWe hope you enjoy using the app."
									 delegate:self
									 cancelButtonTitle:@"Dismiss"
									 otherButtonTitles:@"Settings", nil];
		welcomeAlert.tag = 0;
		[welcomeAlert show];
		[welcomeAlert release];
	}
	
	[window makeKeyAndVisible];
	
	return YES;
}

- (void)loadRequest {
	GADRequest *request = [GADRequest request];
	[bannerView loadRequest:request];
}

- (void)showBannerViewIfApplicable {
	if (didLoadAd) {
		if (bannerView.hidden) {
			// Resume loading ads (ad requests stop once the banner view is hidden).
			[self loadRequest];
			bannerView.hidden = NO;
		}
		bannerViewContainer.hidden = NO;
	}
}

- (void)adViewDidReceiveAd:(GADBannerView *)view {
	didLoadAd = YES;
	bannerViewContainer.hidden = NO;
	[[NSNotificationCenter defaultCenter]postNotificationName:kAdDidLoadNotification object:nil];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
	didLoadAd = NO;
	[[NSNotificationCenter defaultCenter]postNotificationName:kAdDidFailLoadNotification object:nil];
	bannerViewContainer.hidden = YES;
}

- (void)presentOptionsActionSheetForVideoWithID:(NSString *)videoID title:(NSString *)title {
	if (pendingVideoTitle) {
		[pendingVideoTitle release];
		pendingVideoTitle = nil;
	}
	if (pendingVideoID) {
		[pendingVideoID release];
		pendingVideoID = nil;
	}
	pendingVideoTitle = [title retain];
	pendingVideoID = [videoID retain];
	UIActionSheet *openActionSheet = [[UIActionSheet alloc]
                                      initWithTitle:title
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"View in Safari", @"Share...", nil];
	openActionSheet.tag = 2;
    [openActionSheet showInView:theTabBarController.view];
    [openActionSheet release];
}

- (void)emailVideo {
	[self presentMailComposeControllerWithSubject:pendingVideoTitle message:[NSString stringWithFormat:kEmailBodyFormatStr, pendingVideoID, pendingVideoID, pendingVideoID]];
}

- (void)presentMailComposeControllerWithSubject:(NSString *)subject message:(NSString *)message {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc]init];
		mailComposeViewController.mailComposeDelegate = self;
		[mailComposeViewController setSubject:subject];
		[mailComposeViewController setMessageBody:message isHTML:YES];
		[rootViewController presentModalViewController:mailComposeViewController animated:YES];
		[mailComposeViewController release];
	}
	else {
		[self displayCannotSendMailAlert];
	}
}

- (void)displayCannotSendMailAlert {
	UIAlertView *cannotSendMailAlert = [[UIAlertView alloc]
										initWithTitle:@"Cannot Send Mail"
										message:@"You must configure your device to work with your email account in order to send email. Would you like to do this now?"
										delegate:self
										cancelButtonTitle:@"No Thanks"
										otherButtonTitles:@"Sure", nil];
	cannotSendMailAlert.tag = 3;
	[cannotSendMailAlert show];
	[cannotSendMailAlert release];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[rootViewController dismissModalViewControllerAnimated:YES];
	if (result == MFMailComposeResultFailed) {
		UIAlertView *sendFailedAlert = [[UIAlertView alloc]
										initWithTitle:@"Send Failed"
										message:@"Your message could not be sent. This could be due to little or no Internet connectivity."
										delegate:self
										cancelButtonTitle:@"Cancel"
										otherButtonTitles:@"Retry", nil];
		sendFailedAlert.tag = 4;
		[sendFailedAlert show];
		[sendFailedAlert release];
	}
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	return [facebook handleOpenURL:url];
}

#pragma mark SA_OAuthTwitterEngineDelegate

- (void)storeCachedTwitterOAuthData:(NSString *)data forUsername:(NSString *)username {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:data forKey:kTwitterAuthenticationDataKey];
	[defaults synchronize];
}

- (NSString *)cachedTwitterOAuthDataForUsername:(NSString *)username {
	return [[NSUserDefaults standardUserDefaults]objectForKey:kTwitterAuthenticationDataKey];
}

#pragma mark -
#pragma mark SA_OAuthTwitterControllerDelegate

- (void)OAuthTwitterController:(SA_OAuthTwitterController *)controller authenticatedWithUsername:(NSString *)username {
	[[UIApplication sharedApplication]beginIgnoringInteractionEvents];
	// NSLog(@"Authenicated for %@", username);
}

/*
- (void)OAuthTwitterControllerFailed:(SA_OAuthTwitterController *)controller {
	NSLog(@"Authentication Failed!");
}
*/

- (void)OAuthTwitterControllerCanceled:(SA_OAuthTwitterController *)controller {
	pendingTwitterPostRequest = NO;
	// NSLog(@"Authentication Canceled.");
}

#pragma mark -
#pragma mark TwitterEngineDelegate

/*
- (void)requestSucceeded:(NSString *)requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
}

- (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}
*/

#pragma mark -

- (NSFetchedResultsController *)downloadFetchedResultsController {
	if (downloadFetchedResultsController != nil) {
		return downloadFetchedResultsController;
	}
	
	/*
	Set up the fetched results controller.
	*/
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:kDownloadEntityName inManagedObjectContext:[self managedObjectContext]];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:[NSSortDescriptor sortDescriptorWithKey:kStateKey ascending:YES], [NSSortDescriptor sortDescriptorWithKey:kCreationTimeKey ascending:YES], nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(state == %@) OR (state == %@)", [NSNumber numberWithInteger:kDownloadStateInProgress], [NSNumber numberWithInteger:kDownloadStatePending]]];
	
	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
	
	self.downloadFetchedResultsController = controller;
	[downloadFetchedResultsController retain];
	
	[controller release];
	[fetchRequest release];
	[sortDescriptors release];
	
	return downloadFetchedResultsController;
}

- (void)displayCannotConnectAlert:(BOOL)passive {
	if ((!passive) || ((passive) && (!cannotConnectAlertShown))) {
		cannotConnectAlertShown = YES;
		UIAlertView *cannotConnectAlert = [[UIAlertView alloc]
										   initWithTitle:@"Cannot Connect to YouTube"
										   message:@"Please check your Internet connection status and try again."
										   delegate:nil
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];
		[cannotConnectAlert show];
		[cannotConnectAlert release];
	}
}

- (void)presentTwitterViewWithMessage:(NSString *)message {
	if (([[[UIDevice currentDevice]systemVersion]compare:@"5.0"] != NSOrderedAscending) && (NSClassFromString(@"TWTweetComposeViewController"))) {
		if ([TWTweetComposeViewController canSendTweet]) {
			TWTweetComposeViewController *tweetComposeViewController = [[TWTweetComposeViewController alloc]init];
			[tweetComposeViewController setInitialText:message];
			[rootViewController presentModalViewController:tweetComposeViewController animated:YES];
			[tweetComposeViewController release];
		}
		else {
			UIAlertView *cannotSendMailAlert = [[UIAlertView alloc]
												initWithTitle:@"Twitter Account Not Configured"
												message:@"You must configure your device to work with your Twitter account in order to send tweets. You can do this in the Settings app."
												delegate:nil
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
			[cannotSendMailAlert show];
			[cannotSendMailAlert release];
		}
	}
	else {
		if (pendingTweet){
			[pendingTweet release];
			pendingTweet = nil;
		}
		if (message) {
			pendingTweet = [[NSString alloc]initWithString:message];
		}
		
		// if (!twitterEngine) return;
		
		[[UIApplication sharedApplication]beginIgnoringInteractionEvents];
		
		UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:twitterEngine delegate:self];
		if (controller) {
			pendingTwitterPostRequest = YES;
			[rootViewController presentModalViewController:controller animated:YES];
		}
		else {
			[rootViewController presentTwitterPostView];
		}
		/*
		 else {
		 [twitterEngine sendUpdate:[NSString stringWithFormat:@"Already Updated. %@", [NSDate date]]];
		 }
		 */
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setBool:YES forKey:kWelcomeMessageShownKey];
		[defaults synchronize];
		if (buttonIndex != alertView.cancelButtonIndex) {
			for (int i = 0; i < [theTabBarController.viewControllers count]; i++) {
				if ([[[theTabBarController.viewControllers objectAtIndex:i]topViewController]isKindOfClass:[SettingsViewController class]]) {
					[theTabBarController setSelectedIndex:i];
					break;
				}
			}
		}
	}
	else if (buttonIndex != alertView.cancelButtonIndex) {
		if (alertView.tag == 3) {
			NSURL *request = [NSURL URLWithString:kCannotSendMailOpenURLStr];
			if ([[UIApplication sharedApplication]canOpenURL:request]) {
				[[UIApplication sharedApplication]openURL:request];
			}
			else {
				UIAlertView *cannotLaunchMailAlert = [[UIAlertView alloc]
													  initWithTitle:@"Cannot Launch Mail"
													  message:@"Your request could not be completed due to the restrictions on your device. Please allow changes to accounts in the Mail application (launch the Settings app and select General > Restrictions > Accounts > Allow Changes) and try again."
													  delegate:nil
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
				[cannotLaunchMailAlert show];
				[cannotLaunchMailAlert release];
			}
		}
		else if (alertView.tag == 4) {
			[self emailVideo];
		}
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
	/*
	Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	*/
	
	isRunningInBackground = YES;
	
	if ([[NSUserDefaults standardUserDefaults]boolForKey:kBackgroundAudioKey]) {
		[self resumeVideoPlayback];
	}
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	/*
	Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
	*/
	
	isRunningInBackground = YES;
	
	if (backgroundTask) {
		[[UIApplication sharedApplication]endBackgroundTask:backgroundTask];
	}
	[[UIApplication sharedApplication]beginBackgroundTaskWithExpirationHandler:^{
		backgroundTask = 0;
	}];
	
	if ([[NSUserDefaults standardUserDefaults]boolForKey:kBackgroundAudioKey]) {
		[self resumeVideoPlayback];
	}
	
	// AVPlayerItem *playerItem = [[AVPlayerItem alloc]initWithURL:rootViewController.player.moviePlayer.contentURL];
	
	// [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
	
	[self clearCache];
}

- (void)clearCache {
	for (int i = 0; i < [theTabBarController.viewControllers count]; i++) {
		UINavigationController *navigationController = [theTabBarController.viewControllers objectAtIndex:i];
		if (![navigationController isEqual:theTabBarController.selectedViewController]) {
			UIViewController *topViewController = [navigationController topViewController];
			if ([topViewController isKindOfClass:[SearchViewController class]]) {
				SearchViewController *viewController = ((SearchViewController *)topViewController);
				if (viewController) {
					if ([viewController respondsToSelector:@selector(clearResults)]) {
						[viewController clearResults];
					}
				}
			}
		}
	}
}

- (void)resumeVideoPlayback {
	if (rootViewController.modalViewController) {
		if (rootViewController.lastPlaybackState == MPMoviePlaybackStatePlaying) {
			[self performSelector:@selector(_resumeVideoPlayback) withObject:nil afterDelay:0.000001];
		}
	}
}

- (void)_resumeVideoPlayback {
	[rootViewController.player.moviePlayer play];
}

/*
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"status"]) {
		AVQueuePlayer *queuePlayer = [[AVQueuePlayer alloc]initWithPlayerItem:((AVPlayerItem *)object)];
		// [queuePlayer insertItem:(AVPlayerItem *)object afterItem:nil];
		// [queuePlayer advanceToNextItem];
		[queuePlayer play];
		[queuePlayer release];
		
		[object release];
	}
}
*/

- (void)applicationWillEnterForeground:(UIApplication *)application {
	/*
	Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
	*/
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	/*
	Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	*/
	
	isRunningInBackground = NO;
	
	/*
	UILocalNotification *notification = [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
	if (notification) {
		for (int i = 0; i < [theTabBarController.viewControllers count]; i++) {
			UIViewController *viewController = [[theTabBarController.viewControllers objectAtIndex:i]topViewController];
			if ([viewController isKindOfClass:[VideosViewController class]]) {
				[theTabBarController setSelectedIndex:i];
				VideosViewController *videosViewController = ((VideosViewController *)viewController);
				if ([videosViewController fetchedResultsController]) {
					NSIndexPath *videoIndexPath = [[videosViewController fetchedResultsController]indexPathForObject:[[notification userInfo]valueForKey:kNotificationVideoKey]];
					if (videoIndexPath) {
						if (videosViewController.tableView) {
							[videosViewController.tableView scrollToRowAtIndexPath:videoIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
						}
					}
				}
				break;
			}
		}
	}
	*/
	
	[self updateCurrentDownload];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	/*
	Called when the application is about to terminate.
	See also applicationDidEnterBackground:.
	*/
	
	// [facebook logout:self];
	
	NSError *error = nil;
	if (managedObjectContext != nil) {
		if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			[self abortWithError:error];
		}
	}
}

- (void)fbDidLogout {
	UIAlertView *signOutSuccessfulAlert = [[UIAlertView alloc]
										   initWithTitle:@"Signed Out"
										   message:@"You are signed out of Facebook."
										   delegate:nil
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];
	[signOutSuccessfulAlert show];
	[signOutSuccessfulAlert release];
}

#pragma mark -
#pragma mark UITabBarControllerDelegate methods


// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	if (cannotConnectAlertShown) {
		cannotConnectAlertShown = NO;
	}
	
	if (tabBarController.selectedIndex >= 4) {
		[tabBarController.moreNavigationController popToRootViewControllerAnimated:NO];
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:tabBarController.selectedIndex forKey:kSelectedTabBarItemIndexKey];
	[defaults synchronize];
}

// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
	if (changed) {
		NSMutableArray *tabOrderArray = [NSMutableArray arrayWithObjects:nil];
		for (int i = 0; i < [viewControllers count]; i++) {
			UIViewController *viewController = [[viewControllers objectAtIndex:i]topViewController];
			if ([viewController isKindOfClass:[SearchViewController class]]) {
				[tabBarItemIndexDictionary setObject:[NSNumber numberWithInteger:i] forKey:[NSNumber numberWithInteger:viewController.tabBarItem.tag]];
			}
			else if ([viewController isKindOfClass:[DownloadsViewController class]]) {
				downloadsTabIndex = i;
			}
			[tabOrderArray addObject:[NSNumber numberWithInteger:viewController.tabBarItem.tag]];
		}
		[[NSUserDefaults standardUserDefaults]setObject:tabOrderArray forKey:kTabOrderKey];
	}
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	
	if (managedObjectContext != nil) {
		return managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil) {
		managedObjectContext = [[NSManagedObjectContext alloc]init];
		[managedObjectContext setPersistentStoreCoordinator:coordinator];
	}
	return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
	if (managedObjectModel != nil) {
		return managedObjectModel;
	}
	managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil]retain];
	return managedObjectModel;
}


/**
Returns the persistent store coordinator for the application.
If the coordinator doesn't already exist, it is created and the application's store added to it.
*/
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
	if (persistentStoreCoordinator != nil) {
		return persistentStoreCoordinator;
	}
	
	NSURL *storeUrl = [NSURL fileURLWithPath:[[self applicationDataStorageDirectory]stringByAppendingPathComponent:@"Data.sqlite"]];
	
	NSError *error = nil;
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:[self managedObjectModel]];
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		Typical reasons for an error here include:
		* The persistent store is not accessible
		* The schema for the persistent store is incompatible with current managed object model
		Check the error message to determine what the actual problem was.
		*/
		
		[self abortWithError:error];
	}	
	
	return persistentStoreCoordinator;
}

- (void)abortWithError:(NSError *)error {
	/*
	Replace this implementation with code to handle the error appropriately.
	abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	*/
	
	NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	abort();
}

#pragma mark -
#pragma mark Application's data storage directory

- (NSString *)applicationDataStorageDirectory {
	// return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
	return @"/private/var/mobile/Library/MyTube/";
}

#pragma mark -
#pragma mark Application's documents directory

- (NSString *)applicationDocumentsDirectory {
	// return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	return @"/private/var/mobile/Media/MyTube/";
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	/*
	Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
	*/
}

- (void)dealloc {
	[managedObjectContext release];
	[managedObjectModel release];
	[persistentStoreCoordinator release];
	
	[theTabBarController release];
	[bannerViewContainer release];
	[bannerView release];
	[window release];
	[rootViewController release];
	[tabBarItemIndexDictionary release];
	
	[networkStatusChangeNotifier release];
	
	[facebook release];
	[twitterEngine release];
	
	// DOWNLOAD CODE
	
	[fetchedResultsController release];
	[downloadFetchedResultsController release];
	
	[theTableView release];
	
	[decimalNumberHandler release];
	
	// END DOWNLOAD CODE
	
	[super dealloc];
}

#pragma mark -
#pragma mark DOWNLOAD CODE

- (void)actionBarButtonItemPressed {
    UIActionSheet *optionsActionSheet = [[UIActionSheet alloc]
                                         initWithTitle:nil
                                         delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Remove All"
                                         otherButtonTitles:nil];
	optionsActionSheet.tag = 5;
	optionsActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [optionsActionSheet showInView:theTabBarController.view];
    [optionsActionSheet release];
}

- (void)fetchDownloads {
	NSError *error = nil;
    if (![[self downloadFetchedResultsController]performFetch:&error]) {
        [self abortWithError:error];
    }
}

- (void)updateCurrentDownload {
	[self fetchDownloads];
	NSArray *applicableDownloadsArray = [[self downloadFetchedResultsController]fetchedObjects];
	if ([applicableDownloadsArray count] > 0) {
		if ((!currentDownload) || ((currentDownload) && ((![currentDownload isEqual:[applicableDownloadsArray objectAtIndex:0]]) || (![applicableDownloadsArray containsObject:currentDownload]) || (!currentConnection)))) {
			// currentDownload = nil;
			currentDownload = [[applicableDownloadsArray objectAtIndex:0]retain];
			
			[currentDownload setValue:[NSNumber numberWithInteger:kDownloadStateInProgress] forKey:kStateKey];
			
			currentConnection = [[NSURLConnection alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[currentDownload valueForKey:kDownloadURLKey]]] delegate:self];
			
			NSString *filePath = [[self applicationDataStorageDirectory]stringByAppendingPathComponent:[[currentDownload valueForKey:kFileNameKey]stringByAppendingPathExtension:kDownloadPathExtensionStr]];
			[[NSFileManager defaultManager]createFileAtPath:filePath contents:nil attributes:nil];
			receivedData = [[NSMutableData alloc]initWithLength:0];
			currentFileSize = 0;
			currentFileHandle = [[NSFileHandle fileHandleForUpdatingAtPath:filePath]retain];
			
			// [currentConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
			[currentConnection start];
			if (viewIsVisible) {
				[self scheduleDownloadUpdateTimer];
			}
		}
	}
	if ([theTabBarController.tabBar.items count] > downloadsTabIndex) {
		UITabBarItem *item = [theTabBarController.tabBar.items objectAtIndex:downloadsTabIndex];
		
		// [self fetchDownloads];
		
		NSInteger badgeValue = [[[self downloadFetchedResultsController]fetchedObjects]count];
		if (badgeValue > 0) {
			[item setBadgeValue:[NSString stringWithFormat:kBadgeFormatStr, badgeValue]];
			[[UIApplication sharedApplication]setApplicationIconBadgeNumber:badgeValue];
		}
		else {
			[item setBadgeValue:nil];
			[[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
		}
	}
}

- (void)scheduleDownloadUpdateTimer {
	if ((!downloadUpdateTimer) || ((downloadUpdateTimer) && (![downloadUpdateTimer isValid]))) {
		[self updateDownloads];
		downloadUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_INTERVAL target:self selector:@selector(updateDownloads) userInfo:nil repeats:YES];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if ([connection isEqual:currentConnection]) {
		if ([response expectedContentLength] > 0) {
			// [receivedData setLength:0];
			// currentFileSize = 0;
			
			CGFloat expectedSize = [[NSNumber numberWithLongLong:[response expectedContentLength]]floatValue];
			NSDecimalNumber *expectedMBSize = [[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:kFloatFormatSpecifierStr, (expectedSize / MB_FLOAT_SIZE)]]decimalNumberByRoundingAccordingToBehavior:decimalNumberHandler];
			[currentDownload setValue:expectedMBSize forKey:kExpectedSizeKey];
		}
		else {
			[self connectionDidFail];
			
			/*
			 UIAlertView *errorAlert = [[UIAlertView alloc]
			 initWithTitle:@"Download Failed"
			 message:@"Zero download size. Please check your Internet connection status and try again."
			 delegate:nil
			 cancelButtonTitle:@"OK"
			 otherButtonTitles:nil];
			 [errorAlert show];
			 [errorAlert release];
			 */
		}
	}
	else {
		[connection cancel];
		
		if ([(NSHTTPURLResponse *)response statusCode] == SUCCEEDED_STATUS_CODE) {
			[self fileCheckSucceeded];
		}
		else {
			[self fileCheckDidFail];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
	currentFileSize += [data length];
	if ([receivedData length] >= DATA_WRITE_LENGTH) {
		// [currentFileHandle seekToEndOfFile];
		[currentFileHandle writeData:receivedData];
		[receivedData release];
		receivedData = [[NSMutableData alloc]initWithLength:0];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if ([connection isEqual:currentConnection]) {
		[self connectionDidFail];
		
		/*
		UIAlertView *errorAlert = [[UIAlertView alloc]
		 initWithTitle:@"Download Error"
		 message:[NSString stringWithFormat:@"Download failed. Please check your Internet connection status and try again. The error was:\n%@", [[error userInfo]objectForKey:NSLocalizedDescriptionKey]]
		 delegate:nil
		 cancelButtonTitle:@"OK"
		 otherButtonTitles:nil];
		 [errorAlert show];
		 [errorAlert release];
		 */
	}
	else {
		[self fileCheckDidFail];
	}
}

- (void)downloadDidFinish {
	if ([[[self downloadFetchedResultsController]fetchedObjects]count] <= 1) {
		if (downloadUpdateTimer) {
			[downloadUpdateTimer invalidate];
			downloadUpdateTimer = nil;
		}
	}
	/*
	if (currentDownload) {
		// [currentDownload release];
		currentDownload = nil;
	}
	*/
	if (currentConnection) {
		[currentConnection cancel];
		[currentConnection release];
		currentConnection = nil;
	}
	if ((receivedData) && ([receivedData length] > 0) && (currentFileHandle)) {
		[currentFileHandle writeData:receivedData];
		[receivedData release];
		receivedData = nil;
		
		[currentFileHandle closeFile];
		[currentFileHandle release];
		currentFileHandle = nil;
	}
	else if (currentFileHandle) {
		[currentFileHandle closeFile];
		[currentFileHandle release];
		currentFileHandle = nil;
	}
}

- (void)connectionDidFail {
	[self fetchDownloads];
	[self downloadDidFinish];
	
	NSString *filePath = [[self applicationDataStorageDirectory]stringByAppendingPathComponent:[[currentDownload valueForKey:kFileNameKey]stringByAppendingPathExtension:kDownloadPathExtensionStr]];
	[[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
	
	if (!isRunningInBackground) {
		[self downloadDidFail:[[[self downloadFetchedResultsController]fetchedObjects]objectAtIndex:0]];
	}
}

- (void)downloadDidFail:(NSManagedObject *)download {
	[download setValue:[NSNumber numberWithInteger:kDownloadStateFailed] forKey:kStateKey];
	[download setValue:[NSNumber numberWithInteger:0] forKey:kSizeKey];
	
	NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	
	// Save the context.
	NSError *error = nil;
	if (![context save:&error]) {
		[self abortWithError:error];
	}
	
	[self updateCurrentDownload];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self updateDownloads];
	
	[self fetchDownloads];
	[self downloadDidFinish];
	
	NSString *downloadPath = [[self applicationDataStorageDirectory]stringByAppendingPathComponent:[[currentDownload valueForKey:kFileNameKey]stringByAppendingPathExtension:kDownloadPathExtensionStr]];
	CGFloat finalSize = [[[[NSFileManager defaultManager]attributesOfItemAtPath:downloadPath error:nil]objectForKey:NSFileSize]floatValue];
	NSDecimalNumber *finalMBSize = [[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:kFloatFormatSpecifierStr, (finalSize / MB_FLOAT_SIZE)]]decimalNumberByRoundingAccordingToBehavior:decimalNumberHandler];
	[currentDownload setValue:finalMBSize forKey:kSizeKey];
	// [currentDownload setValue:kProcessingStr forKey:kSubtitleKey];
	
	NSMutableString *fileName = [NSMutableString stringWithString:[currentDownload valueForKey:kFileNameKey]];
	if ([[NSFileManager defaultManager]fileExistsAtPath:[[[self applicationDocumentsDirectory]stringByAppendingPathComponent:fileName]stringByAppendingPathExtension:kFilePathExtensionStr]]) {
		NSInteger copyNumber = 2;
		while ([[NSFileManager defaultManager]fileExistsAtPath:[[[self applicationDocumentsDirectory]stringByAppendingPathComponent:[NSString stringWithFormat:kFileCopyStr, fileName, copyNumber]]stringByAppendingPathExtension:kFilePathExtensionStr]]) {
			copyNumber += 1;
		}
		[fileName setString:[NSString stringWithFormat:kFileCopyStr, fileName, copyNumber]];
	}
	NSString *destinationPath = [[self applicationDocumentsDirectory]stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:kFilePathExtensionStr]];
	
	[[NSFileManager defaultManager]moveItemAtPath:downloadPath toPath:destinationPath error:nil];
	
	// Create a new instance of the entity managed by the fetched results controller.
	
	NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:kVideoEntityName inManagedObjectContext:context];
	
	[newManagedObject setValue:fileName forKey:kFileNameKey];
	
	// If appropriate, configure the new managed object.
	for (NSString *key in [NSArray arrayWithObjects:kDurationKey, kQualityKey, kSizeKey, kSubmitterKey, kThumbnailKey, kTitleKey, kVideoIDKey, nil]) {
		[newManagedObject setValue:[currentDownload valueForKey:key] forKey:key];
	}
	
	[context deleteObject:currentDownload];
	currentDownload = nil;
	
	// Save the context.
	NSError *error = nil;
	if (![context save:&error]) {
		[self abortWithError:error];
	}
	
	if ((isRunningInBackground) && ([[NSUserDefaults standardUserDefaults]boolForKey:kDownloadAlertsKey])) {
		[[UIApplication sharedApplication]cancelAllLocalNotifications];
		UILocalNotification *notification = [[UILocalNotification alloc]init];
		notification.alertBody = [@"The following video has finished downloading:\n" stringByAppendingString:[newManagedObject valueForKey:kTitleKey]];
		notification.alertAction = @"View";
		notification.fireDate = [NSDate date];
		notification.soundName = UILocalNotificationDefaultSoundName;
		// [notification.userInfo setValue:newManagedObject forKey:kNotificationVideoKey];
		[[UIApplication sharedApplication]presentLocalNotificationNow:notification];
		[notification release];
	}
}

- (void)updateDownloads {
	if ((currentDownload) && (currentConnection) && (receivedData) && (currentFileHandle)) {
		// NSString *downloadPath = [[self applicationDataStorageDirectory]stringByAppendingPathComponent:[[currentDownload valueForKey:kFileNameKey]stringByAppendingPathExtension:kDownloadPathExtensionStr]];
		// CGFloat currentSize = [[[[NSFileManager defaultManager]attributesOfItemAtPath:downloadPath error:nil]objectForKey:NSFileSize]floatValue];
		// CGFloat expectedSize = [[NSNumber numberWithLongLong:[currentResponse expectedContentLength]]floatValue];
		NSDecimalNumber *currentMBSize = [[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:kFloatFormatSpecifierStr, (currentFileSize / MB_FLOAT_SIZE)]]decimalNumberByRoundingAccordingToBehavior:decimalNumberHandler];
		// NSDecimalNumber *expectedMBSize = [[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:kFloatFormatSpecifierStr, (expectedFileSize / MB_FLOAT_SIZE)]]decimalNumberByRoundingAccordingToBehavior:decimalNumberHandler];
		[currentDownload setValue:currentMBSize forKey:kSizeKey];
		// [currentDownload setValue:expectedMBSize forKey:kExpectedSizeKey];
	}
}

- (NSString *)stringFromDecimalNumber:(NSDecimalNumber *)decimalNumber {
	NSMutableString *formattedDecimalNumber = [NSMutableString stringWithFormat:kStringFormatSpecifierStr, decimalNumber];
	if ([formattedDecimalNumber rangeOfString:kDecimalStr].length > 0) {
		if ([[[formattedDecimalNumber componentsSeparatedByString:kDecimalStr]lastObject]length] < 2) {
			[formattedDecimalNumber appendString:kTenthAppendStr];
		}
	}
	else {
		[formattedDecimalNumber appendString:kWholeNumberAppendStr];
	}
	/*
	if ([formattedDecimalNumber rangeOfString:kDecimalStr].length <= 0) {
		[formattedDecimalNumber appendString:kWholeNumberAppendStr];
	}
	*/
	return [NSString stringWithString:formattedDecimalNumber];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)configureCell:(DownloadCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	if ([[[self fetchedResultsController]fetchedObjects]count] > indexPath.row) {
		NSManagedObject *download = [fetchedResultsController objectAtIndexPath:indexPath];
		cell.titleLabel.text = [download valueForKey:kTitleKey];
		cell.durationLabel.text = [download valueForKey:kDurationKey];
		cell.qualityLabel.text = [MetadataLoader stringForQuality:[[download valueForKey:kQualityKey]integerValue]];
		cell.submitterLabel.text = [download valueForKey:kSubmitterKey];
		NSInteger state = [[download valueForKey:kStateKey]integerValue];
		if ((state == kDownloadStateInProgress) || (state == kDownloadStatePending)) {
			if (/* [download isEqual:currentDownload] */ state == kDownloadStateInProgress) {
				if (([[self stringFromDecimalNumber:[download valueForKey:kSizeKey]]floatValue] > 0) && ([[self stringFromDecimalNumber:[download valueForKey:kExpectedSizeKey]]floatValue] > 0)) {
					cell.progressLabel.text = [NSString stringWithFormat:kProgressFormatStr, [self stringFromDecimalNumber:[download valueForKey:kSizeKey]], [self stringFromDecimalNumber:[download valueForKey:kExpectedSizeKey]]];
					cell.progressView.progress = ([[download valueForKey:kSizeKey]floatValue] / [[download valueForKey:kExpectedSizeKey]floatValue]);
				}
				else {
					cell.progressLabel.text = kStartingDownloadStr;
					cell.progressView.progress = 0;
				}
			}
			else {
				cell.progressLabel.text = kWaitingStr;
				cell.progressView.progress = 0;
			}
			cell.progressLabel.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
		}
		else {
			if (state == kDownloadStateCanceled) {
				cell.progressLabel.text = kCanceledStr;
				cell.progressLabel.textColor = [UIColor blackColor];
			}
			else {
				cell.progressLabel.text = kFailedStr;
				cell.progressLabel.textColor = [UIColor colorWithRed:FAILED_COLOR_RED green:FAILED_COLOR_GREEN blue:FAILED_COLOR_BLUE alpha:1];
			}
			cell.progressView.progress = 0;
		}
		cell.thumbnailImageView.image = [UIImage imageWithData:[[[self fetchedResultsController]objectAtIndexPath:indexPath]valueForKey:kThumbnailKey]];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
}

- (void)downloadVideo:(Video *)video atURL:(NSString *)url quality:(kVideoDefinition)quality {
	Video *videoCopy = [[Video alloc]init];
	videoCopy.videoID = video.videoID;
	videoCopy.title = video.title;
	// videoCopy.thumbnailURL = video.thumbnailURL;
	videoCopy.thumbnailData = video.thumbnailData;
	// videoCopy.ratingCount = video.ratingCount;
	// videoCopy.percentRating = video.percentRating;
	// videoCopy.viewCount = video.viewCount;
	videoCopy.duration = video.duration;
	videoCopy.submitter = video.submitter;
	// videoCopy.metadata = video.metadata;
	// videoCopy.index = video.index;
	
	NSMutableString *fileName = [NSMutableString stringWithString:videoCopy.title];
    for (int i = 0; i < ([kFileNameReplacementStringsArray count] / 2.0); i++) {
		[fileName setString:[fileName stringByReplacingOccurrencesOfString:[kFileNameReplacementStringsArray objectAtIndex:(i * 2)] withString:[kFileNameReplacementStringsArray objectAtIndex:((i * 2) + 1)]]];
	}
	if ([[NSFileManager defaultManager]fileExistsAtPath:[[[self applicationDataStorageDirectory]stringByAppendingPathComponent:fileName]stringByAppendingPathExtension:kDownloadPathExtensionStr]]) {
		NSInteger copyNumber = 2;
		while ([[NSFileManager defaultManager]fileExistsAtPath:[[[self applicationDataStorageDirectory]stringByAppendingPathComponent:[NSString stringWithFormat:kFileCopyStr, fileName, copyNumber]]stringByAppendingPathExtension:kDownloadPathExtensionStr]]) {
			copyNumber += 1;
		}
		[fileName setString:[NSString stringWithFormat:kFileCopyStr, fileName, copyNumber]];
	}
	
	// Create a new instance of the entity managed by the fetched results controller.
	
	NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	NSEntityDescription *entity = [[fetchedResultsController fetchRequest]entity];
	NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
	
	// If appropriate, configure the new managed object.
	[newManagedObject setValuesForKeysWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
													  [NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()], kCreationTimeKey,
													  url, kDownloadURLKey,
													  videoCopy.duration, kDurationKey,
													  fileName, kFileNameKey,
													  [NSNumber numberWithInteger:quality], kQualityKey,
													  [NSNumber numberWithInteger:([[[self fetchedResultsController]fetchedObjects]count] <= 0) ? kDownloadStateInProgress : kDownloadStatePending], kStateKey,
													  videoCopy.submitter, kSubmitterKey,
													  videoCopy.thumbnailData, kThumbnailKey,
													  videoCopy.title, kTitleKey,
													  videoCopy.videoID, kVideoIDKey,
													  nil]];
	
	// Save the context.
	NSError *error = nil;
	if (![context save:&error]) {
		[self abortWithError:error];
	}
	
	[videoCopy release];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	if (tableView.tag == 0) {
		return [[fetchedResultsController sections]count];
	}
	else {
		return 1;
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections]objectAtIndex:section];
	NSInteger numberOfObjects = [sectionInfo numberOfObjects];
	return numberOfObjects;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ROW_HEIGHT;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	DownloadCell *cell = (DownloadCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[DownloadCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
	}
	
	// Configure the cell...
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the managed object for the given index path
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error = nil;
		if (![context save:&error]) {
			[self abortWithError:error];
		}
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


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
	 // ...
	 // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	pendingIndexPath = [indexPath retain];
	NSManagedObject *download = [[self fetchedResultsController]objectAtIndexPath:indexPath];
	NSInteger state = [[download valueForKey:kStateKey]integerValue];
	if ((state == kDownloadStateInProgress) || (state == kDownloadStatePending)) {
		UIActionSheet *cancelDownloadActionSheet = [[UIActionSheet alloc]
													initWithTitle:[download valueForKey:kTitleKey]
													delegate:self
													cancelButtonTitle:@"Cancel"
													destructiveButtonTitle:@"Remove Download"
													otherButtonTitles:@"Cancel Download", nil];
		cancelActionSheet = cancelDownloadActionSheet;
		cancelDownloadActionSheet.tag = 0;
		cancelDownloadActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		[cancelDownloadActionSheet showInView:theTabBarController.view];
		[cancelDownloadActionSheet release];
	}
	else if (state == kDownloadStateCanceled) {
		UIActionSheet *cancelDownloadActionSheet = [[UIActionSheet alloc]
													initWithTitle:[download valueForKey:kTitleKey]
													delegate:self
													cancelButtonTitle:@"Cancel"
													destructiveButtonTitle:@"Remove Download"
													otherButtonTitles:@"Restart Download", nil];
		cancelActionSheet = cancelDownloadActionSheet;
		cancelDownloadActionSheet.tag = 1;
		cancelDownloadActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		[cancelDownloadActionSheet showInView:theTabBarController.view];
		[cancelDownloadActionSheet release];
	}
	else {
		UIActionSheet *cancelDownloadActionSheet = [[UIActionSheet alloc]
													initWithTitle:[download valueForKey:kTitleKey]
													delegate:self
													cancelButtonTitle:@"Cancel"
													destructiveButtonTitle:@"Remove Download"
													otherButtonTitles:@"Retry Download", nil];
		cancelActionSheet = cancelDownloadActionSheet;
		cancelDownloadActionSheet.tag = 1;
		cancelDownloadActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		[cancelDownloadActionSheet showInView:theTabBarController.view];
		[cancelDownloadActionSheet release];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ((actionSheet.tag == 0) || (actionSheet.tag == 1)) {
		if (cancelActionSheet) {
			cancelActionSheet = nil;
		}
		if (buttonIndex == actionSheet.cancelButtonIndex) {
			[pendingIndexPath release];
			pendingIndexPath = nil;
		}
		else {
			if (actionSheet.tag == 0) {
				if (buttonIndex == 0) {
					[self didRemoveDownloadAtIndexPath:pendingIndexPath];
				}
				else {
					[self didCancelDownloadAtIndexPath:pendingIndexPath];
				}
				
				[pendingIndexPath release];
				pendingIndexPath = nil;
			}
			else {
				if (buttonIndex == 0) {
					[self didRemoveDownloadAtIndexPath:pendingIndexPath];
					
					[pendingIndexPath release];
					pendingIndexPath = nil;
				}
				else {
					if ([networkStatusChangeNotifier currentNetworkStatus] == kNetworkStatusNotConnected) {
						[self displayCannotConnectAlert:NO];
						
						[pendingIndexPath release];
						pendingIndexPath = nil;
					}
					else {
						[self didRestartDownloadAtIndexPath:pendingIndexPath];
					}
				}
			}
		}
	}
	else if (actionSheet.tag <= 4) {
		if (actionSheet.tag == 2) {
			if (buttonIndex == actionSheet.cancelButtonIndex) {
				if (pendingVideoTitle) {
					[pendingVideoTitle release];
					pendingVideoTitle = nil;
				}
				if (pendingVideoID) {
					[pendingVideoID release];
					pendingVideoID = nil;
				}
			}
			else {
				if (buttonIndex == 0) {
					UIActionSheet *viewInSafariActionSheet = [[UIActionSheet alloc]
															  initWithTitle:@"You will be transferred to the Safari app in order to view this video on the YouTube\nmobile website."
															  delegate:self
															  cancelButtonTitle:@"Cancel"
															  destructiveButtonTitle:nil
															  otherButtonTitles:@"View in Safari", nil];
					viewInSafariActionSheet.tag = 3;
					[viewInSafariActionSheet showInView:theTabBarController.view];
					[viewInSafariActionSheet release];
				}
				else {
					UIActionSheet *sharingOptionsActionSheet = [[UIActionSheet alloc]
																initWithTitle:@"Share"
																delegate:self
																cancelButtonTitle:@"Cancel"
																destructiveButtonTitle:nil
																otherButtonTitles:@"Facebook", @"Twitter", @"Email", nil];
					sharingOptionsActionSheet.tag = 4;
					[sharingOptionsActionSheet showInView:theTabBarController.view];
					[sharingOptionsActionSheet release];
				}
			}
		}
		else {
			if (buttonIndex != actionSheet.cancelButtonIndex) {
				if (actionSheet.tag == 3) {
					NSURL *request = [NSURL URLWithString:[kSafariOpenURLStr stringByAppendingString:pendingVideoID]];
					if ([[UIApplication sharedApplication]canOpenURL:request]) {
						[[UIApplication sharedApplication]openURL:request];
					}
					else {
						UIAlertView *cannotLaunchSafariAlert = [[UIAlertView alloc]
																initWithTitle:@"Cannot Launch Safari"
																message:@"Your request could not be completed due to the restrictions on your device. Please enable the Safari application and try again.\n(Launch the Settings app, select General > Restrictions, and turn on the \"Safari\" switch.)"
																delegate:nil
																cancelButtonTitle:@"OK"
																otherButtonTitles:nil];
						[cannotLaunchSafariAlert show];
						[cannotLaunchSafariAlert release];
					}
				}
				else if (actionSheet.tag == 4) {
					if (buttonIndex == 2) {
						[self emailVideo];
					}
					else {
						if ([networkStatusChangeNotifier currentNetworkStatus] == kNetworkStatusNotConnected) {
							UIAlertView *noInternetConnectionAlert = [[UIAlertView alloc]
																	  initWithTitle:@"No Internet Connection"
																	  message:[(buttonIndex == 0) ? @"Facebook" : @"Twitter" stringByAppendingString:@" requires an Internet connection. Please connect to the Internet and try again."]
																	  delegate:nil
																	  cancelButtonTitle:@"OK"
																	  otherButtonTitles:nil];
							[noInternetConnectionAlert show];
							[noInternetConnectionAlert release];
						}
						else {
							if (buttonIndex == 0) {
								NSString *link = [kFacebookPostPrefixStr stringByAppendingString:pendingVideoID];
								[facebook dialog:@"feed" andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Check out this video on YouTube.", @"message", pendingVideoTitle, @"name", link, @"link", link, @"description", nil] andDelegate:self];
							}
							else if (buttonIndex == 1) {
								[self presentTwitterViewWithMessage:[kTwitterPostPrefixStr stringByAppendingString:pendingVideoID]];
							}
						}
					}
				}
			}
			if (pendingVideoTitle) {
				[pendingVideoTitle release];
				pendingVideoTitle = nil;
			}
			if (pendingVideoID) {
				[pendingVideoID release];
				pendingVideoID = nil;
			}
		}
	}
	else if (buttonIndex != actionSheet.cancelButtonIndex) {
		massOperationInProgress = YES;
		NSFetchedResultsController *controller = [self fetchedResultsController];
		for (int i = 0; i < [[controller fetchedObjects]count]; i++) {
			[self didRemoveDownloadAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		}
		massOperationInProgress = NO;
		
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		
		// Save the context.
		NSError *error = nil;
		if (![context save:&error]) {
			[self abortWithError:error];
		}
		
		// Needed only to update the tab bar item badge. Fetches aren't necessarily required.
		
		[self updateCurrentDownload];
	}
}

- (void)didRemoveDownloadAtIndexPath:(NSIndexPath *)indexPath {
	if (!massOperationInProgress) {
		[self fetchDownloads];
	}
	
	NSArray *downloads = [[self downloadFetchedResultsController]fetchedObjects];
	if ([downloads count] > 0) {
		if ([[downloads objectAtIndex:0]isEqual:[[self fetchedResultsController]objectAtIndexPath:indexPath]]) {
			// [self fetchDownloads];
			[self downloadDidFinish];
			NSString *filePath = [[self applicationDataStorageDirectory]stringByAppendingPathComponent:[[currentDownload valueForKey:kFileNameKey]stringByAppendingPathExtension:kDownloadPathExtensionStr]];
			[[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
		}
	}
	
	NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	[context deleteObject:[[self fetchedResultsController]objectAtIndexPath:indexPath]];
	
	if (!massOperationInProgress) {
		// Save the context.
		NSError *error = nil;
		if (![context save:&error]) {
			[self abortWithError:error];
		}
	}
}

- (void)didCancelDownloadAtIndexPath:(NSIndexPath *)indexPath {
	BOOL isCurrentDownload = NO;
	
	NSManagedObject *download = [[self fetchedResultsController]objectAtIndexPath:indexPath];
	if ([download isEqual:currentDownload]) {
		if (!massOperationInProgress) {
			[self fetchDownloads];
		}
		[self downloadDidFinish];
		
		NSString *filePath = [[self applicationDataStorageDirectory]stringByAppendingPathComponent:[[currentDownload valueForKey:kFileNameKey]stringByAppendingPathExtension:kDownloadPathExtensionStr]];
		[[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
		
		isCurrentDownload = YES;
	}
	
	[download setValue:[NSNumber numberWithInteger:kDownloadStateCanceled] forKey:kStateKey];
	if (isCurrentDownload) {
		[download setValue:[NSNumber numberWithInteger:0] forKey:kSizeKey];
	}
	
	if (!massOperationInProgress) {
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		
		// Save the context.
		NSError *error = nil;
		if (![context save:&error]) {
			[self abortWithError:error];
		}
		
		if (isCurrentDownload) {
			[self updateCurrentDownload];
		}
	}
}

- (void)didRestartDownloadAtIndexPath:(NSIndexPath *)indexPath {
	UIView *rootView = rootViewController.view;
	// hud = [[HUDView alloc]initWithFrame:CGRectMake(0, 0, 161, 135)];
	hud = [[HUDView alloc]initWithFrame:CGRectMake(80, 158, 160, 135)];
	hud.delegate = self;
	hud.hudLabel.text = kHUDTitleStr;
	hud.hudSubtitleLabel.text = kHUDProcessingSubtitleStr;
	// hud.center = CGPointMake(rootView.center.x, (rootView.center.y - 20));
	[rootView addSubview:hud];
	[hud release];
	
	NSManagedObject *download = [[self fetchedResultsController]objectAtIndexPath:indexPath];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[download valueForKey:kDownloadURLKey]] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:FILE_REQUEST_TIMEOUT_INTERVAL];
	NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:NO];
	[connection start];
	[connection release];
	
	// [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}

- (void)fileCheckSucceeded {
	NSManagedObject *download = [[self fetchedResultsController]objectAtIndexPath:pendingIndexPath];
	
	[download setValue:[NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()] forKey:kCreationTimeKey];
	[download setValue:[NSNumber numberWithInteger:kDownloadStatePending] forKey:kStateKey];
	
	NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	
	// Save the context.
	NSError *error = nil;
	if (![context save:&error]) {
		[self abortWithError:error];
	}
	
	[self updateCurrentDownload];
	
	[self hideHUD];
	
	// [theTableView scrollToRowAtIndexPath:pendingIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
	
	[pendingIndexPath release];
	pendingIndexPath = nil;
}

- (void)fileCheckDidFail {
	theTabBarController.view.userInteractionEnabled = NO;
	theTableView.scrollsToTop = NO;
	
	Video *video = [[Video alloc]init];
	video.videoID = [[[self fetchedResultsController]objectAtIndexPath:pendingIndexPath]valueForKey:kVideoIDKey];
	
	dataLoader = [[DataLoader alloc]init];
	dataLoader.delegate = self;
	[dataLoader fetchDataForVideo:video loadType:kDataLoadTypeMetadata];
	// [dataLoader release];
	
	// [video release];
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
	hud.hudSubtitleLabel.text = kHUDCanceledSubtitleStr;
	[self hideHUD];
}

- (void)dataLoaderDidFetchDataForVideo:(Video *)video {
	NSManagedObject *download = [[self fetchedResultsController]objectAtIndexPath:pendingIndexPath];
	NSString *videoURL = [MetadataLoader urlForVideo:video metadata:video.metadata quality:[[download valueForKey:kQualityKey]integerValue]];
	if (videoURL) {
		[download setValue:videoURL forKey:kDownloadURLKey];
		[self fileCheckSucceeded];
	}
	else {
		UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle:@"Error"
								   message:@"An error occurred while parsing the metadata of this video. Please restart your device and try again."
								   delegate:nil
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert release];
	}
	
	[video release];
	
	[self hideHUD];
}

- (void)dataLoaderFetchDidFailForVideo:(Video *)video {
	[self downloadDidFail:[[self fetchedResultsController]objectAtIndexPath:pendingIndexPath]];
	
	[video release];
	
	[self hideHUD];
}

- (void)hideHUD {
	theTabBarController.view.userInteractionEnabled = YES;
	theTableView.scrollsToTop = YES;
	hud.userInteractionEnabled = NO;
	[UIView beginAnimations:@"Fade Out" context:nil];
	[UIView setAnimationDuration:0.25];
	hud.alpha = 0;
	[UIView commitAnimations];
	hud = nil;
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
	
	if (fetchedResultsController != nil) {
		return fetchedResultsController;
	}
	
	/*
	 Set up the fetched results controller.
	 */
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:kDownloadEntityName inManagedObjectContext:[self managedObjectContext]];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:[NSSortDescriptor sortDescriptorWithKey:kStateKey ascending:YES], [NSSortDescriptor sortDescriptorWithKey:kCreationTimeKey ascending:YES], nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:kCacheNameStr];
	aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	[fetchedResultsController retain];
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}


#pragma mark -
#pragma mark Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[theTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[theTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[theTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
		{
			if (cancelActionSheet) {
				[cancelActionSheet dismissWithClickedButtonIndex:1 animated:YES];
				cancelActionSheet = nil;
			}
            [theTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
            break;
            
        case NSFetchedResultsChangeDelete:
		{
			if (cancelActionSheet) {
				[cancelActionSheet dismissWithClickedButtonIndex:cancelActionSheet.cancelButtonIndex animated:YES];
				cancelActionSheet = nil;
			}
            [theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
            break;
            
        case NSFetchedResultsChangeUpdate:
		{
            [self configureCell:(DownloadCell *)[theTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
		}
            break;
			
        case NSFetchedResultsChangeMove:
            [theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [theTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
			[theTableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            break;
	}
	
	if (((type == NSFetchedResultsChangeInsert) || (type == NSFetchedResultsChangeDelete)) && (!massOperationInProgress)) {
		[self updateCurrentDownload];
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[theTableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	 // In the simplest, most efficient, case, reload the table view.
	 [theTableView reloadData];
}
*/

#pragma mark -

@end

