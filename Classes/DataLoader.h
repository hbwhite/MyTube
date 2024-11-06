//
//  DataLoader.h
//  MyTube
//
//  Created by Harrison White on 6/8/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThumbnailLoader.h"
#import "MetadataLoader.h"

@class Video;

enum {
	kDataLoadTypeAll = 0,
	kDataLoadTypeMetadata
};
typedef NSUInteger kDataLoadType;

@protocol DataLoaderDelegate;

@interface DataLoader : NSObject <ThumbnailLoaderDelegate, MetadataLoaderDelegate> {
	id <DataLoaderDelegate> delegate;
	Video *_video;
	ThumbnailLoader *thumbnailLoader;
	MetadataLoader *metadataLoader;
    BOOL didLoadThumbnail;
	BOOL didLoadMetadata;
}

@property (nonatomic, assign) id <DataLoaderDelegate> delegate;

- (void)fetchDataForVideo:(Video *)video loadType:(kDataLoadType)loadType;
- (void)cancelFetch;

@end

@protocol DataLoaderDelegate <NSObject>

@optional

- (void)dataLoaderDidFetchDataForVideo:(Video *)video;
- (void)dataLoaderFetchDidFailForVideo:(Video *)video;

@end
