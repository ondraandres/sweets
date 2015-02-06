//
//  SettingsViewController.m
//  sweets
//
//  Created by Jake Lisby on 2/4/15.
//  Copyright (c) 2015 Rain Tomorrow. All rights reserved.
//

#import "SettingsViewController.h"
#import "userSettingsForm.h"
#import "NSString+USStateMap.h"

@interface SettingsViewController ()

@property (strong,nonatomic) VBFPopFlatButton *leftButton;

@end

@implementation SettingsViewController

- (void)awakeFromNib
{
    // setup form
    self.formController.form = [[userSettingsForm alloc] init];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self populateForm];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"SAVE"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(saveView:)];
    NSDictionary * attributes = @{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:14.0f], NSForegroundColorAttributeName:[UIColor blackColor]};
    [saveButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.leftButton = [[VBFPopFlatButton alloc] initWithFrame:CGRectMake(0, 0, 17, 17) buttonType:buttonMenuType buttonStyle:buttonPlainStyle animateToInitialState:NO];
    self.leftButton.tintColor = [UIColor blackColor];
    [self.leftButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *collapseButton = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    self.navigationItem.leftBarButtonItem = collapseButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMenuButton) name:@"changeMenuButton" object:nil];
}

-(void)populateForm{
    PFQuery *query = [PFQuery queryWithClassName:@"Members"];
    [query whereKey:@"memberUser" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *member, NSError *error) {
        if (member) {
            userSettingsForm *form = (userSettingsForm *)self.formController.form;
            form.profileFName = member[@"profileFName"];
            form.profileLName = member[@"profileLName"];
            form.profileEmail = member[@"profileEmail"];
            form.profilePhone = member[@"profilePhone"];
            PFFile *userImageFile = member[@"profileImage"];
            [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    form.profilePhoto = image;
                }
            }];
            form.dateOfBirth = member[@"profileDOB"];
            PFUser *currentUser = [PFUser currentUser];
            form.mkUsername = currentUser[@"mkUsername"];
            form.mkPassword = currentUser[@"mkPassword"];
            if(member[@"profileStreetAddress"]){
                form.StreetAddress = member[@"profileStreetAddress"];
            } else{
                form.StreetAddress = member[@"consultantStreetAddress"];
            }
            if(member[@"profileCity"]){
                form.City = member[@"profileCity"];
            } else{
                form.City = member[@"consultantCity"];
            }
            if(member[@"profileState"]){
                form.State = member[@"profileState"];
            } else{
                form.State = member[@"consultantState"];
            }
            if(member[@"profileZipcode"]){
                form.ZipCode = [member[@"profileZipcode"] intValue];
            } else{
                form.ZipCode = [member[@"consultantZip"] intValue];
            }
            [self.formController.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) btnClicked:(id)sender{
    [self.sideMenuViewController presentLeftMenuViewController];
    [self.leftButton animateToType:buttonCloseType];
}
-(void)changeMenuButton{
    [self.leftButton animateToType:buttonMenuType];
}

- (IBAction)saveView:(id)sender {
    [self.view endEditing:YES];
    
    userSettingsForm *form = self.formController.form;
        
    PFQuery *query = [PFQuery queryWithClassName:@"Members"];
    [query whereKey:@"memberUser" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *member, NSError *error) {
        NSString *fileName;
        
        if (form.profileFName != nil){
            member[@"profileFName"] = form.profileFName;
            fileName = [NSString stringWithFormat:@"%@-profileImage.png",form.profileFName];
        }
        if (form.profileLName != nil){
            member[@"profileLName"] = form.profileLName;
            fileName = [NSString stringWithFormat:@"%@-profileImage.png",form.profileLName];
        }
        NSString *emailString = form.profileEmail; // storing the entered email in a string.**
        // Regular expression to checl the email format.
        NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailReg];
        if (([emailTest evaluateWithObject:emailString] != YES))
        {
            UIAlertView *emailAlert = [[UIAlertView alloc] initWithTitle:@"Issue with Email" message:@"We're sorry, the email address you entered is not correctly formatted. Use this format email@email.com" delegate:self
                                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [emailAlert show];
        } else {
            member[@"profileEmail"] = form.profileEmail;
        }
        NSString *phoneNumber = [[form.profilePhone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        NSString *phoneRegex = @"[235689][0-9]{6}([0-9]{3})?";
        NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
        if(([phoneTest evaluateWithObject:phoneNumber] != YES)){
            UIAlertView *phoneAlert = [[UIAlertView alloc] initWithTitle:@"Issue with Phone Number" message:@"We're sorry, the phone number you entered is not correctly formatted. Please only use nine numbers." delegate:self
                                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
            [phoneAlert show];
        } else{
            member[@"profilePhone"] = form.profilePhone;
        }
        if (form.mkUsername != nil || form.mkPassword != nil){
            PFUser *currentUser = [PFUser currentUser];
            if (form.mkUsername != nil){
                currentUser[@"mkUsername"] = form.mkUsername;
            }
            if (form.mkPassword != nil){
                currentUser[@"mkPassword"] = form.mkPassword;
            }
            if (form.mkUsername != nil && form.mkPassword != nil){
                currentUser[@"canUseMK"] = @"1";
            }
            [currentUser saveEventually];
        }
        if (form.StreetAddress != nil){
            member[@"profileStreetAddress"] = form.StreetAddress;
        }
        if (form.City != nil){
            member[@"profileCity"] = form.City;
        }
        if (form.State != nil){
            member[@"profileState"] = form.State;
        }
        NSString *checkZipCode = [NSString stringWithFormat:@"%lu", (unsigned long)form.ZipCode];
        if ([checkZipCode length] == 5){
            member[@"profileZipcode"] = [NSNumber numberWithUnsignedShort:form.ZipCode];
        }
        else if (form.ZipCode == 0){
        }
        else{
            [[[UIAlertView alloc] initWithTitle:@"Incorrect Format" message:@"We're sorry, that Zip Code is not correctly formatted. Please make sure it's only 5 digits." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            return;
        }
        if (form.profilePhoto != nil){
            NSData *imageData = UIImagePNGRepresentation(form.profilePhoto);
            PFFile *imageFile = [PFFile fileWithName:fileName data:imageData];
            member[@"profileImage"] = imageFile;
        }
        if (form.dateOfBirth != nil){
            member[@"profileDOB"] = form.dateOfBirth;
        }
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.labelText = @"Saving";
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Save the updates
            [member saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    // Dismiss the CreateNewCustomerViewController and show the UserHomeViewController
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    UIAlertController *alertController = [UIAlertController
                                                          alertControllerWithTitle:@"Saving Issue"
                                                          message:@"We're sorry, there was an issue saving your changes. Do you want to try again?"
                                                          preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancelAction = [UIAlertAction
                                                   actionWithTitle:NSLocalizedString(@"Nevermind", @"Cancel action")
                                                   style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action)
                                                   {
                                                       [self.navigationController popViewControllerAnimated:YES];
                                                   }];
                    
                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"Try Again", @"OK action")
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                   [member saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                       if (!error) {
                                                           [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                           UIAlertController *newalertController = [UIAlertController
                                                                                                    alertControllerWithTitle:@"Saving Successful"
                                                                                                    message:@"That fixed it! Sorry for the inconvinence!"
                                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                                           
                                                           UIAlertAction *newcancelAction = [UIAlertAction
                                                                                             actionWithTitle:NSLocalizedString(@"OK", @"Cancel action")
                                                                                             style:UIAlertActionStyleCancel
                                                                                             handler:^(UIAlertAction *action)
                                                                                             {
                                                                                                 [self.navigationController popViewControllerAnimated:YES];
                                                                                             }];
                                                           
                                                           [newalertController addAction:newcancelAction];
                                                           [self presentViewController:newalertController animated:YES completion:nil];
                                                       }
                                                       else{
                                                           [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                           UIAlertController *newalertController = [UIAlertController
                                                                                                    alertControllerWithTitle:@"Saving Issue"
                                                                                                    message:@"We're sorry, there was still an issue saving your updates. Please try again later."
                                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                                           
                                                           UIAlertAction *newcancelAction = [UIAlertAction
                                                                                             actionWithTitle:NSLocalizedString(@"OK", @"Cancel action")
                                                                                             style:UIAlertActionStyleCancel
                                                                                             handler:^(UIAlertAction *action)
                                                                                             {
                                                                                                 [self.navigationController popViewControllerAnimated:YES];
                                                                                             }];
                                                           
                                                           [newalertController addAction:newcancelAction];
                                                           [self presentViewController:newalertController animated:YES completion:nil];
                                                       }
                                                   }];
                                               }];
                    
                    [alertController addAction:cancelAction];
                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
        
    }];
}
- (void)itemSelected {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
