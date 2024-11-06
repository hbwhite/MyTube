//
//  DownloadedVideoCell.h
//  MyTube
//
//  Created by Harrison White on 3/2/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DownloadedVideoCell : UITableViewCell {
	UIImageView *thumbnailImageView;
	UIView *thumbnailSeparator;
	UILabel *titleLabel;
	UILabel *qualityLabel;
    UILabel *sizeLabel;
	UILabel *durationLabel;
    UILabel *submitterLabel;
}

@property (nonatomic, assign) UIImageView *thumbnailImageView;
@property (nonatomic, assign) UIView *thumbnailSeparator;
@property (nonatomic, assign) UILabel *titleLabel;
@property (nonatomic, assign) UILabel *qualityLabel;
@property (nonatomic, assign) UILabel *sizeLabel;
@property (nonatomic, assign) UILabel *durationLabel;
@property (nonatomic, assign) UILabel *submitterLabel;

@end
