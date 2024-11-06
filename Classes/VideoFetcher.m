//
//  VideoFetcher.m
//  MyTube
//
//  Created by Harrison White on 6/3/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "VideoFetcher.h"

static NSString *kNullStr					= @"";
static NSString *kVideoEntryStr				= @"entry";
static NSString *kThumbnailURLEntryStr		= @"media:thumbnail";
static NSString *kThumbnailURLKey			= @"url";
static NSString *kRatingCountKey			= @"numRaters";
static NSString *kRatingEntryStr			= @"gd:rating";
static NSString *kRatingAverageKey			= @"average";
static NSString *kRatingMaxKey				= @"max";
static NSString *kRatingMinKey				= @"min";
static NSString *kDurationEntryStr			= @"yt:duration";
static NSString *kDurationKey				= @"seconds";
static NSString *kViewCountEntryStr			= @"yt:statistics";
static NSString *kViewCountKey				= @"viewCount";
static NSString *kIDStr						= @"id";
static NSString *kTitleStr					= @"title";
static NSString *kSubmitterStr				= @"name";

static NSString *kFloatFormatSpecifierStr	= @"%f";
static NSString *kFinalIDSeparatorStr		= @"/";

@interface VideoFetcher ()

@property (nonatomic, assign) Video *_currentVideo;
@property (nonatomic, assign) NSXMLParser *_feedParser;
@property (nonatomic, assign) NSMutableString *_content;
@property (nonatomic, assign) NSMutableArray *_pendingResults;
@property (nonatomic, assign) NSDecimalNumberHandler *_decimalNumberHandler;
@property (nonatomic) NSInteger _startIndex;
@property (readwrite) BOOL _contentIsPresent;

- (void)didFinishParsing:(NSError *)error;

@end

@implementation VideoFetcher

@synthesize delegate;

@synthesize _currentVideo;
@synthesize _feedParser;
@synthesize _content;
@synthesize _pendingResults;
@synthesize _decimalNumberHandler;
@synthesize _startIndex;
@synthesize _contentIsPresent;

- (id)init {
	_content = [[NSMutableString alloc]init];
	_pendingResults = [[NSMutableArray alloc]init];
	_decimalNumberHandler = [[NSDecimalNumberHandler alloc]
							 initWithRoundingMode:NSRoundPlain
							 scale:0
							 raiseOnExactness:YES
							 raiseOnOverflow:NO
							 raiseOnUnderflow:NO
							 raiseOnDivideByZero:NO];
	return self;
}

- (void)fetchVideosWithFeedURL:(NSString *)url startingAtIndex:(NSInteger)index {
	_startIndex = index;
	_feedParser = [[NSXMLParser alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
	[_feedParser setDelegate:self];
	[_feedParser parse];
	[_feedParser autorelease];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:kVideoEntryStr]) {
		// currentVideo = nil;
		_currentVideo = [Video alloc];
		_contentIsPresent = YES;
	}
	else if ([elementName isEqualToString:kThumbnailURLEntryStr]) {
		// if ([[attributeDict objectForKey:kThumbnailURLKey]hasSuffix:@"2.jpg"]) {
		if (!_currentVideo.thumbnailURL) {
			NSString *url = [attributeDict objectForKey:kThumbnailURLKey];
			if (url) {
				_currentVideo.thumbnailURL = url;
			}
		}
	}
	else if ([elementName isEqualToString:kRatingEntryStr]) {
		NSString *ratingCount = [attributeDict objectForKey:kRatingCountKey];
		if (ratingCount) {
			_currentVideo.ratingCount = [ratingCount integerValue];
		}
		NSString *average = [attributeDict objectForKey:kRatingAverageKey];
		if (average) {
			CGFloat averageFloat = [average floatValue];
			CGFloat max = 5;
			NSString *maxString = [attributeDict objectForKey:kRatingMaxKey];
			if (maxString) {
				CGFloat maxFloat = [maxString floatValue];
				if (maxFloat > 0) {
					max = maxFloat;
				}
			}
			CGFloat min = 1;
			NSString *minString = [attributeDict objectForKey:kRatingMinKey];
			if (minString) {
				CGFloat minFloat = [minString floatValue];
				if (minFloat > 0) {
					min = minFloat;
				}
			}
			_currentVideo.percentRating = [[[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:kFloatFormatSpecifierStr, (((averageFloat - min) / (max - min)) * 100)]]decimalNumberByRoundingAccordingToBehavior:_decimalNumberHandler]integerValue];
		}
	}
	else if ([elementName isEqualToString:kDurationEntryStr]) {
		NSString *secondsString = [attributeDict objectForKey:kDurationKey];
		if (secondsString) {
			NSInteger lengthInSeconds = [secondsString integerValue];
			NSInteger seconds = (lengthInSeconds % 60);
			NSInteger totalMinutes = ((lengthInSeconds - seconds) / 60.0);
			NSInteger minutes = (totalMinutes % 60);
			NSInteger hours = ((totalMinutes - minutes) / 60.0);
			_currentVideo.duration = [NSString stringWithFormat:@"%@%02i:%02i", (hours > 0) ? [NSString stringWithFormat:@"%i:", hours] : @"", minutes, seconds];
		}
	}
	else if ([elementName isEqualToString:kViewCountEntryStr]) {
		NSString *viewCount = [attributeDict objectForKey:kViewCountKey];
		if (viewCount) {
			_currentVideo.viewCount = [viewCount integerValue];
		}
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if ((_contentIsPresent) && (_content) && (string)) {
		[_content appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if (_currentVideo) {
		if ([elementName isEqualToString:kVideoEntryStr]) {
			_currentVideo.index = (_startIndex + [_pendingResults count]);
			[_pendingResults addObject:_currentVideo];
			// [currentVideo release];
			_currentVideo = nil;
			[_content setString:kNullStr];
			_contentIsPresent = NO;
		}
		else if ((_content) && ([_content length] > 0)) {
			if (([elementName isEqualToString:kIDStr]) && ([_content rangeOfString:kFinalIDSeparatorStr].length > 0)) {
				NSInteger videoIDLocation = ([_content rangeOfString:kFinalIDSeparatorStr options:NSBackwardsSearch].location + 1);
				_currentVideo.videoID = [NSString stringWithString:[_content substringWithRange:NSMakeRange(videoIDLocation, ([_content length] - videoIDLocation))]];
			}
			else if ([elementName isEqualToString:kTitleStr]) {
				_currentVideo.title = [NSString stringWithString:_content];
			}
			else if ([elementName isEqualToString:kSubmitterStr]) {
				_currentVideo.submitter = [NSString stringWithString:_content];
			}
			[_content setString:kNullStr];
		}
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	[self didFinishParsing:parseError];
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
	[self didFinishParsing:validationError];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[self didFinishParsing:nil];
}

- (void)cancel {
	if (_feedParser) {
		if ([_feedParser respondsToSelector:@selector(setDelegate:)]) {
			[_feedParser setDelegate:nil];
		}
		if ([_feedParser respondsToSelector:@selector(abortParsing)]) {
			[_feedParser abortParsing];
		}
	}
}

- (void)didFinishParsing:(NSError *)error {
	if (delegate) {
		if ([delegate respondsToSelector:@selector(videoFetcher:didLoadVideos:error:)]) {
			[delegate videoFetcher:self didLoadVideos:_pendingResults error:error];
		}
	}
	/*
	if (([pendingResults count] > 0) && ([results count] > 0)) {
		noAdditionalVideos = YES;
	}
	*/
}

- (void)dealloc {
	[_content release];
	[_pendingResults release];
	[_decimalNumberHandler release];
	[super dealloc];
}

@end
