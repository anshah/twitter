//
//  TimelineVC.m
//  twitter
//
//  Created by Timothy Lee on 8/4/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "TimelineVC.h"
#import "TweetCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"
#import "TweetViewController.h"
#import "ComposeViewController.h"
#import "CustomButton.h"

#define MAX_TEXTVIEW_WIDTH 257
#define MAX_TEXTVIEW_HEIGHT 160
#define EXTRA_HEIGHT_PADDING 52
#define EXTRA_HEIGHT_PADDING_RETWEETED 20

@interface TimelineVC ()

@property (nonatomic, strong) NSMutableArray *tweets;

@property (nonatomic) BOOL loadingMoreTweets;

- (void)onSignOutButton;
- (void)reload;

@end

@implementation TimelineVC{
    UILabel* refreshLabel;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Home";
        [self reload];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:85.0/255 green:172.0/255 blue:238.0/255 alpha:1.0];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onSignOutButton)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(addNewTweet)];
    
    [self addPullToRefreshLabel];

    //[self.tableView registerClass: [TweetCell class] forCellReuseIdentifier:@"TweetCell"];
}

- (void) viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
    return [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TweetCell";
    //TweetCell* tweetCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //if (tweetCell == nil)
    //{
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TweetCell" owner:self options:nil];
        TweetCell* tweetCell = (TweetCell *)[nib objectAtIndex:0];
    //}
    
    Tweet *tweet = self.tweets[indexPath.row];
    
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
    replyButton.indexPath = indexPath.row;
    [replyButton addTarget:self action:@selector(onReplyEvent:) forControlEvents:UIControlEventTouchUpInside];

    CustomButton* retweetButton = (CustomButton*)[tweetCell viewWithTag:9];
    retweetButton.indexPath = indexPath.row;
    [retweetButton setSelected: tweet.is_retweeted];
    [retweetButton addTarget:self action:@selector(onRetweetEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    //cant retweet one's tweet so hide if users own tweet
    if([tweet.screen_name compare: [User currentUser].screen_name] == 0){
        retweetButton.enabled = NO;
    }
    
    CustomButton* favoriteButton = (CustomButton*)[tweetCell viewWithTag:10];
    favoriteButton.indexPath = indexPath.row;
    [favoriteButton setSelected: tweet.is_favorite];
    [favoriteButton addTarget:self action:@selector(onFavoriteEvent:) forControlEvents:UIControlEventTouchUpInside];

    return tweetCell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Max height width frame
    CGSize boundingSize = CGSizeMake(MAX_TEXTVIEW_WIDTH, MAX_TEXTVIEW_HEIGHT);
    
    //height for tweet text
    CGRect textRect = [[[self.tweets objectAtIndex:indexPath.row] text]
                       boundingRectWithSize:boundingSize
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]}
                       context:nil];
    
    //add padding for fixed elements
    CGFloat requiredHeight = textRect.size.height + EXTRA_HEIGHT_PADDING;
    
    //add padding if retweeted
    if([[self.tweets objectAtIndex:indexPath.row] isRetweet]){
        requiredHeight += EXTRA_HEIGHT_PADDING_RETWEETED;
    }
    
    return requiredHeight;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TweetViewController* tweetViewController = [[TweetViewController alloc] initWithTweet: [self.tweets objectAtIndex:indexPath.row]];
    //[tweetViewController setTweet: [self.tweets objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:tweetViewController animated:YES];
}

