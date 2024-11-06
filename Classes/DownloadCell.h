//
//  DownloadCell.h
//  MyTube
//
//  Created by Harrison White on 2/18/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DownloadCell : UITableViewCell {
	UIImageView *thumbnailImageView;
	UIView *thumbnailSeparator;
	UILabel *titleLabel;
	UILabel *durationLabel;
    UILabel *qualityLabel;
	UILabel *submitterLabel;
    UILabel *progressLabel;
	UIProgressView *progressView;
}

@property (nonatomic, assign) UIImageView *thumbnailImageView;
@property (nonatomic, assign) UIView *thumbnailSeparator;
@property (nonatomic, assign) UILabel *titleLabel;
@property (nonatomic, assign) UILabel *durationLabel;
@property (nonatomic, assign) UILabel *qualityLabel;
@property (nonatomic, assign) UILabel *submitterLabel;
@property (nonatomic, assign) UILabel *progressLabel;
@property (nonatomic, assign) UIProgressView *progressView;

@end
