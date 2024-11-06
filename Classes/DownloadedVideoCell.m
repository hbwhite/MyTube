//
//  DownloadedVideoCell.m
//  MyTube
//
//  Created by Harrison White on 3/2/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "DownloadedVideoCell.h"

#define THUMBNAIL_SEPARATOR_COMMON_RGB_VALUE	(217.0 / 255.0)

@implementation DownloadedVideoCell

@synthesize thumbnailImageView;
@synthesize thumbnailSeparator;
@synthesize titleLabel;
@synthesize qualityLabel;
@synthesize sizeLabel;
@synthesize durationLabel;
@synthesize submitterLabel;

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
		
		titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 6, 148, 31)];
		titleLabel.numberOfLines = 2;
		titleLabel.font = [UIFont boldSystemFontOfSize:13];
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.highlightedTextColor = [UIColor whiteColor];
		[self addSubview:titleLabel];
        
		qualityLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 37, 65, 20)];
		qualityLabel.font = [UIFont boldSystemFontOfSize:13];
		qualityLabel.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:1 alpha:1];
		qualityLabel.backgroundColor = [UIColor clearColor];
		qualityLabel.highlightedTextColor = [UIColor whiteColor];
		[self addSubview:qualityLabel];
		
		sizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(195, 37, 83, 20)];
		sizeLabel.font = [UIFont boldSystemFontOfSize:13];
		sizeLabel.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
		sizeLabel.backgroundColor = [UIColor clearColor];
		sizeLabel.highlightedTextColor = [UIColor whiteColor];
		[self addSubview:sizeLabel];
        
		durationLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 57, 40, 20)];
		durationLabel.font = [UIFont boldSystemFontOfSize:13];
		durationLabel.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
		durationLabel.backgroundColor = [UIColor clearColor];
		durationLabel.highlightedTextColor = [UIColor whiteColor];
		[self addSubview:durationLabel];
        
        submitterLabel = [[UILabel alloc]initWithFrame:CGRectMake(190, 57, 88, 20)];
        submitterLabel.font = [UIFont boldSystemFontOfSize:13];
        submitterLabel.textColor = [UIColor colorWithRed:1 green:0.25 blue:0 alpha:1];
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
	[qualityLabel release];
    [sizeLabel release];
	[durationLabel release];
    [submitterLabel release];
    [super dealloc];
}

@end
