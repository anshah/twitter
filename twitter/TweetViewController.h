//
//  TweetViewController.h
//  twitter
//
//  Created by Ankit Nitin Shah on 1/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetViewController : UITableViewController

@property (nonatomic, strong) Tweet* tweet;

- (id)initWithTweet:(Tweet*)tweet;

@end
