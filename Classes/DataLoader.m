//
//  DataLoader.m
//  MyTube
//
//  Created by Harrison White on 6/8/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "DataLoader.h"
#import "Video.h"

@interface DataLoader ()

@property (nonatomic, assign) Video *_video;
@property (nonatomic, assign) ThumbnailLoader *thumbnailLoader;
@property (nonatomic, assign) MetadataLoader *metadataLoader;
@property (readwrite) BOOL didLoadThumbnail;
@property (readwrite) BOOL didLoadMetadata;

- (void)runDataCheck;

@end

@implementation DataLoader

@synthesize delegate;
@synthesize _video;
@synthesize thumbnailLoader;
@synthesize metadataLoader;
@synthesize didLoadThumbnail;
@synthesize didLoadMetadata;

- (void)fetchDataForVideo:(Video *)video loadType:(kDataLoadType)loadType {
	_video = video;
	if ((loadType == kDataLoadTypeAll) && (!video.thumbnailData)) {
		thumbnailLoader = [[ThumbnailLoader alloc]init];
		thumbnailLoader.delegate = self;
		[thumbnailLoader fetchThumbnailForVideo:video];
		[thumbnailLoader release];
	}
	else {
		didLoadThumbnail = YES;
	}
	if (video.metadata) {
		didLoadMetadata = YES;
	}
	else {
		metadataLoader = [[MetadataLoader alloc]init];
		metadataLoader.delegate = self;
		[metadataLoader fetchMetadataForVideo:video];
		[metadataLoader release];
	}
	[self runDataCheck];
}

- (void)cancelFetch {
	if (metadataLoader) {
		if ([metadataLoader respondsToSelector:@selector(setDelegate:)]) {
			[metadataLoader setDelegate:nil];
		}
		metadataLoader = nil;
	}
	if (thumbnailLoader) {
		if ([thumbnailLoader respondsToSelector:@selector(setDelegate:)]) {
			[thumbnailLoader setDelegate:nil];
		}
		thumbnailLoader = nil;
	}
}

- (void)thumbnailLoaderDidFinishFetchForThumbnailForVideo:(Video *)video {
	if (video.thumbnailData) {
		didLoadThumbnail = YES;
		[self runDataCheck];
	}
	else {
		if (metadataLoader) {
			if ([metadataLoader respondsToSelector:@selector(setDelegate:)]) {
				[metadataLoader setDelegate:nil];
			}
			metadataLoader = nil;
		}
		if (delegate) {
			if ([delegate respondsToSelector:@selector(dataLoaderFetchDidFailForVideo:)]) {
				[delegate dataLoaderFetchDidFailForVideo:_video];
			}
		}
	}
}

- (void)metadataLoaderDidFetchMetadataForVideo:(Video *)video {
	didLoadMetadata = YES;
	[self runDataCheck];
}

- (void)metadataLoaderFetchDidFailForVideo:(Video *)video {
	if (thumbnailLoader) {
		if ([thumbnailLoader respondsToSelector:@selector(setDelegate:)]) {
			[thumbnailLoader setDelegate:nil];
		}
		thumbnailLoader = nil;
	}
	if (delegate) {
		if ([delegate respondsToSelector:@selector(dataLoaderFetchDidFailForVideo:)]) {
			[delegate dataLoaderFetchDidFailForVideo:_video];
		}
	}
}

- (void)runDataCheck {
	if ((didLoadThumbnail) && (didLoadMetadata)) {
		if (delegate) {
			if ([delegate respondsToSelector:@selector(dataLoaderDidFetchDataForVideo:)]) {
				[delegate dataLoaderDidFetchDataForVideo:_video];
			}
		}
	}
}

@end
