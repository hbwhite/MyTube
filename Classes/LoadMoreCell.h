//
//  LoadMoreCell.h
//  MyTube
//
//  Created by Harrison White on 4/11/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadMoreCell : UITableViewCell {
    UILabel *loadMoreLabel;
	UIActivityIndicatorView *loadMoreActivityIndicator;
}

@property (nonatomic, assign) UILabel *loadMoreLabel;
@property (nonatomic, assign) UIActivityIndicatorView *loadMoreActivityIndicator;

@end
