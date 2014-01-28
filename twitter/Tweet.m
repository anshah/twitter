//
//  Tweet.m
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "Tweet.h"
@interface Tweet()

@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) NSString *tweetid;

@property (nonatomic, strong) NSString *profilePictureUrl;
@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *screen_name;

@property (nonatomic, strong) NSString *retweetedby_user;
@property (nonatomic, strong) NSString *retweetedby_screen_name;

@property (nonatomic, strong) NSString *created_at;

@property (nonatomic, strong) NSString *created_at_relative;

@property (nonatomic) BOOL isRetweet;

@property (nonatomic) BOOL verified;

@end

@implementation Tweet

static NSDateFormatter* twitter_date_format = nil;
static NSDateFormatter *timeline_date_format = nil;
static NSDateFormatter *tweet_datetime_format = nil;


+ (NSMutableArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *params in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:params]];
    }
    return tweets;
}

- (id)initWithDictionary:(NSDictionary *)data {
    if (self = [super initWithDictionary:data]) {
        self.tweetid = [self.data valueOrNilForKeyPath:@"id"];
        self.isRetweet = ([self.data valueOrNilForKeyPath:@"retweeted_status"] != nil);
        self.retweets_count = [self.data valueOrNilForKeyPath:@"retweet_count"];
        self.favorites_count = [self OwnOrRetweetedFromKey:@"favorite_count"];
        if(tweet_datetime_format == nil){
            tweet_datetime_format = [[NSDateFormatter alloc] init];
            [tweet_datetime_format setDateFormat:@"M/d/yy, hh:mm a"];
        }
        self.created_at =[tweet_datetime_format stringFromDate:[Tweet convertTwitterDateToNSDate: [self OwnOrRetweetedFromKey:@"created_at"]]];
        self.created_at_relative = [Tweet userFriendlyDateTimeFormat: [Tweet convertTwitterDateToNSDate: [self OwnOrRetweetedFromKey:@"created_at"]]];
        self.text = [self OwnOrRetweetedFromKey:@"text"];
        self.profilePictureUrl = [self OwnOrRetweetedFromKey:@"user.profile_image_url"];
        self.user= [self OwnOrRetweetedFromKey:@"user.name"];
        self.screen_name= [self OwnOrRetweetedFromKey:@"user.screen_name"];
        self.is_retweeted = [[self.data valueOrNilForKeyPath:@"retweeted"] intValue] > 0;
        self.is_favorite = [[self.data valueOrNilForKeyPath:@"retweeted"] intValue] > 0;
        if([self isRetweet]){
            self.retweetedby_user = [self.data valueOrNilForKeyPath:@"user.name"];
        }
        if([self isRetweet]){
            self.retweetedby_screen_name = [self.data valueOrNilForKeyPath:@"user.screen_name"];
        }
        self.verified = [[self OwnOrRetweetedFromKey:@"user.verified"] intValue] > 0;
        
    }
    return self;
}

- (id) OwnOrRetweetedFromKey:(NSString*) key{
    if(![self isRetweet]){
        return [self.data valueOrNilForKeyPath:key];
    }else{
        return [self.data valueOrNilForKeyPath:[@"retweeted_status." stringByAppendingString:key]];
    }
}

+(NSDate*)convertTwitterDateToNSDate:(NSString*)created_at
{
    //"created_at" = "Sun Jan 26 02:36:31 +0000 2014";
    if(twitter_date_format == nil){
        twitter_date_format = [[NSDateFormatter alloc] init];
        [twitter_date_format setTimeStyle:NSDateFormatterFullStyle];
        [twitter_date_format setFormatterBehavior:NSDateFormatterBehavior10_4];
        [twitter_date_format setDateFormat:@"EEE LLL d HH:mm:ss Z yyyy"];
    }
    NSDate* convertedDate = [twitter_date_format dateFromString:created_at];
    return convertedDate;
}

//return relative date time as shown on twitter timeline
+ (NSString*) userFriendlyDateTimeFormat: (NSDate*)ndate{
    if(timeline_date_format == nil){
        timeline_date_format = [[NSDateFormatter alloc] init];
        [timeline_date_format setDateFormat:@"M/d/yy"];
    }
    NSDate *now = [NSDate date];
    NSTimeInterval howLong = [now timeIntervalSinceDate:ndate];
    
    if(howLong < 60){
        return [NSString stringWithFormat:@"%ds",(int)howLong];
    }else if(howLong < 3600){
        return [NSString stringWithFormat:@"%dm",(int)(howLong/60)];
    }else if(howLong < 3600*24){
        return [NSString stringWithFormat:@"%dh",(int)(howLong/(3600))];
    }else if(howLong < 3600*24*7){
        return [NSString stringWithFormat:@"%dd",(int)(howLong/(3600*24))];
    }else{
        return [timeline_date_format stringFromDate:ndate];
    }
}

@end
