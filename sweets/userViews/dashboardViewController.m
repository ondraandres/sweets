//
//  dashboardViewController.m
//  sweets
//
//  Created by Jake Lisby on 2/3/15.
//  Copyright (c) 2015 Rain Tomorrow. All rights reserved.
//

#import "dashboardViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "RESideMenu.h"
#import "VBFPopFlatButton.h"

@interface dashboardViewController ()

@property(strong,nonatomic) VBFPopFlatButton *leftButton;

@end

@implementation dashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.leftButton = [[VBFPopFlatButton alloc] initWithFrame:CGRectMake(0, 0, 17, 17) buttonType:buttonMenuType buttonStyle:buttonPlainStyle animateToInitialState:NO];
    self.leftButton.tintColor = [UIColor blackColor];
    [self.leftButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *collapseButton = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    self.navigationItem.leftBarButtonItem = collapseButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMenuButton) name:@"changeMenuButton" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) btnClicked:(id)sender{
    [self.sideMenuViewController presentLeftMenuViewController];
    [self.leftButton animateToType:buttonCloseType];
}
- (void)changeMenuButton{
    [self.leftButton animateToType:buttonMenuType];
}
@end
