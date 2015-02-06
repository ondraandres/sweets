//
//  ConversationTableViewCell.h
//  sweets
//
//  Created by Jake Lisby on 2/5/15.
//  Copyright (c) 2015 Rain Tomorrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *conversationMembers;
@property (weak, nonatomic) IBOutlet UILabel *conversationPreview;
@property (weak, nonatomic) IBOutlet UILabel *conversationDate;
@property (weak, nonatomic) IBOutlet UIView *unreadConversationBadge;

@end
