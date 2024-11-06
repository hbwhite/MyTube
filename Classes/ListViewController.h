//
//  ListViewController.h
//  MyTube
//
//  Created by Harrison White on 7/23/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ListViewControllerDelegate;

@interface ListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	id <ListViewControllerDelegate> delegate;
	IBOutlet UITableView *theTableView;
	NSString *_tableHeaderTitle;
    NSMutableArray *optionsArray;
	NSMutableArray *optionSubtitlesArray;
	NSMutableArray *correspondingValuesArray;
	NSMutableString *_selectedOption;
	NSInteger selectedOptionIndex;
	BOOL isAdObserver;
}

@property (nonatomic, assign) id <ListViewControllerDelegate> delegate;

- (void)setTableHeaderTitle:(NSString *)tableHeaderTitle;
- (void)setOptions:(NSArray *)options;
- (void)setOptionSubtitles:(NSArray *)optionSubtitles;
- (void)setCorrespondingValues:(NSArray *)correspondingValues;
- (void)setSelectedOption:(NSString *)selectedOption;

@end

@protocol ListViewControllerDelegate <NSObject>

@optional

- (void)listViewControllerDidSelectOptionAtIndex:(NSInteger)index;

@end
