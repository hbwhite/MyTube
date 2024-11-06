//
//  ContainerViewController.m
//  MyTube
//
//  Created by Harrison White on 3/8/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "ContainerViewController.h"
#import "MyTubeAppDelegate.h"
#import "SearchViewController.h"
#import "TwitterPostViewController.h"
#import "HUDView.h"

#define PLAYBACK_TIME_OFFSET					2

static NSString *kMinimumAirPlayFirmwareVersion = @"4.3";

static NSString *kAutoReplayKey					= @"Auto Replay";

static NSString *kResumeVideosKey				= @"Resume Videos";

static NSString *kCurrentPlaybackTimeKey		= @"currentPlaybackTime";
static NSString *kFileNameKey					= @"fileName";

static NSString *kFilePathExtensionStr			= @"mp4";

@interface ContainerViewController ()

// @property (nonatomic) MPMoviePlaybackState pendingPlaybackState;

- (BOOL)isAirPlaySupported;
- (NSString *)applicationDocumentsDirectory;
- (void)loadStateDidChange:(NSNotification *)notification;
- (void)playbackStateDidChange:(NSNotification *)notification;
// - (void)nowPlayingItemDidChange:(NSNotification *)notification;
// - (void)airPlayVideoActivityDidChange:(NSNotification *)notification;
- (void)playbackDidFinish:(NSNotification *)notification;

@end

@implementation ContainerViewController

@synthesize delegate;
@synthesize player;
@synthesize pendingEntity;
// @synthesize pendingPlaybackState;
@synthesize lastPlaybackState;
@synthesize didCancel;

- (void)playVideoForEntity:(NSManagedObject *)entity {
	pendingEntity = entity;
	NSURL *videoURL = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory]stringByAppendingPathComponent:[[entity valueForKey:kFileNameKey]stringByAppendingPathExtension:kFilePathExtensionStr]]];
	CGFloat currentPlaybackTime = 0;
	if ([[NSUserDefaults standardUserDefaults]boolForKey:kResumeVideosKey]) {
		currentPlaybackTime = [[entity valueForKey:kCurrentPlaybackTimeKey]floatValue];
	}
	[self playVideoAtURL:videoURL initialPlaybackTime:currentPlaybackTime];
}

