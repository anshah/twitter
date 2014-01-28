//
//  ComposeViewController.m
//  twitter
//
//  Created by Ankit Nitin Shah on 1/27/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "ComposeViewController.h"
#import "UIImageView+AFNetworking.h"

@interface ComposeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImg;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UITextView *tweetData;

@end

@implementation ComposeViewController{
    UIBarButtonItem* textCountButton;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //set up navigation bar title and buttons
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:85.0/255 green:172.0/255 blue:238.0/255 alpha:1.0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(closeTweeting)];
    
    UIBarButtonItem* tweetButton =[[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(postTweet)];
    textCountButton =[[UIBarButtonItem alloc] initWithTitle:@"140" style:UIBarButtonItemStylePlain target:nil action:nil];
    [textCountButton setEnabled:false];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:tweetButton, textCountButton, nil];
    
    //setup user image, name and screename
    [self.profileImg setImageWithURL: [NSURL URLWithString:User.currentUser.profilePictureUrl]];
    self.profileImg.layer.cornerRadius = 3.0;
    self.profileImg.clipsToBounds = YES;
    
    self.userName.text = User.currentUser.user;
    self.screenName.text = User.currentUser.screen_name;
    
    //setup reply to in tweet if reply to compose
    if(self.in_reply_to){
        NSString* startTweet = [self.in_reply_to.reply_handles componentsJoinedByString:@" @" ];/*@"";
        if([self.in_reply_to isRetweet]){
            startTweet = [NSString stringWithFormat:@"@%@ ", self.in_reply_to.retweetedby_screen_name];
        }
        startTweet = [NSString stringWithFormat:@"%@@%@ ",startTweet,self.in_reply_to.screen_name ];
       */
        self.tweetData.text = [startTweet substringFromIndex:1];
    }
    [self.tweetData becomeFirstResponder];
    [textCountButton setTitle: [NSString stringWithFormat: @"%d", (140-self.tweetData.text.length)]];
    self.tweetData.delegate = self;
}

-(void)closeTweeting{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void) postTweet{
    if([self.tweetData.text length] == 0){
        return;
    }
    //Post tweet and update model and close view.
    [[TwitterClient instance] tweet:self.tweetData.text in_reply_to_status_id:self.in_reply_to.tweetid success:^(AFHTTPRequestOperation *operation, id response) {
        [[User currentUser].tweets insertObject:[[Tweet alloc] initWithDictionary:response] atIndex:0];
        [self closeTweeting];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Couldn't post tweet, please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//textview delegate
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    //Limit max to 140 characters
    if((textView.text.length +text.length - range.length) > 140){
        return false;
    }
    [textCountButton setTitle: [NSString stringWithFormat: @"%d", 140-(textView.text.length +text.length - range.length)]];
    return TRUE;
}

@end
