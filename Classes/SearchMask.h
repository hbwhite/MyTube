//
//  SearchMask.h
//  MyTube
//
//  Created by Harrison White on 4/10/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchMaskDelegate;

@interface SearchMask : UIView {
    IBOutlet id <SearchMaskDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet id <SearchMaskDelegate> delegate;

@end

@protocol SearchMaskDelegate <NSObject>
@optional

- (void)searchMaskTouchesBegan;

@end
