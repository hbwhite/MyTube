//
//  SegmentedControlCell.m
//  MyTube
//
//  Created by Harrison White on 8/11/11.
//  Copyright (c) 2011 Harrison Apps, LLC. All rights reserved.
//

#import "SegmentedControlCell.h"
#import "MyTubeAppDelegate.h"

#define SEGMENTED_CONTROL_TINT_COLOR_RED							0
#define SEGMENTED_CONTROL_TINT_COLOR_GREEN							0.65
#define SEGMENTED_CONTROL_TINT_COLOR_BLUE							1

static NSString *kWebsiteSegmentedControlSelectedSegmentIndexKey	= @"Website Segmented Control Selected Segment Index";

@interface SegmentedControlCell ()

- (void)segmentedControlValueChanged;

@end

@implementation SegmentedControlCell

@synthesize segmentedControl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
		segmentedControl = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Desktop", @"Mobile", nil]];
		segmentedControl.frame = CGRectMake(9, 0, 302, 44);
		segmentedControl.tintColor = [UIColor colorWithRed:SEGMENTED_CONTROL_TINT_COLOR_RED green:SEGMENTED_CONTROL_TINT_COLOR_GREEN blue:SEGMENTED_CONTROL_TINT_COLOR_BLUE alpha:1];
		segmentedControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults]integerForKey:kWebsiteSegmentedControlSelectedSegmentIndexKey];
		[segmentedControl addTarget:self action:@selector(segmentedControlValueChanged) forControlEvents:UIControlEventValueChanged];
		[self addSubview:segmentedControl];
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)segmentedControlValueChanged {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:segmentedControl.selectedSegmentIndex forKey:kWebsiteSegmentedControlSelectedSegmentIndexKey];
	[defaults synchronize];
	[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]clearCache];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
	[segmentedControl release];
	[super dealloc];
}

@end
