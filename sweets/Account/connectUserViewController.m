//
//  connectUserViewController.m
//  sweets
//
//  Created by Jake Lisby on 1/30/15.
//  Copyright (c) 2015 Rain Tomorrow. All rights reserved.
//

#import "connectUserViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <KBRoundedButton/KBRoundedButton.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface connectUserViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *modalFrame;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *consultantIDField;
- (IBAction)findMeDidPress:(id)sender;
@property (weak, nonatomic) IBOutlet KBRoundedButton *findMeButton;
@property (weak, nonatomic) IBOutlet KBRoundedButton *getStartedButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
- (IBAction)getStartedDidPress:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *fnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UILabel *fullNameDisplay;
@property (weak, nonatomic) IBOutlet UILabel *emailDisplay;
@property (weak, nonatomic) IBOutlet UILabel *phoneDisplay;
- (IBAction)verifiedMemberDidPress:(id)sender;
- (IBAction)notVerifiedMemberDidPress:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *moreInfoformView;

@end

@implementation connectUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.backgroundImageView.image = [self blurredBackground];
    
    // Delegates
    self.consultantIDField.delegate = self;
    self.fnameTextField.delegate = self;
    self.lnameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.phoneTextField.delegate = self;
    
    self.modalFrame.layer.cornerRadius = 5;
    self.modalFrame.layer.masksToBounds = YES;
    
    self.profileImage.layer.cornerRadius = 55;
    self.profileImage.layer.masksToBounds = YES;
    
    if (self.getStartedButton || self.fullNameDisplay){
        FBRequest *request = [FBRequest requestForMe];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // result is a dictionary with the user's Facebook data
                self.facebookData = (NSDictionary *)result;
                NSString *facebookID = self.facebookData[@"id"];
                
                // URL should point to https://graph.facebook.com/{facebookId}/picture?type=large&return_ssl_resources=1
                self.facebookProfileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.facebookProfileURL];
                
                // Run network request asynchronously
                [NSURLConnection sendAsynchronousRequest:urlRequest
                                                   queue:[NSOperationQueue mainQueue]
                                       completionHandler:
                 ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                     if (connectionError == nil && data != nil) {
                         // Set the image in the header imageView
                         self.profileImage.image = [UIImage imageWithData:data];
                     }
                 }];
            }
        }];
        if (self.fullNameDisplay){
            self.fullNameDisplay.text = self.memberData[@"mkName"];
            self.emailDisplay.text = self.memberData[@"mkEmail"];
            self.phoneDisplay.text = self.memberData[@"mkPhone"];
            self.consultantID = self.memberData[@"mkID"];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIImage *)blurredBackground {
    //    UIImage *blurredBackground = [[UIImage imageNamed:@"bg-blurred"] applyExtraLightEffect];
    //    return blurredBackground;
    
    return [UIImage imageNamed:@"blurredBack"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    if (self.findMeButton) {
        [self checkUser];
    } else if (self.getStartedButton){
        NSInteger nextTag = textField.tag + 1;
        if (nextTag == 2){
            [self.lnameTextField becomeFirstResponder];
        } else if (nextTag == 3){
            [self.emailTextField becomeFirstResponder];
        } else if (nextTag == 4){
            [self.phoneTextField becomeFirstResponder];
        } else{
            [textField resignFirstResponder];
            [self saveUserData];
        }
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (IBAction)findMeDidPress:(id)sender {
    [self checkUser];
}

-(void)checkUser{
    NSString *consultantID = self.consultantIDField.text;
    if([consultantID length] == 6){
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"checkNewUser" object:consultantID];
        }];
    } else{
        UIAlertController *newalertController = [UIAlertController
                                                 alertControllerWithTitle:@"A Slight Issue"
                                                 message:@"We're sorry, that consultant ID is not valid. Please try again."
                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *newcancelAction = [UIAlertAction
                                          actionWithTitle:NSLocalizedString(@"OK", @"Cancel action")
                                          style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction *action)
                                          {
                                          }];
        
        [newalertController addAction:newcancelAction];
        [self presentViewController:newalertController animated:YES completion:nil];
    }
}
- (IBAction)getStartedDidPress:(id)sender {
    [self saveUserData];
}
-(void)saveUserData{
    if (self.getStartedButton){
        if ([self.fnameTextField.text isEqualToString:@""]){ 
            UIAlertView *fnameAlert = [[UIAlertView alloc] initWithTitle:@"Something was Missed" message:@"Sorry about this, but a first name is required to move forward." delegate:self
                                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [fnameAlert show];
        } else if ([self.lnameTextField.text isEqualToString:@""]){
            UIAlertView *lnameAlert = [[UIAlertView alloc] initWithTitle:@"Something was Missed" message:@"Sorry about this, but a last name is required to move forward." delegate:self
                                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [lnameAlert show];
        } else if ([self.emailTextField.text isEqualToString:@""]){
            UIAlertView *emailAlert = [[UIAlertView alloc] initWithTitle:@"Something was Missed" message:@"Sorry about this, but an email address is required to move forward." delegate:self
                                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [emailAlert show];
        } else if ([self.phoneTextField.text isEqualToString:@""]){
            UIAlertView *phoneAlert = [[UIAlertView alloc] initWithTitle:@"Something was Missed" message:@"Sorry about this, but a phone number is required to move forward." delegate:self
                                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [phoneAlert show];
        } else {
            NSString *emailString = self.emailTextField.text; // storing the entered email in a string.**
            // Regular expression to checl the email format.
            NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
            NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailReg];
            if (([emailTest evaluateWithObject:emailString] != YES))
            {
                UIAlertView *emailAlert = [[UIAlertView alloc] initWithTitle:@"Issue with Email" message:@"We're sorry, the email address you entered is not correctly formatted. Use this format email@email.com" delegate:self
                                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [emailAlert show];
            } else {
                NSString *phoneNumber = self.phoneTextField.text;
                NSString *phoneRegex = @"[235689][0-9]{6}([0-9]{3})?";
                NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
                if(([phoneTest evaluateWithObject:phoneNumber] != YES)){
                    UIAlertView *phoneAlert = [[UIAlertView alloc] initWithTitle:@"Issue with Phone Number" message:@"We're sorry, the phone number you entered is not correctly formatted. Please only use nine numbers." delegate:self
                                                               cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    
                    [phoneAlert show];
                } else{
                    PFObject *member = [PFObject objectWithClassName:@"Members"];
                    member[@"consultantID"] = self.consultantID;
                    member[@"profileFName"] = self.fnameTextField.text;
                    member[@"profileLName"] = self.lnameTextField.text;
                    member[@"profileEmail"] = self.emailTextField.text;
                    member[@"profilePhone"] = self.phoneTextField.text;
                    member[@"memberFacebookID"] = self.facebookData[@"id"];
                    member[@"facebookLocation"] = self.facebookData[@"location"][@"name"];
                    member[@"facebookBirthday"] = self.facebookData[@"birthday"];
                    member[@"facebookProfileImage"] = self.facebookProfileURL;
                    member[@"didConnectDetails"] = @"1";
                    [member setObject:[PFUser currentUser] forKey:@"memberUser"];
                    [member saveEventually];
                    PFUser *currentUser = [PFUser currentUser];
                    currentUser[@"didConnectDetails"] = @"1";
                    [currentUser saveEventually];
                }
            }
        }
    }
    if (self.fullNameDisplay){
        PFQuery *query = [PFQuery queryWithClassName:@"Members"];
        // Retrieve the object by id
        [query getObjectInBackgroundWithId:self.memberData[@"objectID"] block:^(PFObject *member, NSError *error) {
            member[@"memberFacebookID"] = self.facebookData[@"id"];
            member[@"facebookLocation"] = self.facebookData[@"location"][@"name"];
            member[@"facebookBirthday"] = self.facebookData[@"birthday"];
            member[@"facebookProfileImage"] = self.facebookProfileURL;
            [member setObject:[PFUser currentUser] forKey:@"memberUser"];
            [member saveEventually];
        }];
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"didConnectDetails"] = @"1";
        [currentUser saveEventually];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if(textField.tag == 4){
        [self createInputAccessoryView];
        [textField setInputAccessoryView:self.inputAccView];
    }
}
-(void)createInputAccessoryView{
    // Create the view that will play the part of the input accessory view.
    // Note that the frame width (third value in the CGRectMake method)
    // should change accordingly in landscape orientation. But we don’t care
    // about that now.
    self.inputAccView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 310.0, 40.0)];
    
    // Set the view’s background color. We’ ll set it here to gray. Use any color you want.
    [self.inputAccView setBackgroundColor:[UIColor lightGrayColor]];
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setFrame:CGRectMake(260.0, 0.0f, 80.0f, 40.0f)];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnDone.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [btnDone addTarget:self action:@selector(doneTyping) forControlEvents:UIControlEventTouchUpInside];
    
    // Now that our buttons are ready we just have to add them to our view.
    [self.inputAccView addSubview:btnDone];
}
-(void)doneTyping{
    [self.phoneTextField resignFirstResponder];
}
- (IBAction)verifiedMemberDidPress:(id)sender {
    [self saveUserData];
}

- (IBAction)notVerifiedMemberDidPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tryUserAgain" object:self];
    }];
}
@end
