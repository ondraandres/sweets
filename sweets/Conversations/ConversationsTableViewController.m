//
//  ConversationsTableViewController.m
//  sweets
//
//  Created by Jake Lisby on 2/5/15.
//  Copyright (c) 2015 Rain Tomorrow. All rights reserved.
//

#import "ConversationsTableViewController.h"
#import "ConversationTableViewCell.h"
#import "ConversationErrorTableViewCell.h"
#import "ConversationModel.h"

static NSString *conversationCellReuseID= @"conversationCell";
static NSString *errorCellReuseID = @"conversationErrorCell";

@interface ConversationsTableViewController ()

@property (strong,nonatomic) VBFPopFlatButton *leftButton;
@property (strong, nonatomic) ConversationErrorTableViewCell *errorCell;

@end

@implementation ConversationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    VBFPopFlatButton *rightButton = [[VBFPopFlatButton alloc] initWithFrame:CGRectMake(0, 0, 17, 17) buttonType:buttonAddType buttonStyle:buttonPlainStyle animateToInitialState:NO];
    rightButton.tintColor = [UIColor blackColor];
    [rightButton addTarget:self action:@selector(createClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightCollapseButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightCollapseButton;
    
    self.leftButton = [[VBFPopFlatButton alloc] initWithFrame:CGRectMake(0, 0, 17, 17) buttonType:buttonMenuType buttonStyle:buttonPlainStyle animateToInitialState:NO];
    self.leftButton.tintColor = [UIColor blackColor];
    [self.leftButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *collapseButton = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    self.navigationItem.leftBarButtonItem = collapseButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMenuButton) name:@"changeMenuButton" object:nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Removing extra cells and separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor lightGrayColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];
    
    if (!self.conversations) [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.tableView numberOfSections] > 0) [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

-(void) btnClicked:(id)sender{
    [self.sideMenuViewController presentLeftMenuViewController];
    [self.leftButton animateToType:buttonCloseType];
}
- (void)changeMenuButton{
    [self.leftButton animateToType:buttonMenuType];
}

-(void) createClicked:(id)sender{
    [self performSegueWithIdentifier:@"selectRecepients" sender:self];
}

// MARK: Data
- (void)reloadData {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![self conversationsExist]) {
        return 1;
    } else {
        return [self.conversations count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self conversationsExist]) {
        return 200.0;
    } else {
        return 75.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self conversationsExist]) {
        self.errorCell = (ConversationErrorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:errorCellReuseID forIndexPath:indexPath];
        [self.errorCell.reloadButton addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventTouchUpInside];
        return self.errorCell;
    } else {
        ConversationTableViewCell *cell = (ConversationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:conversationCellReuseID forIndexPath:indexPath];
        
        ConversationModel *conversation = [self.conversations objectAtIndex:indexPath.row];
        
        NSNumber* unreadCount = conversation.unreadCount;
        int unread = [unreadCount intValue];
        cell.unreadConversationBadge.hidden = (unread == 0);
        
        cell.conversationMembers.text = conversation.participants;
        
        cell.conversationPreview.text = conversation.lastMessage;
        cell.conversationDate.text = conversation.lastActivityDateShortDescription;
        
        // Image from Web
        if(conversation.senderAvatar){
            [cell.profileImage setImage:conversation.senderAvatar];
        } else{
            [cell.profileImage setImage:[UIImage imageNamed:@"maskIcon"]];
        }
        cell.profileImage.layer.masksToBounds = YES;
        cell.profileImage.layer.cornerRadius = 25.0;
        
        return cell;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)conversationsExist {
    return (self.conversations && self.conversations.count > 0);
}

@end
