//
//  SegmentedControlCell.h
//  MyTube
//
//  Created by Harrison White on 8/11/11.
//  Copyright (c) 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentedControlCell : UITableViewCell {
	UISegmentedControl *segmentedControl;
}

@property (nonatomic, assign) UISegmentedControl *segmentedControl;

@end
