//
//  ConversationTableViewCell.m
//  sweets
//
//  Created by Jake Lisby on 2/5/15.
//  Copyright (c) 2015 Rain Tomorrow. All rights reserved.
//

#import "ConversationTableViewCell.h"

@interface ConversationTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *interiorBadge;

@end

@implementation ConversationTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    /// Needs 2 views to avoid antialiasing here. Yuck.
    self.unreadConversationBadge.layer.cornerRadius = 10.0;
    self.interiorBadge.layer.cornerRadius = 8.0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    /// Add seperator inset
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(82.0, self.frame.size.height - 1.0, self.frame.size.width - 90.0, 1.0)];
    separator.backgroundColor = [UIColor grayColor];
    [self addSubview:separator];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
