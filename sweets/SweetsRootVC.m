//
//  SweetsRootVC.m
//  sweets
//
//  Created by Jake Lisby on 1/29/15.
//  Copyright (c) 2015 Rain Tomorrow. All rights reserved.
//

#import "SweetsRootVC.h"
#import "connectUserViewController.h"
#import <PQFCustomLoaders/PQFCustomLoaders.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface SweetsRootVC ()

@property (strong, nonatomic) PQFCirclesInTriangle *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation SweetsRootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Adding my notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInUser:) name:@"signInUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tryUserAgain:) name:@"tryUserAgain" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNewUser:) name:@"checkNewUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutUser:) name:@"logoutUser" object:nil];
    
    self.activityIndicator = [[PQFCirclesInTriangle alloc]initLoaderOnView:self.view];
    self.activityIndicator.duration = 1.3;
    self.activityIndicator.loaderColor = [UIColor whiteColor];
    
    self.backgroundImageView.image = [self blurredBackground];
    
    [self.activityIndicator show];
    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        // do stuff with the user
        FBRequest *request = [FBRequest requestForMe];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // handle successful response
                PFUser *currentUser = [PFUser currentUser];
                if([currentUser[@"didConnectDetails"]  isEqual: @"1"]){
                    [self performSegueWithIdentifier:@"segueToHomeViewController" sender:self];
                } else{
                    [self performSegueWithIdentifier:@"segueFindUser" sender:self];
                }
            } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                        isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
                NSLog(@"The facebook session was invalidated");
                [self performSegueWithIdentifier:@"segueToLogin" sender:self];
            } else {
                NSLog(@"Some other error: %@", error);
            }
        }];
        
    } else {
        // show the signup or login screen
        [self performSegueWithIdentifier:@"segueToLogin" sender:self];
    }
}

-(UIImage *)blurredBackground {
    //    UIImage *blurredBackground = [[UIImage imageNamed:@"bg-blurred"] applyExtraLightEffect];
    //    return blurredBackground;
    
    return [UIImage imageNamed:@"blurredBack"];
}

- (void) checkNewUser:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"checkNewUser"]){
        NSString *consultantID = (NSString *)notification.object;
        PFQuery *query = [PFQuery queryWithClassName:@"Members"];
        [query whereKey:@"consultantID" equalTo:consultantID];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!object) {
                [self performSegueWithIdentifier:@"segueCreateConsultant" sender:consultantID];
            } else {
                // The find succeeded.
                NSString *combinedName = [NSString stringWithFormat:@"%@ %@",[object objectForKey:@"mkFName"],[object objectForKey:@"mkLName"]];
                NSString *mkEmail = [object objectForKey:@"mkEmail"];
                NSString *mkPhone = [object objectForKey:@"mkPhone"];
                NSString *objectID = object.objectId;
                NSDictionary *memberData = [[NSDictionary alloc] initWithObjectsAndKeys:objectID, @"objectID", consultantID, @"mkID", combinedName, @"mkName", mkEmail, @"mkEmail", mkPhone, @"mkPhone", nil];
                [self performSegueWithIdentifier:@"segueConfirmMember" sender:memberData];
            }
        }];
    }
    
}
- (void) tryUserAgain:(NSNotification *) notification
{
    [self performSegueWithIdentifier:@"segueFindUser" sender:self];
}
- (void) signInUser:(NSNotification *) notification
{
    [self performSegueWithIdentifier:@"segueFindUser" sender:self];
    // Set permissions required from the facebook user account
    /*NSArray *permissionsArray = @[ @"email", @"public_profile", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Try Again", nil];
            [alert show];
        } else {
            if (user.isNew) {
                [self performSegueWithIdentifier:@"segueFindUser" sender:self];
            } else {
                [self performSegueWithIdentifier:@"segueToHomeViewController" sender:self];
            }
        }
    }];*/
}

- (void) logoutUser:(NSNotification *) notification
{
    [PFUser logOut];
    [self performSegueWithIdentifier:@"segueToLogin" sender:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"segueCreateConsultant"]){
        connectUserViewController *controller = segue.destinationViewController;
        // Send data to destination view controller
        controller.consultantID = sender;
    } else if ([segue.identifier isEqualToString:@"segueConfirmMember"]){
        connectUserViewController *controller = segue.destinationViewController;
        // Send data to destination view controller
        controller.memberData = sender;
    }
}

@end
