//
//  ThumbnailLoader.h
//  MyTube
//
//  Created by Harrison White on 5/29/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Video;
@class VideoCell;

@protocol ThumbnailLoaderDelegate;

@interface ThumbnailLoader : NSObject {
    id <ThumbnailLoaderDelegate> delegate;
	Video *_video;
	VideoCell *_cell;
	UITableView *_tableView;
	NSURLConnection *thumbnailConnection;
	NSMutableData *thumbnailData;
}

@property (nonatomic, assign) id <ThumbnailLoaderDelegate> delegate;

- (void)fetchThumbnailForVideo:(Video *)video withCell:(VideoCell *)cell inTableView:(UITableView *)tableView withResults:(NSArray *)results;
- (void)fetchThumbnailForVideo:(Video *)video;
- (void)didFinishFetchForThumbnailForVideo:(Video *)video;
// + (void)loadThumbnailForVideo:(Video *)video withCell:(VideoCell *)cell;

@end

@protocol ThumbnailLoaderDelegate <NSObject>

@optional

- (void)thumbnailLoaderDidStartFetchForThumbnailForVideo:(Video *)video;
- (void)thumbnailLoaderDidFinishFetchForThumbnailForVideo:(Video *)video;

@end
