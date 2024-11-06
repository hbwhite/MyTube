//
//  VideoCell.m
//  MyTube
//
//  Created by Harrison White on 4/9/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "VideoCell.h"

#define THUMBNAIL_SEPARATOR_COMMON_RGB_VALUE	(217.0 / 255.0)

@implementation VideoCell

@synthesize thumbnailImageView;
@synthesize thumbnailSeparator;
@synthesize titleLabel;
@synthesize thumbImageView;
@synthesize ratingPercentLabel;
@synthesize viewCountLabel;
@synthesize durationLabel;
@synthesize submitterLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
		thumbnailImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 120, 90)];
		thumbnailImageView.contentMode = UIViewContentModeScaleToFill;
		[self addSubview:thumbnailImageView];
		
		thumbnailSeparator = [[UIView alloc]initWithFrame:CGRectMake(120, 0, 1, 90)];
		thumbnailSeparator.backgroundColor = [UIColor colorWithRed:THUMBNAIL_SEPARATOR_COMMON_RGB_VALUE green:THUMBNAIL_SEPARATOR_COMMON_RGB_VALUE blue:THUMBNAIL_SEPARATOR_COMMON_RGB_VALUE alpha:1];
		[self addSubview:thumbnailSeparator];
		
		titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 6, 157, 33)];
		titleLabel.numberOfLines = 2;
		titleLabel.font = [UIFont boldSystemFontOfSize:13];
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.highlightedTextColor = [UIColor whiteColor];
		[self addSubview:titleLabel];
		
		thumbImageView = [[UIImageView alloc]initWithFrame:CGRectMake(130, 39, 20, 20)];
		[self addSubview:thumbImageView];
        
		ratingPercentLabel = [[UILabel alloc]initWithFrame:CGRectMake(150, 39, 33, 24)];
		ratingPercentLabel.font = [UIFont boldSystemFontOfSize:12];
		ratingPercentLabel.backgroundColor = [UIColor clearColor];
		ratingPercentLabel.highlightedTextColor = [UIColor whiteColor];
		[self addSubview:ratingPercentLabel];
		
		viewCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(183, 39, 104, 22)];
		viewCountLabel.font = [UIFont systemFontOfSize:12];
		viewCountLabel.textColor = [UIColor colorWithRed:(102.0 / 255.0) green:(109.0 / 255.0) blue:(116.0 / 255.0) alpha:1];
		viewCountLabel.backgroundColor = [UIColor clearColor];
		viewCountLabel.highlightedTextColor = [UIColor whiteColor];
		[self addSubview:viewCountLabel];
        
		durationLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 61, 48, 20)];
		durationLabel.font = [UIFont boldSystemFontOfSize:12];
		durationLabel.textColor = [UIColor blackColor];
		durationLabel.backgroundColor = [UIColor clearColor];
		durationLabel.highlightedTextColor = [UIColor whiteColor];
		[self addSubview:durationLabel];
        
        submitterLabel = [[UILabel alloc]initWithFrame:CGRectMake(175, 61, 112, 20)];
        submitterLabel.font = [UIFont boldSystemFontOfSize:12];
        submitterLabel.textColor = [UIColor colorWithRed:0.4 green:(109.0 / 255.0) blue:(116.0 / 255.0) alpha:1];
		submitterLabel.backgroundColor = [UIColor clearColor];
        submitterLabel.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:submitterLabel];
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
	[thumbImageView release];
	[ratingPercentLabel release];
    [viewCountLabel release];
	[durationLabel release];
    [submitterLabel release];
    [super dealloc];
}

@end
