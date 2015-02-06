//
//  ChangeStateToAbrev.m
//  sweets
//
//  Created by Jake Lisby on 2/5/15.
//  Copyright (c) 2015 Rain Tomorrow. All rights reserved.
//

#import "ChangeStateToAbrev.h"
#import "NSString+USStateMap.h"

@implementation ChangeStateToAbrev

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return value? [value stateFullNameFromAbbreviation]: nil;
}

@end
