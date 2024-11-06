//
//  HUDView.m
//  MyTube
//
//  Created by Harrison White on 12/18/10.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "HUDView.h"

// #define HUD_ALPHA			0.875
#define HUD_ALPHA				0.7
#define HUD_CORNER_RADIUS		10
#define HUD_TITLE_FONT_SIZE		20
#define HUD_SUBTITLE_FONT_SIZE	14

@implementation HUDView

@synthesize delegate;
@synthesize hudActivityIndicatorView;
@synthesize hudLabel;
@synthesize hudSubtitleLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:HUD_ALPHA];
		self.layer.cornerRadius = HUD_CORNER_RADIUS;
		hudActivityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		hudActivityIndicatorView.frame = CGRectMake(62, 53, 37, 37);
		[hudActivityIndicatorView startAnimating];
		[self addSubview:hudActivityIndicatorView];
		hudLabel = [[UILabel alloc]initWithFrame:CGRectMake(6, 6, 147, 43)];
		hudLabel.font = [UIFont boldSystemFontOfSize:HUD_TITLE_FONT_SIZE];
		hudLabel.textAlignment = UITextAlignmentCenter;
		hudLabel.backgroundColor = [UIColor clearColor];
		hudLabel.textColor = [UIColor whiteColor];
		[self addSubview:hudLabel];
		hudSubtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(6, 88, 147, 43)];
		hudSubtitleLabel.font = [UIFont boldSystemFontOfSize:HUD_SUBTITLE_FONT_SIZE];
		hudSubtitleLabel.textAlignment = UITextAlignmentCenter;
		hudSubtitleLabel.backgroundColor = [UIColor clearColor];
		hudSubtitleLabel.textColor = [UIColor whiteColor];
		[self addSubview:hudSubtitleLabel];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (delegate) {
        if ([delegate respondsToSelector:@selector(hudViewTouchesBegan:)]) {
            [delegate hudViewTouchesBegan:self];
        }
    }
	[super touchesEnded:touches withEvent:event];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	[hudActivityIndicatorView release];
	[hudLabel release];
	[hudSubtitleLabel release];
    [super dealloc];
}


@end
