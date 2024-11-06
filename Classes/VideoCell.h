//
//  VideoCell.h
//  MyTube
//
//  Created by Harrison White on 4/9/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCell : UITableViewCell {
	UIImageView *thumbnailImageView;
	UIView *thumbnailSeparator;
    UILabel *titleLabel;
	UIImageView *thumbImageView;
	UILabel *ratingPercentLabel;
    UILabel *viewCountLabel;
	UILabel *durationLabel;
    UILabel *submitterLabel;
}

@property (nonatomic, assign) UIImageView *thumbnailImageView;
@property (nonatomic, assign) UIView *thumbnailSeparator;
@property (nonatomic, assign) UILabel *titleLabel;
@property (nonatomic, assign) UIImageView *thumbImageView;
@property (nonatomic, assign) UILabel *ratingPercentLabel;
@property (nonatomic, assign) UILabel *viewCountLabel;
@property (nonatomic, assign) UILabel *durationLabel;
@property (nonatomic, assign) UILabel *submitterLabel;

@end
