//
//  Video.m
//  MyTube
//
//  Created by Harrison White on 4/8/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "Video.h"

@implementation Video

@synthesize videoID;
@synthesize title;
@synthesize thumbnailURL;
@synthesize thumbnailData;
@synthesize percentRating;
@synthesize ratingCount;
@synthesize viewCount;
@synthesize duration;
@synthesize submitter;
@synthesize metadata;
@synthesize index;

- (void)dealloc {
	[videoID release];
	[title release];
	[thumbnailURL release];
	[thumbnailData release];
	[duration release];
	[submitter release];
	[metadata release];
	[super dealloc];
}

@end
