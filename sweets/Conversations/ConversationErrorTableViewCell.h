//
//  ConversationErrorTableViewCell.h
//  sweets
//
//  Created by Jake Lisby on 2/5/15.
//  Copyright (c) 2015 Rain Tomorrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationErrorTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;

@end
