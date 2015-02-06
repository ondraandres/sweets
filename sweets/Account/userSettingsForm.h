//
//  userSettingsForm.h
//  sweets
//
//  Created by Jake Lisby on 2/4/15.
//  Copyright (c) 2015 Rain Tomorrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXForms.h"

@interface userSettingsForm : NSObject <FXForm>

@property (nonatomic, copy) NSString *profileFName;
@property (nonatomic, copy) NSString *profileLName;
@property (nonatomic, copy) NSString *profileEmail;
@property (nonatomic, copy) NSString *profilePhone;
@property (nonatomic, copy) NSString *mkUsername;
@property (nonatomic, copy) NSString *mkPassword;
@property (nonatomic, copy) NSString *StreetAddress;
@property (nonatomic, copy) NSString *City;
@property (nonatomic, copy) NSString *State;
@property (nonatomic, assign) NSUInteger ZipCode;
@property (nonatomic, strong) UIImage *profilePhoto;
@property (nonatomic, strong) NSDate *dateOfBirth;

@end
