//
//  DetailCell.m
//  MyTube
//
//  Created by Harrison White on 7/23/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "DetailCell.h"

#define DETAIL_LABEL_COLOR_RED		(46.0 / 255.0)
#define DETAIL_LABEL_COLOR_GREEN	(65.0 / 255.0)
#define DETAIL_LABEL_COLOR_BLUE		(118.0 / 255.0)

@implementation DetailCell

@synthesize detailLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
		detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 260, 30)];
		detailLabel.font = [UIFont systemFontOfSize:17];
		detailLabel.textAlignment = UITextAlignmentRight;
		detailLabel.textColor = [UIColor colorWithRed:DETAIL_LABEL_COLOR_RED green:DETAIL_LABEL_COLOR_GREEN blue:DETAIL_LABEL_COLOR_BLUE alpha:1];
		detailLabel.highlightedTextColor = [UIColor whiteColor];
		detailLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:detailLabel];
		
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
	[detailLabel release];
    [super dealloc];
}

@end
