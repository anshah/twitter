//
//  SearchResult.h
//  twitter
//
//  Created by Ankit Nitin Shah on 1/28/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

@interface SearchResult : RestObject

@property (nonatomic, strong, readonly) NSMutableArray* tweets;

- (NSArray*) filterRepliesToStatus: (NSString*) status_id;

@end
