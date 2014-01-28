//
//  TweetViewController.m
//  twitter
//
//  Created by Ankit Nitin Shah on 1/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "TweetViewController.h"
#import "TweetDetailViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "ComposeViewController.h"
#import "CustomButton.h"

#define MAX_TEXTVIEW_WIDTH 295
#define EXTRA_HEIGHT_PADDING 162
#define EXTRA_HEIGHT_PADDING_RETWEETED 15

@interface TweetViewController ()

@end

@implementation TweetViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Tweet";        
    }
    return self;
}

- (id)initWithTweet:(Tweet*)tweet
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = @"Tweet";
        self.tweet=tweet;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reply" style:UIBarButtonItemStylePlain target:self action:@selector(addNewTweet)];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TweetDetailViewCell" owner:self options:nil];
    TweetDetailViewCell* tweetCell = (TweetDetailViewCell *)[nib objectAtIndex:0];
    //NSLog(@"Creating new cell");
    
    UILabel* retweetedby = (UILabel*)[tweetCell viewWithTag:2];
    if([self.tweet isRetweet]){
        [retweetedby setText: [self.tweet.retweetedby_user stringByAppendingString: @" retweeted"]];
    }else{
        //hide top retweeted by img and user if not retweeted
        UIImageView* retweetedImg = (UIImageView*)[tweetCell viewWithTag:1];
        for(NSLayoutConstraint* con in retweetedImg.constraints){
            if([con firstAttribute] == NSLayoutAttributeHeight){
                con.constant = 0.0;
            }
        }
        for(NSLayoutConstraint* con in retweetedby.constraints){
            if([con firstAttribute] == NSLayoutAttributeHeight){
                con.constant = 0.0;
            }
        }
    }

    UIImageView* profilePic = (UIImageView*)[tweetCell viewWithTag:3];
    [profilePic setImageWithURL: [NSURL URLWithString:self.tweet.profilePictureUrl]];
    profilePic.layer.cornerRadius = 4.0;
    profilePic.clipsToBounds = YES;
    
    UILabel* user = (UILabel*)[tweetCell viewWithTag:4];
    [user setText: self.tweet.user];
    
    UILabel* verified = (UILabel*)[tweetCell viewWithTag:5];
    if(!self.tweet.verified){
        verified.hidden = YES;
    }
    
    UILabel* screenname = (UILabel*)[tweetCell viewWithTag:6];
    [screenname setText: [@"@" stringByAppendingString: self.tweet.screen_name]];
    
    UILabel* text = (UILabel*)[tweetCell viewWithTag:7];
    [text setText: self.tweet.text];
    
    
    UILabel* createddt = (UILabel*)[tweetCell viewWithTag:8];
    createddt.text = self.tweet.created_at;

    UILabel* retweet_count = (UILabel*)[tweetCell viewWithTag:9];
    retweet_count.text = [NSString stringWithFormat:@"%@",self.tweet.retweets_count];
    UILabel* favorite_count = (UILabel*)[tweetCell viewWithTag:10];
    favorite_count.text = [NSString stringWithFormat:@"%@",self.tweet.favorites_count];
    
    CustomButton* customButton = (CustomButton*)[tweetCell viewWithTag:15];
    customButton.indexPath = indexPath.row;
    [customButton addTarget:self action:@selector(onReplyEvent:) forControlEvents:UIControlEventTouchUpInside];

    CustomButton* retweetButton = (CustomButton*)[tweetCell viewWithTag:16];
    retweetButton.indexPath = indexPath.row;
    [retweetButton setSelected: self.tweet.is_retweeted];
    [retweetButton addTarget:self action:@selector(onRetweetEvent:) forControlEvents:UIControlEventTouchUpInside];
    if([self.tweet.screen_name compare: [User currentUser].screen_name] == 0){
        retweetButton.enabled = NO;
    }
    
    CustomButton* favoriteButton = (CustomButton*)[tweetCell viewWithTag:17];
    favoriteButton.indexPath = indexPath.row;
    [favoriteButton setSelected: self.tweet.is_favorite];
    [favoriteButton addTarget:self action:@selector(onFavoriteEvent:) forControlEvents:UIControlEventTouchUpInside];

    CustomButton* deleteButton = (CustomButton*)[tweetCell viewWithTag:18];
    if([self.tweet.screen_name compare: [User currentUser].screen_name] == 0){
        deleteButton.indexPath = indexPath.row;
        [deleteButton addTarget:self action:@selector(onDeleteEvent:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        deleteButton.hidden = YES;
    }
    
    return tweetCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Max height width frame
    CGSize boundingSize = CGSizeMake(MAX_TEXTVIEW_WIDTH, 0.0);

    //height for tweet text
    CGRect textRect = [[self.tweet text]
                       boundingRectWithSize:boundingSize
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0]}
                       context:nil];

    //add padding for fixed elements
    CGFloat requiredHeight = textRect.size.height + EXTRA_HEIGHT_PADDING;
    
    //add padding if retweeted
    if([self.tweet isRetweet]){
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

-(BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return FALSE;
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

- (void) addNewTweet{
    ComposeViewController* compose = [[ComposeViewController alloc] init];
    compose.in_reply_to = self.tweet;
    UINavigationController* navCon = [[UINavigationController alloc] initWithRootViewController:compose];
    
    compose.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navCon animated:YES completion:nil];
}

- (IBAction)onReplyEvent:(id)sender{
    [self addNewTweet];
}

- (IBAction)onRetweetEvent:(id)sender{
    CustomButton* customButton = (CustomButton*)sender;
    
    if(customButton.isSelected){
        //Not Implemented remove retweet
        [[[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Not implemented" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }else{
        //retweet and on success update model and view
        [[TwitterClient instance] retweet: self.tweet.tweetid success:^(AFHTTPRequestOperation *operation, id response) {
            [customButton setSelected:YES];
            self.tweet.is_retweeted= YES;
            self.tweet.retweets_count = [NSString stringWithFormat:@"%d",[self.tweet.retweets_count intValue]+1 ];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Couldn't retweet, please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
    [self.tableView reloadData];

}

- (IBAction)onFavoriteEvent:(id)sender{
    CustomButton* customButton = (CustomButton*)sender;
    
    if(customButton.isSelected == YES){
        //remove favorite and update model and view
        [[TwitterClient instance] undo_favorite: [self.tweet tweetid] success:^(AFHTTPRequestOperation *operation, id response) {
            [customButton setSelected:NO];
            self.tweet.is_favorite= NO;
            self.tweet.favorites_count = [NSString stringWithFormat:@"%d",[self.tweet.favorites_count intValue]-1 ];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Couldn't undo favorite, please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            NSLog(@"%@",error);
        }];
        
    }else{
        //favorite and on success update model and view
        [[TwitterClient instance] favorite: [self.tweet tweetid] success:^(AFHTTPRequestOperation *operation, id response) {
            [customButton setSelected:YES];
            self.tweet.is_favorite= YES;
            self.tweet.favorites_count = [NSString stringWithFormat:@"%d",[self.tweet.favorites_count intValue]+1 ];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Couldn't favorite, please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
}


- (IBAction)onDeleteEvent:(id)sender{
    CustomButton* customButton = (CustomButton*)sender;
    
    //delete and on success update model and go to timeline
    [[TwitterClient instance] deleteTweet: [self.tweet tweetid] success:^(AFHTTPRequestOperation *operation, id response) {
        [[User currentUser].tweets removeObjectAtIndex:customButton.indexPath];
        [self.navigationController popViewControllerAnimated:YES];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Couldn't delete, please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];

}
@end
