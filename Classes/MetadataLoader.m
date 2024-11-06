//
//  MetadataLoader.m
//  MyTube
//
//  Created by Harrison White on 5/29/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "MetadataLoader.h"
#import "MyTubeAppDelegate.h"
#import "Video.h"

// "&fmt=18" may not be needed
// static NSString *kMetadataURLStr						= @"http://www.youtube.com/get_video_info?video_id=%@&fmt=18";
static NSString *kVideoURLStr							= @"http://www.youtube.com/watch?v=%@&fmt=18";

#define METADATA_MINIMUM_TRIM_LENGTH					389

#define INITIAL_DECODE_REPETITION_COUNT					2

#define kMetadataComponentSeparatorsArray				[NSArray arrayWithObjects:@"%2C", @",", nil]
#define kUnicodeReplacementStringsArray					[NSArray arrayWithObjects:@"\\u0026", @"&", nil]
#define kEncodingExemptVariablesArray					[NSArray arrayWithObjects:@"sparams", nil]

static NSString *kURLPrefixStr							= @"http";
static NSString *kVariablesBeginningStr					= @"?";
static NSString *kVariableSeparatorStr					= @"&";
static NSString *kURLKeyValueSeparatorStr				= @"=";

// Offsets of 389 chars
// static NSString *kMetadataStartStr					= @"flashvars=\"";
// static NSString *kMetadataStartStr					= @"flashvars";

// Offset of roughly 10000 chars
static NSString *kMetadataStartStr						= @"url_encoded_fmt_stream_map";

// static NSString *kMetadataEndStr						= @"&";
// static NSString *kMetadataEndStr						= @">";
static NSString *kMetadataEndStr						= @"&amp;";

static NSString *kSDTitleStr							= @"SD";
static NSString *kHD720pTitleStr						= @"720p HD";
static NSString *kHD1080pTitleStr						= @"1080p HD";
// static NSString *kHD3072pTitleStr					= @"3072p HD";

@interface MetadataLoader ()

@property (nonatomic, assign) Video *_video;
@property (nonatomic, assign) NSURLConnection *metadataConnection;
@property (nonatomic, assign) NSMutableData *_metadata;
@property (readwrite) BOOL didFindMetadataBeginning;

- (void)scanMetadata:(BOOL)setFlags;
- (void)didFetchMetadata;
- (void)fetchDidFail;
+ (NSString *)finalURLFromString:(NSString *)url;

@end

@implementation MetadataLoader

@synthesize delegate;
@synthesize _video;
@synthesize metadataConnection;
@synthesize _metadata;
@synthesize didFindMetadataBeginning;

- (void)fetchMetadataForVideo:(Video *)video {
	_video = video;
	NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:kVideoURLStr, video.videoID]]];
	_metadata = [[NSMutableData alloc]init];
	metadataConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:NO];
	// [thumbnailConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[metadataConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
	[metadataConnection start];
	[request release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[_metadata setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_metadata appendData:data];
	if ([_metadata length] >= METADATA_MINIMUM_TRIM_LENGTH) {
		[self scanMetadata:YES];
	}
}

