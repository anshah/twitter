//
//  TweetCell.h
//  twitter
//
//  Created by Timothy Lee on 8/6/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetCell : UITableViewCell

+(id) createCellWithTweet :(Tweet*)tweet indexPath:(int)indexPath
              onReplyEvent:(void (^)(id sender))onReplyEvent
            onRetweetEvent:(void (^)(id sender))onRetweetEvent
           onFavoriteEvent:(void (^)(id sender))onFavoriteEvent;

@end