- (void)playVideoAtURL:(NSURL *)url initialPlaybackTime:(CGFloat)initialPlaybackTime {
	if (didCancel) {
		didCancel = NO;
	}
	
	BOOL isInitialPlayback = NO;
	
	if (self.modalViewController) {
		[player.moviePlayer setContentURL:url];
	}
	else {
		isInitialPlayback = YES;
		player = [[MPMoviePlayerViewController alloc]initWithContentURL:url];
	}
	
	[player.moviePlayer prepareToPlay];
	
	[self setApplicableRepeatMode];
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	if ([self isAirPlaySupported]) {
		if ([url isFileURL]) {
			[player.moviePlayer setAllowsAirPlay:YES];
			// [notificationCenter addObserver:self selector:@selector(airPlayVideoActivityDidChange:) name:MPMoviePlayerIsAirPlayVideoActiveDidChangeNotification object:nil];
		}
		else if (!isInitialPlayback) {
			[player.moviePlayer setAllowsAirPlay:NO];
			// [notificationCenter removeObserver:self name:MPMoviePlayerIsAirPlayVideoActiveDidChangeNotification object:nil];
		}
	}
	
	if (isInitialPlayback) {
		[player.moviePlayer setShouldAutoplay:YES];
		// [player.moviePlayer setUseApplicationAudioSession:YES];
	}
	
	[player.moviePlayer setInitialPlaybackTime:initialPlaybackTime];
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	if (isInitialPlayback) {
		[audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
	}
	[audioSession setActive:YES error:nil];
	
	if ([url isFileURL]) {
		[player.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
		if (isInitialPlayback) {
			[self presentMoviePlayerViewControllerAnimated:player];
		}
	}
	else {
		[notificationCenter addObserver:self selector:@selector(loadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
	}
	[notificationCenter addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	// if (initialPlaybackTime > 0) {
		[notificationCenter addObserver:self selector:@selector(playbackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
	// }
	
	// [notificationCenter addObserver:self selector:@selector(nowPlayingItemDidChange:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	
	// [player autorelease];
}

- (BOOL)isAirPlaySupported {
	return (([[[UIDevice currentDevice]systemVersion]compare:kMinimumAirPlayFirmwareVersion] != NSOrderedAscending) && ([MPMoviePlayerViewController instancesRespondToSelector:@selector(setAllowsAirPlay:)]));
}

/*
- (void)removeControlReceivedWithEvent:(UIEvent *)receivedEvent {
	if (receivedEvent.type == UIEventTypeRemoteControl) {
		switch (receivedEvent.subtype) {
			case UIEventSubtypeRemoteControlNextTrack:
			{
				if ([player.moviePlayer.contentURL isFileURL]) {
					if (delegate) {
						if ([delegate respondsToSelector:@selector(entityForNextVideo:)]) {
							NSManagedObject *nextEntity = [delegate entityForNextVideo:pendingEntity];
							if (nextEntity) {
								[self playVideoForEntity:nextEntity];
							}
						}
					}
				}
			}
				break;
			case UIEventSubtypeRemoteControlPreviousTrack:
			{
				if ([player.moviePlayer.contentURL isFileURL]) {
					if (delegate) {
						if ([delegate respondsToSelector:@selector(entityForPreviousVideo:)]) {
							NSManagedObject *previousEntity = [delegate entityForPreviousVideo:pendingEntity];
							if (previousEntity) {
								[self playVideoForEntity:previousEntity];
							}
						}
					}
				}
			}
				break;
			case UIEventSubtypeRemoteControlPause:
				[player.moviePlayer pause];
				break;
			case UIEventSubtypeRemoteControlPlay:
				[player.moviePlayer play];
				break;
			case UIEventSubtypeRemoteControlStop:
				[player.moviePlayer stop];
				break;
			default:
				break;
		}
	}
}
*/

- (void)cancelPlayback {
	didCancel = YES;
	delegate = nil;
}

- (NSString *)applicationDocumentsDirectory {
	// return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	return @"/private/var/mobile/Media/MyTube/";
}

- (void)setApplicableRepeatMode {
	[player.moviePlayer setRepeatMode:([[NSUserDefaults standardUserDefaults]boolForKey:kAutoReplayKey]) ? MPMovieRepeatModeOne : MPMovieRepeatModeNone];
}

- (void)loadStateDidChange:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
	if (player.moviePlayer.loadState == MPMovieLoadStatePlayable) {
		if (didCancel) {
			didCancel = NO;
			[player.moviePlayer stop];
			[player release];
		}
		else {
			[self presentMoviePlayerViewControllerAnimated:player];
			
			[player.moviePlayer play];
			
			if (delegate) {
				if ([delegate respondsToSelector:@selector(moviePlayerDidLoadVideo)]) {
					[delegate moviePlayerDidLoadVideo];
				}
			}
		}
	}
	else {
		if (didCancel) {
			didCancel = NO;
			[player.moviePlayer stop];
			[player release];
		}
		else if (delegate) {
			if ([delegate respondsToSelector:@selector(moviePlayerDidFailLoad)]) {
				[delegate moviePlayerDidFailLoad];
			}
		}
	}
}

- (void)playbackStateDidChange:(NSNotification *)notification {
	if (![(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]isRunningInBackground]) {
		lastPlaybackState = player.moviePlayer.playbackState;
	}
	// lastPlaybackState = pendingPlaybackState;
	// pendingPlaybackState = player.moviePlayer.playbackState;
	
	// [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
	if ([player.moviePlayer initialPlaybackTime] != 0) {
		[player.moviePlayer setInitialPlaybackTime:0];
	}
}

/*
- (void)nowPlayingItemDidChange:(NSNotification *)notification {
	
}
*/

/*
- (void)airPlayVideoActivityDidChange:(NSNotification *)notification {
	if ([player.moviePlayer isAirPlayVideoActive]) {
		[player.moviePlayer setRepeatMode:MPMovieRepeatModeNone];
	}
	else {
		[self setApplicableRepeatMode];
	}
}
*/

- (void)playbackDidFinish:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	if ([[[notification userInfo]objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]integerValue] == MPMovieFinishReasonPlaybackError) {
		if ([player.moviePlayer.contentURL isFileURL]) {
			UIAlertView *errorAlert = [[UIAlertView alloc]
									   initWithTitle:@"Error"
									   message:@"The video could not be played because an unexpected error occurred. Please restart your device and try again. If this error persists, you may need to download the video again."
									   delegate:self
									   cancelButtonTitle:@"OK"
									   otherButtonTitles:nil];
			[errorAlert show];
			[errorAlert release];
		}
		else {
			UIAlertView *errorAlert = [[UIAlertView alloc]
									   initWithTitle:@"Error"
									   message:@"The video could not be played. This can be the result of a slow Internet connection, and you may be able to watch it after downloading it first."
									   delegate:self
									   cancelButtonTitle:@"OK"
									   otherButtonTitles:nil];
			[errorAlert show];
			[errorAlert release];
		}
		if (delegate) {
			if ([delegate isKindOfClass:[SearchViewController class]]) {
				if ([delegate respondsToSelector:@selector(hideHUDAnimated:)]) {
					[((SearchViewController *)delegate) hideHUDAnimated:YES];	
				}
			}
		}
	}
	else if (pendingEntity) {
		CGFloat playbackTime = 0;
		if ([[[notification userInfo]objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]integerValue] == MPMovieFinishReasonUserExited) {
			CGFloat currentPlaybackTime = [player.moviePlayer currentPlaybackTime];
			if ((currentPlaybackTime + PLAYBACK_TIME_OFFSET) < [player.moviePlayer duration]) {
				playbackTime = currentPlaybackTime;
			}
		}
		[pendingEntity setValue:[NSNumber numberWithFloat:playbackTime] forKey:kCurrentPlaybackTimeKey];
		pendingEntity = nil;
	}
	/*
	if ([[[notification userInfo]objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]integerValue] != MPMovieFinishReasonUserExited) {
		if ([player.moviePlayer.contentURL isFileURL]) {
			if (delegate) {
				if ([delegate respondsToSelector:@selector(entityForNextVideo:)]) {
					NSManagedObject *nextEntity = [delegate entityForNextVideo:pendingEntity];
					if (nextEntity) {
						[self playVideoForEntity:nextEntity];
					}
				}
			}
		}
	}
	*/
	
	[player release];
	
	// [[UIApplication sharedApplication]endReceivingRemoteControlEvents];
	// [self resignFirstResponder];
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	[audioSession setActive:NO error:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissMoviePlayerViewControllerAnimated];
}

- (void)viewWillAppear:(BOOL)animated {
	/*
	[[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
	*/
	
	MyTubeAppDelegate *appDelegate = (MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate];
	[appDelegate showBannerViewIfApplicable];
    [appDelegate.theTabBarController viewWillAppear:animated];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	MyTubeAppDelegate *appDelegate = (MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.pendingTwitterPostRequest) {
		appDelegate.pendingTwitterPostRequest = NO;
		[self presentTwitterPostView];
	}
	else {
		[appDelegate.theTabBarController viewDidAppear:animated];
	}
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]theTabBarController]viewWillDisappear:animated];
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	if (self.modalViewController) {
		if ([self.modalViewController isKindOfClass:[MPMoviePlayerViewController class]]) {
			if (delegate) {
				if ([delegate isKindOfClass:[SearchViewController class]]) {
					if ([delegate respondsToSelector:@selector(hideHUDAnimated:)]) {
						[((SearchViewController *)delegate) hideHUDAnimated:NO];	
					}
				}
			}
		}
		else if ([[UIApplication sharedApplication]isIgnoringInteractionEvents]) {
			[[UIApplication sharedApplication]endIgnoringInteractionEvents];
		}
	}
	MyTubeAppDelegate *appDelegate = (MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate];
	// This prevents ads from being refreshed in the background while a video is playing.
	appDelegate.bannerView.hidden = YES;
    [appDelegate.theTabBarController viewDidDisappear:animated];
	[super viewDidDisappear:animated];
}

- (void)presentTwitterPostView {
	MyTubeAppDelegate *appDelegate = (MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate];
	TwitterPostViewController *twitterPostViewController = [[TwitterPostViewController alloc]initWithNibName:@"TwitterPostViewController" bundle:nil];
	if (appDelegate.pendingTweet) {
		twitterPostViewController.message = [NSString stringWithString:appDelegate.pendingTweet];
		[appDelegate.pendingTweet release];
		appDelegate.pendingTweet = nil;
	}
	[self presentModalViewController:twitterPostViewController animated:YES];
	[twitterPostViewController release];
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	// pendingPlaybackState = MPMoviePlaybackStatePlaying;
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
