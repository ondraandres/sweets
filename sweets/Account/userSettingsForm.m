//
//  userSettingsForm.m
//  sweets
//
//  Created by Jake Lisby on 2/4/15.
//  Copyright (c) 2015 Rain Tomorrow. All rights reserved.
//

#import "userSettingsForm.h"
#import "ChangeStateToAbrev.h"

@implementation userSettingsForm

- (NSArray *)fields
{
    return @[
             
             @{FXFormFieldKey: @"profileFName", FXFormFieldTitle: @"First Name", FXFormFieldHeader: @"Profile"},
             
             @{FXFormFieldKey: @"profileLName", FXFormFieldTitle: @"Last Name"},
             @{FXFormFieldKey: @"profilePhone", FXFormFieldTitle: @"Phone Number"},
             @{FXFormFieldKey: @"profileEmail", FXFormFieldTitle: @"Email Address"},
             @{FXFormFieldKey: @"profilePhoto", FXFormFieldHeader: @"Profile Information"},
             @"dateOfBirth",
             
             @{FXFormFieldKey: @"mkUsername", FXFormFieldTitle: @"Username", FXFormFieldHeader: @"Mary Kay InTouch Login"},
             @{FXFormFieldKey: @"mkPassword", FXFormFieldTitle: @"Password"},
             
             @{FXFormFieldKey: @"StreetAddress", FXFormFieldHeader: @"Address",
               @"textField.autocapitalizationType": @(UITextAutocapitalizationTypeWords)},
             
             @"City",
             
             @{FXFormFieldKey: @"State", FXFormFieldPlaceholder: @"None", FXFormFieldAction: @"itemSelected", FXFormFieldOptions: @[@"AL", @"AK", @"AZ", @"AR", @"CA", @"CO", @"CT", @"DE", @"FL", @"GA", @"HI", @"ID", @"IL", @"IN", @"IA", @"KS", @"KY", @"LA", @"ME", @"MD", @"MA", @"MI", @"MN", @"MS", @"MO", @"MT", @"NE", @"NV", @"NH", @"NJ", @"NM", @"NY", @"NC", @"ND", @"OH", @"OK", @"OR", @"PA", @"RI", @"SC", @"SD", @"TN", @"TX", @"UT", @"VT", @"VA", @"WA", @"WV", @"WI", @"WY"],
               FXFormFieldValueTransformer: [[ChangeStateToAbrev alloc] init]},
             
             @"ZipCode",
             
             ];
}


@end
