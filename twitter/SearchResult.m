//
//  SearchResult.m
//  twitter
//
//  Created by Ankit Nitin Shah on 1/28/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "SearchResult.h"

@interface SearchResult()

@property (nonatomic, strong) NSMutableArray* tweets;

@end

@implementation SearchResult

- (id)initWithDictionary:(NSDictionary *)data {
    if (self = [super initWithDictionary:data]) {
        self.tweets = [NSMutableArray arrayWithArray: [Tweet tweetsWithArray: [self.data valueOrNilForKeyPath:@"statuses"]]];
    }
    return self;
}

- (NSArray*) filterRepliesToStatus: (NSString*) status_id{
    NSMutableArray* replies = [[NSMutableArray alloc] init];
    for(Tweet* twt in self.tweets){
        if(twt.in_reply_to_status_id != nil && [status_id compare: twt.in_reply_to_status_id] == 0){
            [replies addObject: twt];
        }
    }
    return [NSArray arrayWithArray:replies];
}

@end