- (void)scanMetadata:(BOOL)setFlags {
	BOOL shouldSearchForEnd = YES;
	NSMutableString *metadataString = [[NSMutableString alloc]initWithData:_metadata encoding:NSUTF8StringEncoding];
	if (!didFindMetadataBeginning) {
		NSRange metadataBeginningRange = [metadataString rangeOfString:kMetadataStartStr];
		if (metadataBeginningRange.length > 0) {
			[metadataString setString:[metadataString substringFromIndex:(metadataBeginningRange.location + [kMetadataStartStr length])]];
			if (setFlags) {
				[_metadata setData:[metadataString dataUsingEncoding:NSUTF8StringEncoding]];
				didFindMetadataBeginning = YES;
			}
		}
		else {
			shouldSearchForEnd = NO;
		}
	}
	BOOL didSetMetadata = NO;
	if (shouldSearchForEnd) {
		NSRange metadataEndRange = [metadataString rangeOfString:kMetadataEndStr];
		if (metadataEndRange.length > 0) {
			[metadataConnection cancel];
			[metadataConnection release];
			[_metadata release];
			_video.metadata = [metadataString substringToIndex:metadataEndRange.location];
			didSetMetadata = YES;
		}
	}
	if ((!didSetMetadata) && (!setFlags)) {
		_video.metadata = metadataString;
		didSetMetadata = YES;
	}
	if (didSetMetadata) {
		[self didFetchMetadata];
	}
	[metadataString release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self fetchDidFail];
	[connection release];
	[_metadata release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self scanMetadata:NO];
	[connection release];
	[_metadata release];
}

- (void)didFetchMetadata {
	if (delegate) {
		if ([delegate respondsToSelector:@selector(metadataLoaderDidFetchMetadataForVideo:)]) {
			[delegate metadataLoaderDidFetchMetadataForVideo:_video];
		}
	}
}

- (void)fetchDidFail {
	if (delegate) {
		if ([delegate respondsToSelector:@selector(metadataLoaderFetchDidFailForVideo:)]) {
			[delegate metadataLoaderFetchDidFailForVideo:_video];
		}
	}
}

