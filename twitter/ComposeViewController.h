//
//  ComposeViewController.h
//  twitter
//
//  Created by Ankit Nitin Shah on 1/27/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComposeViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) Tweet* in_reply_to;

@end
