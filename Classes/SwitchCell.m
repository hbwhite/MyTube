//
//  SwitchCell.m
//  MyTube
//
//  Created by Harrison White on 10/22/10.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "SwitchCell.h"


@implementation SwitchCell

@synthesize cellSwitch;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		cellSwitch = [[UISwitch alloc]init];
		cellSwitch.frame = CGRectMake((300 - (cellSwitch.frame.size.width + 8)), 8, cellSwitch.frame.size.width, cellSwitch.frame.size.height);
		[self.contentView addSubview:cellSwitch];
		
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[cellSwitch release];
    [super dealloc];
}


@end