+ (NSString *)urlForVideo:(Video *)video metadata:(NSString *)metadata quality:(kVideoDefinition)quality {
	NSString *searchString = nil;
	switch (quality) {
		case kVideoDefinitionSD:
			searchString = kSearchStrSD;
			break;
		case kVideoDefinitionHD720p:
			searchString = kSearchStrHD720p;
			break;
		case kVideoDefinitionHD1080p:
			searchString = kSearchStrHD1080p;
			break;
			/*
			 case kVideoDefinitionHD3072p:
			 searchString = kSearchStrHD3072p;
			 break;
			 */
		default:
			searchString = kSearchStrSD;
			break;
	}
	
	NSString *metadataString = [NSString stringWithContentsOfURL:[NSURL URLWithString:[@"http://www.youtube.com/get_video_info?video_id=" stringByAppendingString:video.videoID]] encoding:NSUTF8StringEncoding error:nil];
	if (metadataString) {
		NSArray *metadataComponents = [metadataString componentsSeparatedByString:@"&"];
		for (NSString *metadataComponent in metadataComponents) {
			NSString *decodedMetadataComponent = [metadataComponent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSRange equalsSignRange = [metadataComponent rangeOfString:@"="];
			
			if (equalsSignRange.length > 0) {
				if ([[[decodedMetadataComponent substringToIndex:equalsSignRange.location]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]isEqualToString:@"url_encoded_fmt_stream_map"]) {
					NSString *urlEncodedFMTStreamMap = [decodedMetadataComponent substringFromIndex:(equalsSignRange.location + 1)];
					NSArray *urlsArray = [urlEncodedFMTStreamMap componentsSeparatedByString:@","];
					for (NSString *urlString in urlsArray) {
						NSRange urlVariableSpecifierRange = [urlString rangeOfString:@"url="];
						
						if (urlVariableSpecifierRange.length > 0) {
							NSString *url = [urlString substringFromIndex:(urlVariableSpecifierRange.location + 4)];
							if ([url rangeOfString:searchString].length > 0) {
								NSString *finalURL = [self finalURLFromString:url];
								if (finalURL) {
									return finalURL;
								}
							}
							break;
						}
					}
					break;
				}
			}
		}
	}
	
	NSMutableString *url = [NSMutableString stringWithString:metadata];
	NSRange searchStringRange = [url rangeOfString:searchString];
	for (NSString *component in kMetadataComponentSeparatorsArray) {
		NSRange urlEndRange = [url rangeOfString:component options:NSLiteralSearch range:NSMakeRange(searchStringRange.location, ([url length] - searchStringRange.location))];
		if (urlEndRange.length > 0) {
			[url setString:[url substringToIndex:urlEndRange.location]];
			NSRange urlBeginningRange = [url rangeOfString:kURLPrefixStr options:NSBackwardsSearch range:NSMakeRange(0, [url length])];
			if (urlBeginningRange.length > 0) {
				[url setString:[url substringFromIndex:urlBeginningRange.location]];
				NSString *finalURL = [self finalURLFromString:url];
				if (finalURL) {
					return finalURL;
				}
			}
			break;
		}
	}
	
	return nil;
}

+ (NSString *)finalURLFromString:(NSString *)string {
	NSMutableString *url = [NSMutableString stringWithString:string];
	for (int i = 0; i < ([kUnicodeReplacementStringsArray count] / 2.0); i++) {
		[url setString:[url stringByReplacingOccurrencesOfString:[kUnicodeReplacementStringsArray objectAtIndex:(i * 2)] withString:[kUnicodeReplacementStringsArray objectAtIndex:((i * 2) + 1)]]];
	}
	for (int i = 0; i < 2; i++) {
		[url setString:[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	NSRange variablesBeginningRange = [url rangeOfString:kVariablesBeginningStr];
	if (variablesBeginningRange.length > 0) {
		NSInteger variablesBeginningIndex = (variablesBeginningRange.location + variablesBeginningRange.length);
		NSString *urlPrefix = [url substringToIndex:variablesBeginningIndex];
		NSString *variablesString = [url substringFromIndex:variablesBeginningIndex];
		
		BOOL signatureVariableFound = NO;
		NSString *sigVariable = nil;
		
		NSMutableArray *variablesArray = [NSMutableArray arrayWithArray:[variablesString componentsSeparatedByString:kVariableSeparatorStr]];
		for (int i = 0; i < [variablesArray count]; i++) {
			NSString *variable = [variablesArray objectAtIndex:i];
			NSRange keyValueSeparatorRange = [variable rangeOfString:kURLKeyValueSeparatorStr];
			NSString *key = [variable substringToIndex:keyValueSeparatorRange.location];
			
			if ([key isEqualToString:@"signature"]) {
				signatureVariableFound = YES;
			}
			else if ([key isEqualToString:@"sig"]) {
				sigVariable = [variable substringFromIndex:(keyValueSeparatorRange.location + 1)];
			}
			
			BOOL isEncodingExempt = NO;
			for (NSString *encodingExemptVariable in kEncodingExemptVariablesArray) {
				if ([key rangeOfString:encodingExemptVariable].length > 0) {
					isEncodingExempt = YES;
					break;
				}
			}
			if (!isEncodingExempt) {
				[variablesArray replaceObjectAtIndex:i withObject:[[variablesArray objectAtIndex:i]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			}
		}
		
		if ((!signatureVariableFound) && (sigVariable)) {
			[variablesArray addObject:[@"signature=" stringByAppendingString:sigVariable]];
		}
		
		NSSet *variablesSet = [NSSet setWithArray:variablesArray];
		NSArray *revisedVariablesArray = [variablesSet allObjects];
		NSString *revisedVariablesString = [revisedVariablesArray componentsJoinedByString:kVariableSeparatorStr];
		
		return [urlPrefix stringByAppendingString:revisedVariablesString];
	}
	
	return nil;
}

+ (NSString *)stringForQuality:(kVideoDefinition)quality {
    switch (quality) {
		case kVideoDefinitionSD:
            return kSDTitleStr;
            break;
		case kVideoDefinitionHD720p:
            return kHD720pTitleStr;
            break;
        case kVideoDefinitionHD1080p:
            return kHD1080pTitleStr;
            break;
			/*
		case kVideoDefinitionHD3072p:
			return kHD3072pTitleStr;
			break;
			*/
        default:
            return nil;
            break;
    }
}

@end
