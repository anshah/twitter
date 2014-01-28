//
//  TweetCell.m
//  twitter
//
//  Created by Timothy Lee on 8/6/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import "CustomButton.h"

@interface TweetCell()


@end

@implementation TweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
/*
+(id) createCellWithTweet :(Tweet*)tweet indexPath:(int)indexPath
        onReplyEvent:(void (^)(id sender))onReplyEvent
        onRetweetEvent:(void (^)(id sender))onRetweetEvent
        onFavoriteEvent:(void (^)(id sender))onFavoriteEvent
{
    
    // Initialization code
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TweetCell" owner:self options:nil];
    TweetCell* tweetCell = (TweetCell *)[nib objectAtIndex:0];
    
    //Tweet *tweet = self.tweets[indexPath.row];
    
    UIImageView* profilePic = (UIImageView*)[tweetCell viewWithTag:4];
    [profilePic setImageWithURL: [NSURL URLWithString:tweet.profilePictureUrl]];
    profilePic.layer.cornerRadius = 4.0;
    profilePic.clipsToBounds = YES;
    
    UILabel* user = (UILabel*)[tweetCell viewWithTag:1];
    [user setText: tweet.user];
    
    UILabel* screenname = (UILabel*)[tweetCell viewWithTag:2];
    [screenname setText: [@"@" stringByAppendingString: tweet.screen_name]];
    
    UILabel* text = (UILabel*)[tweetCell viewWithTag:3];
    [text setText: tweet.text];
    
    UILabel* retweetedby = (UILabel*)[tweetCell viewWithTag:7];
    if([tweet isRetweet]){
        [retweetedby setText: [tweet.retweetedby_user stringByAppendingString: @" retweeted"]];
    }else{
        //Hide top retweeted img and retwitted by user name if its not retweet
        
        UIImageView* retweetedImg = (UIImageView*)[tweetCell viewWithTag:6];
        for(NSLayoutConstraint* con in retweetedImg.constraints){
            //NSLog(@"%d, %d, %f, %d, %f", [con firstAttribute], [con relation], [con multiplier], [con secondAttribute], [con constant]);
            if([con firstAttribute] == NSLayoutAttributeHeight){
                con.constant = 0.0;
            }
        }
        for(NSLayoutConstraint* con in retweetedby.constraints){
            //NSLog(@"%d, %d, %f, %d, %f", [con firstAttribute], [con relation], [con multiplier], [con secondAttribute], [con constant]);
            if([con firstAttribute] == NSLayoutAttributeHeight){
                con.constant = 0.0;
            }
        }
    }
    
    UILabel* createddt = (UILabel*)[tweetCell viewWithTag:5];
    createddt.text = tweet.created_at_relative;
    
    CustomButton* replyButton = (CustomButton*)[tweetCell viewWithTag:8];
    replyButton.indexPath = indexPath;
    [replyButton addTarget:self action:@selector(onReplyEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    CustomButton* retweetButton = (CustomButton*)[tweetCell viewWithTag:9];
    retweetButton.indexPath = indexPath;
    [retweetButton setSelected: tweet.is_retweeted];
    [retweetButton addTarget:self action:@selector(onRetweetEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    //cant retweet one's tweet so hide if users own tweet
    if([tweet.screen_name compare: [User currentUser].screen_name] == 0){
        retweetButton.enabled = NO;
    }
    
    CustomButton* favoriteButton = (CustomButton*)[tweetCell viewWithTag:10];
    favoriteButton.indexPath = indexPath;
    [favoriteButton setSelected: tweet.is_favorite];
    [favoriteButton addTarget:self action:@selector(onFavoriteEvent:) forControlEvents:UIControlEventTouchUpInside];
    
        return tweetCell;
}*/
@end
