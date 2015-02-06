//
//  ConversationsTableViewController.h
//  sweets
//
//  Created by Jake Lisby on 2/5/15.
//  Copyright (c) 2015 Rain Tomorrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import "VBFPopFlatButton.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"

@interface ConversationsTableViewController : UITableViewController

@property (strong,nonatomic) NSMutableArray *conversations;

@end
