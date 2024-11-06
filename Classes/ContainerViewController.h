//
//  ContainerViewController.h
//  MyTube
//
//  Created by Harrison White on 3/8/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@protocol ContainerViewControllerDelegate;

@interface ContainerViewController : UIViewController <UIAlertViewDelegate> {
	id <ContainerViewControllerDelegate> delegate;
	MPMoviePlayerViewController *player;
	NSManagedObject *pendingEntity;
	// MPMoviePlaybackState pendingPlaybackState;
	MPMoviePlaybackState lastPlaybackState;
	BOOL didCancel;
}

@property (nonatomic, assign) id <ContainerViewControllerDelegate> delegate;
@property (nonatomic, assign) MPMoviePlayerViewController *player;
@property (nonatomic, assign) NSManagedObject *pendingEntity;
@property (nonatomic) MPMoviePlaybackState lastPlaybackState;
@property (readwrite) BOOL didCancel;

- (void)playVideoForEntity:(NSManagedObject *)entity;
- (void)playVideoAtURL:(NSURL *)url initialPlaybackTime:(CGFloat)initialPlaybackTime;
- (void)cancelPlayback;
- (void)setApplicableRepeatMode;
- (void)presentTwitterPostView;

@end

@protocol ContainerViewControllerDelegate <NSObject>

@optional

- (void)moviePlayerDidLoadVideo;
- (void)moviePlayerDidFailLoad;

/*
- (NSManagedObject *)entityForNextVideo:(NSManagedObject *)currentVideo;
- (NSManagedObject *)entityForPreviousVideo:(NSManagedObject *)currentVideo;
*/

@end
