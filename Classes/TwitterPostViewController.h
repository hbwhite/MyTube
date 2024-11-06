//
//  TwitterPostViewController.h
//  MyTube
//
//  Created by Harrison White on 5/30/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TwitterPostViewController : UIViewController <UITextViewDelegate> {
    IBOutlet UIBarButtonItem *cancelButton;
	IBOutlet UIBarButtonItem *postButton;
	IBOutlet UITextView *postTextView;
	IBOutlet UILabel *charactersRemainingLabel;
	NSString *message;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *postButton;
@property (nonatomic, retain) IBOutlet UITextView *postTextView;
@property (nonatomic, retain) IBOutlet UILabel *charactersRemainingLabel;
@property (nonatomic, assign) NSString *message;

- (IBAction)cancelButtonPressed;
- (IBAction)postButtonPressed;
- (void)postTweet;
- (void)updateCharactersRemainingLabel;

@end
