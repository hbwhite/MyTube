//
//  HUDView.h
//  MyTube
//
//  Created by Harrison White on 12/18/10.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol HUDViewDelegate;

@interface HUDView : UIView {
	id <HUDViewDelegate> delegate;
	UIActivityIndicatorView *hudActivityIndicatorView;
	UILabel *hudLabel;
	UILabel *hudSubtitleLabel;
}

@property (nonatomic, assign) id <HUDViewDelegate> delegate;
@property (nonatomic, assign) UIActivityIndicatorView *hudActivityIndicatorView;
@property (nonatomic, assign) UILabel *hudLabel;
@property (nonatomic, assign) UILabel *hudSubtitleLabel;

@end

@protocol HUDViewDelegate <NSObject>

@optional

- (void)hudViewTouchesBegan:(HUDView *)hudView;

@end
