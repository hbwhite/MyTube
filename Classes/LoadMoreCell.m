//
//  LoadMoreCell.m
//  MyTube
//
//  Created by Harrison White on 4/11/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "LoadMoreCell.h"

#define LOAD_MORE_COLOR_RED		(41.0 / 255.0)
#define LOAD_MORE_COLOR_GREEN	(96.0 / 255.0)
#define LOAD_MORE_COLOR_BLUE	(217.0 / 255.0)

@implementation LoadMoreCell

@synthesize loadMoreLabel;
@synthesize loadMoreActivityIndicator;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
		loadMoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 90)];
		loadMoreLabel.textAlignment = UITextAlignmentCenter;
		loadMoreLabel.highlightedTextColor = [UIColor whiteColor];
		loadMoreLabel.font = [UIFont boldSystemFontOfSize:18];
		loadMoreLabel.textColor = [UIColor colorWithRed:LOAD_MORE_COLOR_RED green:LOAD_MORE_COLOR_GREEN blue:LOAD_MORE_COLOR_BLUE alpha:1];
		[self.contentView addSubview:loadMoreLabel];
		loadMoreActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		loadMoreActivityIndicator.frame = CGRectMake(250, 33, 20, 20);
		loadMoreActivityIndicator.hidden = YES;
		[self.contentView addSubview:loadMoreActivityIndicator];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
	[loadMoreLabel release];
	[loadMoreActivityIndicator release];
    [super dealloc];
}

@end
