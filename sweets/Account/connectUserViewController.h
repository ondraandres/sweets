//
//  connectUserViewController.h
//  sweets
//
//  Created by Jake Lisby on 1/30/15.
//  Copyright (c) 2015 Rain Tomorrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface connectUserViewController : UIViewController

@property (strong, nonatomic) NSDictionary *facebookData;
@property (strong, nonatomic) NSString *consultantID;
@property (strong, nonatomic) NSURL *facebookProfileURL;
@property (strong, nonatomic) NSDictionary *memberData;
@property (nonatomic, retain) UIView *inputAccView;

@end
