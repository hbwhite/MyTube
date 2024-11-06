//
//  ThumbnailLoader.m
//  MyTube
//
//  Created by Harrison White on 5/29/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "ThumbnailLoader.h"
#import "Video.h"
#import "VideoCell.h"

#define THUMBNAIL_LOAD_DELAY	0.2
#define THUMBNAIL_CACHE_SIZE	50

@interface ThumbnailLoader ()

@property (nonatomic, assign) Video *_video;
@property (nonatomic, assign) VideoCell *_cell;
@property (nonatomic, assign) UITableView *_tableView;
@property (nonatomic, assign) NSURLConnection *thumbnailConnection;
@property (nonatomic, assign) NSMutableData *thumbnailData;

@end

@implementation ThumbnailLoader

@synthesize delegate;
@synthesize _video;
@synthesize _cell;
@synthesize _tableView;
@synthesize thumbnailConnection;
@synthesize thumbnailData;

- (void)fetchThumbnailForVideo:(Video *)video withCell:(VideoCell *)cell inTableView:(UITableView *)tableView withResults:(NSArray *)results {
	if (delegate) {
		if ([delegate respondsToSelector:@selector(thumbnailLoaderDidStartFetchForThumbnailForVideo:)]) {
			[delegate thumbnailLoaderDidStartFetchForThumbnailForVideo:video];
		}
	}
	[NSThread sleepForTimeInterval:THUMBNAIL_LOAD_DELAY];
	if ([[tableView indexPathsForRowsInRect:CGRectMake(0, tableView.contentOffset.y, 320, 367)]containsObject:[NSIndexPath indexPathForRow:video.index inSection:0]]) {
		// if ((video) && (cell) && (tableView)) {
			_cell = cell;
			_tableView = tableView;
			[self fetchThumbnailForVideo:video];
			if (video.index >= THUMBNAIL_CACHE_SIZE) {
				NSInteger index = (video.index - THUMBNAIL_CACHE_SIZE);
				if ([results count] > index) {
					Video *theVideo = [results objectAtIndex:index];
					theVideo.thumbnailData = nil;
					theVideo.metadata = nil;
				}
			}
			if ([results count] > (video.index + THUMBNAIL_CACHE_SIZE)) {
				Video *theVideo = [results objectAtIndex:video.index];
				theVideo.thumbnailData = nil;
				theVideo.metadata = nil;
			}
		// }
	}
	else {
		[self didFinishFetchForThumbnailForVideo:video];
	}
}

- (void)fetchThumbnailForVideo:(Video *)video {
	_video = video;
	NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:video.thumbnailURL]];
	thumbnailData = [[NSMutableData alloc]init];
	thumbnailConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:NO];
	// [thumbnailConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[thumbnailConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
	[thumbnailConnection start];
	[request release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[thumbnailData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[thumbnailData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self didFinishFetchForThumbnailForVideo:_video];
	[connection release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (_video) {
		if ([_video respondsToSelector:@selector(setThumbnailData:)]) {
			_video.thumbnailData = thumbnailData;
			if ((_cell) && (_tableView)) {
				if ([[_tableView indexPathsForRowsInRect:CGRectMake(0, _tableView.contentOffset.y, 320, 367)]containsObject:[NSIndexPath indexPathForRow:_video.index inSection:0]]) {
					_cell.thumbnailImageView.image = [UIImage imageWithData:thumbnailData];
					[_cell setNeedsLayout];
				}
			}
		}
	}
	[self didFinishFetchForThumbnailForVideo:_video];
	[connection release];
	[thumbnailData release];
}

- (void)didFinishFetchForThumbnailForVideo:(Video *)video {
	if (delegate) {
		if ([delegate respondsToSelector:@selector(thumbnailLoaderDidFinishFetchForThumbnailForVideo:)]) {
			[delegate thumbnailLoaderDidFinishFetchForThumbnailForVideo:video];
		}
	}
}

/*
+ (void)loadThumbnailForVideo:(Video *)video withCell:(VideoCell *)cell {
	video.thumbnailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:video.thumbnailURL]];
	cell.thumbnailImageView.image = [UIImage imageWithData:video.thumbnailData];
	[cell setNeedsLayout];
}
*/

@end
