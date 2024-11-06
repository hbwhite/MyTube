//
//  Video.h
//  MyTube
//
//  Created by Harrison White on 4/8/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Video : NSObject {
	NSString *videoID;
	NSString *title;
	NSString *thumbnailURL;
	NSData *thumbnailData;
	NSInteger ratingCount;
	NSInteger percentRating;
	NSInteger viewCount;
	NSString *duration;
	NSString *submitter;
	NSString *metadata;
	NSInteger index;
}

@property (nonatomic, copy) NSString *videoID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *thumbnailURL;
@property (nonatomic, retain) NSData *thumbnailData;
@property (nonatomic) NSInteger ratingCount;
@property (nonatomic) NSInteger percentRating;
@property (nonatomic) NSInteger viewCount;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *submitter;
@property (nonatomic, copy) NSString *metadata;
@property (nonatomic) NSInteger index;

@end
