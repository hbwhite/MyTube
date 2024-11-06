//
//  SearchMask.m
//  MyTube
//
//  Created by Harrison White on 4/10/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "SearchMask.h"


@implementation SearchMask

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (delegate) {
		if ([delegate respondsToSelector:@selector(searchMaskTouchesBegan)]) {
			[delegate searchMaskTouchesBegan];
		}
	}
	[super touchesBegan:touches withEvent:event];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
	[delegate release];
    [super dealloc];
}

@end
