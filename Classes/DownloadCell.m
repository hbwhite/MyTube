//
//  DownloadCell.m
//  MyTube
//
//  Created by Harrison White on 2/18/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "DownloadCell.h"

#define THUMBNAIL_SEPARATOR_COMMON_RGB_VALUE	(217.0 / 255.0)

@implementation DownloadCell

@synthesize thumbnailImageView;
@synthesize thumbnailSeparator;
@synthesize titleLabel;
@synthesize durationLabel;
@synthesize qualityLabel;
@synthesize submitterLabel;
@synthesize progressLabel;
@synthesize progressView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
        
		thumbnailImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 120, 90)];
		thumbnailImageView.contentMode = UIViewContentModeScaleToFill;
		[self addSubview:thumbnailImageView];
		
		thumbnailSeparator = [[UIView alloc]initWithFrame:CGRectMake(120, 0, 1, 90)];
		thumbnailSeparator.backgroundColor = [UIColor colorWithRed:THUMBNAIL_SEPARATOR_COMMON_RGB_VALUE green:THUMBNAIL_SEPARATOR_COMMON_RGB_VALUE blue:THUMBNAIL_SEPARATOR_COMMON_RGB_VALUE alpha:1];
		[self addSubview:thumbnailSeparator];
		
		titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 10, 190, 20)];
		titleLabel.font = [UIFont boldSystemFontOfSize:13];
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.highlightedTextColor = [UIColor whiteColor];
		[self addSubview:titleLabel];
        
        durationLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 30, 35, 20)];
		durationLabel.font = [UIFont boldSystemFontOfSize:13];
		durationLabel.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
		durationLabel.backgroundColor = [UIColor clearColor];
		durationLabel.highlightedTextColor = [UIColor whiteColor];
		[self addSubview:durationLabel];
        
        qualityLabel = [[UILabel alloc]initWithFrame:CGRectMake(165, 30, 65, 20)];
		qualityLabel.textAlignment = UITextAlignmentCenter;
		qualityLabel.font = [UIFont boldSystemFontOfSize:13];
		qualityLabel.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:1 alpha:1];
		qualityLabel.backgroundColor = [UIColor clearColor];
		qualityLabel.highlightedTextColor = [UIColor whiteColor];
		[self addSubview:qualityLabel];
		
		submitterLabel = [[UILabel alloc]initWithFrame:CGRectMake(230, 30, 90, 20)];
		submitterLabel.textAlignment = UITextAlignmentCenter;
		submitterLabel.font = [UIFont boldSystemFontOfSize:13];
        submitterLabel.textColor = [UIColor colorWithRed:1 green:0.25 blue:0 alpha:1];
		submitterLabel.backgroundColor = [UIColor clearColor];
        submitterLabel.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:submitterLabel];
        
        progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 50, 190, 20)];
        progressLabel.font = [UIFont boldSystemFontOfSize:12];
		progressLabel.backgroundColor = [UIColor clearColor];
        progressLabel.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:progressLabel];
        
		progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(130, 70, 180, 9)];
		[self addSubview:progressView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
	[super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

- (void)dealloc {
	[thumbnailImageView release];
	[thumbnailSeparator release];
	[titleLabel release];
	[durationLabel release];
    [qualityLabel release];
	[submitterLabel release];
    [progressLabel release];
	[progressView release];
    [super dealloc];
}

@end
