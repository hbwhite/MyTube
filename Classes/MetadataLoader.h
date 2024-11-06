//
//  MetadataLoader.h
//  MyTube
//
//  Created by Harrison White on 5/29/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSearchIntegerSD					18
#define kSearchIntegerHD720p				22
#define kSearchIntegerHD1080p				37
// #define kSearchIntegerHD3072p			38

#define kSearchIntegerFormatSpecifierStr	@"%i"
#define kSearchStrPrefixStr					@"itag%3D"

#define kSearchStrSD						[kSearchStrPrefixStr stringByAppendingString:[NSString stringWithFormat:kSearchIntegerFormatSpecifierStr, kSearchIntegerSD]]
#define kSearchStrHD720p					[kSearchStrPrefixStr stringByAppendingString:[NSString stringWithFormat:kSearchIntegerFormatSpecifierStr, kSearchIntegerHD720p]]
#define kSearchStrHD1080p					[kSearchStrPrefixStr stringByAppendingString:[NSString stringWithFormat:kSearchIntegerFormatSpecifierStr, kSearchIntegerHD1080p]]
// #define kSearchStrHD3072p				[kSearchStrPrefixStr stringByAppendingString:[NSString stringWithFormat:kSearchIntegerFormatSpecifierStr, kSearchIntegerHD3072p]]

@class Video;

enum {
	kVideoDefinitionSD,
	kVideoDefinitionHD720p,
	kVideoDefinitionHD1080p/*,
	kVideoDefinitionHD3072p*/
};
typedef NSUInteger kVideoDefinition;

@protocol MetadataLoaderDelegate;

@interface MetadataLoader : NSObject {
	id <MetadataLoaderDelegate> delegate;
	Video *_video;
    NSURLConnection *metadataConnection;
	NSMutableData *_metadata;
	BOOL didFindMetadataBeginning;
}

@property (nonatomic, assign) id <MetadataLoaderDelegate> delegate;

- (void)fetchMetadataForVideo:(Video *)video;
+ (NSString *)urlForVideo:(Video *)video metadata:(NSString *)metadata quality:(kVideoDefinition)quality;
+ (NSString *)stringForQuality:(kVideoDefinition)quality;

@end

@protocol MetadataLoaderDelegate <NSObject>

@optional

- (void)metadataLoaderDidFetchMetadataForVideo:(Video *)video;
- (void)metadataLoaderFetchDidFailForVideo:(Video *)video;

@end
