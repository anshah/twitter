//
//  User.h
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const UserDidLoginNotification;
extern NSString *const UserDidLogoutNotification;

@interface User : RestObject

+ (User *)currentUser;
+ (void)setCurrentUser:(User *)currentUser;

@property (nonatomic, strong, readonly) NSString *profilePictureUrl;
@property (nonatomic, strong, readonly) NSString *user;
@property (nonatomic, strong, readonly) NSString *screen_name;

//Tweet added to User, so can be accessed globally
@property (nonatomic, strong) NSMutableArray *tweets;

@end
