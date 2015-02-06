//
//  ConversationModel.h
//  sweets
//
//  Created by Jake Lisby on 2/5/15.
//  Copyright (c) 2015 Rain Tomorrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ConversationModel : NSObject
@property (strong, nonatomic) NSString *lastActivityDateShortDescription, *participants, *lastMessage;
@property (strong, nonatomic) PFObject *senderAvatar;
@property (strong, nonatomic) NSNumber *unreadCount, *threadID;
@end