- (void) addNewTweet{
    ComposeViewController* compose = [[ComposeViewController alloc] init];
    UINavigationController* navCon = [[UINavigationController alloc] initWithRootViewController:compose];
    
    compose.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navCon animated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - Private methods

- (void)onSignOutButton {
    [User setCurrentUser:nil];
}

- (void)reload {
    [[TwitterClient instance] homeTimelineWithCount:20 sinceId:nil maxId:nil success:^(AFHTTPRequestOperation *operation, id response) {
        //NSLog(@"%@", response);
        [User currentUser].tweets = [Tweet tweetsWithArray:response];
        self.tweets = [User currentUser].tweets;
        [self.tableView reloadData];
        self.loadingMoreTweets = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Do nothing
    }];
}

- (void)loadMoreTweets {
    if([self.tweets count] != 0){
        NSString* maxid = [[self.tweets lastObject] tweetid];
        //NSLog(@"startid:, %@",maxid);
        [[TwitterClient instance] homeTimelineWithCount:20 sinceId:nil maxId:maxid success:^(AFHTTPRequestOperation *operation, id response) {
            //NSLog(@"%@", response);
            NSMutableArray* oldTweets = [Tweet tweetsWithArray:response];
            [oldTweets removeObjectAtIndex:0];
            [self.tweets addObjectsFromArray: oldTweets];
            [self.tableView reloadData];
            self.loadingMoreTweets = NO;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            // Do nothing
            self.loadingMoreTweets = NO;
        }];
    }
}


- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
    
    float percentScrolled = 1.0*(scrollView.contentOffset.y+scrollView.frame.size.height) / self.tableView.contentSize.height;
    if(!self.loadingMoreTweets && percentScrolled > 0.9){
        self.loadingMoreTweets = YES;
        [self loadMoreTweets];
    }
    
    //added for pull to refresh
    if(scrollView.contentOffset.y < 0){
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -110) {
                // User is scrolling above the header
                refreshLabel.text = @"Release to refresh...";
            } else {
                // User is scrolling somewhere within the header
                refreshLabel.text = @"Pull down to refresh...";
            }
        }];
    }
}

- (IBAction)onReplyEvent:(id)sender{
    CustomButton* customButton = (CustomButton*)sender;
    ComposeViewController* compose = [[ComposeViewController alloc] init];
    compose.in_reply_to = [self.tweets objectAtIndex:customButton.indexPath];
    
    UINavigationController* navCon = [[UINavigationController alloc] initWithRootViewController:compose];
    compose.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navCon animated:YES completion:nil];
}

- (IBAction)onRetweetEvent:(id)sender{
    CustomButton* customButton = (CustomButton*)sender;
    Tweet* tweet = (Tweet*)[self.tweets objectAtIndex:customButton.indexPath];
    
    if(customButton.isSelected){
        //Not Implemented remove retweet
        [[[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Not implemented" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        //[customButton setSelected:NO];
    }else{
        //retweet and on success update model and view
        [[TwitterClient instance] retweet: [tweet tweetid] success:^(AFHTTPRequestOperation *operation, id response) {
            [customButton setSelected:YES];
            tweet.is_retweeted= YES;
            tweet.retweets_count = [NSString stringWithFormat:@"%d",[tweet.retweets_count intValue]+1 ];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:customButton.indexPath inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //[[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Couldn't retweet, please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
}

- (IBAction)onFavoriteEvent:(id)sender{
    CustomButton* customButton = (CustomButton*)sender;
    Tweet* tweet = (Tweet*)[self.tweets objectAtIndex:customButton.indexPath];
    
    if(customButton.isSelected == YES){
        //remove favorite and update model and view
        [[TwitterClient instance] undo_favorite: [tweet tweetid] success:^(AFHTTPRequestOperation *operation, id response) {
            [customButton setSelected:NO];
            tweet.is_favorite= NO;
            tweet.favorites_count = [NSString stringWithFormat:@"%d",[tweet.favorites_count intValue]-1 ];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:customButton.indexPath inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //[[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Couldn't undo favorite, please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            //NSLog(@"%@",error);
        }];
        //[customButton setHighlighted:NO];
    }else{
        //favorite and on success update model and view
        [[TwitterClient instance] favorite: [tweet tweetid] success:^(AFHTTPRequestOperation *operation, id response) {
            [customButton setSelected:YES];
            tweet.is_favorite= YES;
            tweet.favorites_count = [NSString stringWithFormat:@"%d",[tweet.favorites_count intValue]+1 ];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:customButton.indexPath inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //[[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Couldn't favorite, please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
}

//reload if pull to refresh is shown.
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.loadingMoreTweets) return;
    if (scrollView.contentOffset.y <= -110) {
        // Released above the header
        NSLog(@"Refreshing...");
        self.loadingMoreTweets = YES;
        [self reload];
    }
}
//view above tableview for pull to refresh
- (void)addPullToRefreshLabel {
    UIView* refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, -50, 320, 50)];
    refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    
    [refreshHeaderView addSubview:refreshLabel];
    [self.tableView addSubview:refreshHeaderView];
}


@end
