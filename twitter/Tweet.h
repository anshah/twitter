//
//  Tweet.h
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : RestObject

@property (nonatomic, strong, readonly) NSString *text;

+ (NSMutableArray *)tweetsWithArray:(NSArray *)array;

@property (nonatomic, strong, readonly) NSString *tweetid;

//is retwitted by someone hence appearing on timeline
@property (nonatomic, readonly) BOOL isRetweet;


//original user of the tweet.
@property (nonatomic, strong, readonly) NSString *profilePictureUrl;
@property (nonatomic, strong, readonly) NSString *user;
@property (nonatomic, strong, readonly) NSString *screen_name;

//if retwitted one, below gives original user
@property (nonatomic, strong, readonly) NSString *retweetedby_user;
@property (nonatomic, strong, readonly) NSString *retweetedby_screen_name;

@property (nonatomic, strong, readonly) NSString *created_at;

//user to display relative datetime on timeline
@property (nonatomic, strong, readonly) NSString *created_at_relative;


//properties to track count of retweet and favorites. Could be increased, reduced by user. Hence readwrite
@property (nonatomic, strong) NSString *retweets_count;
@property (nonatomic, strong) NSString *favorites_count;

@property (nonatomic, readonly) BOOL verified;

//property to track retweeting and favorite behaviour by user. Hence readwrite
@property (nonatomic) BOOL is_retweeted;
@property (nonatomic) BOOL is_favorite;

@end
