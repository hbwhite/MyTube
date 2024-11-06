//
//  VideoFetcher.h
//  MyTube
//
//  Created by Harrison White on 6/3/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Video.h"

@protocol VideoFetcherDelegate;

@interface VideoFetcher : NSObject <NSXMLParserDelegate> {
	@public
    id <VideoFetcherDelegate> delegate;
	
	@private
	Video *_currentVideo;
	NSXMLParser *_feedParser;
    NSMutableString *_content;
	NSMutableArray *_pendingResults;
	NSDecimalNumberHandler *_decimalNumberHandler;
	NSInteger _startIndex;
	BOOL _contentIsPresent;
}

@property (nonatomic, assign) id <VideoFetcherDelegate> delegate;

- (void)fetchVideosWithFeedURL:(NSString *)url startingAtIndex:(NSInteger)index;
- (void)cancel;

@end

@protocol VideoFetcherDelegate <NSObject>

@optional

- (void)videoFetcher:(VideoFetcher *)videoFetcher didLoadVideos:(NSArray *)videos error:(NSError *)error;

@end
