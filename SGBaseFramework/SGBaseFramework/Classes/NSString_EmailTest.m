//
//  YMEmailTest.m
//  BaseFramework
//
//  Created by Samuel Grau on 20/06/11.
//  Copyright 2011 YouMag. All rights reserved.
//

#import "NSString_EmailTest.h"
#import "SGBaseFrameworkHeader.h"

@implementation NSString_EmailTest


- (void)testEmailValidation {
    NSString *e = [[NSString alloc] initWithString:@"samuel.grau@gmailcom"];
    BOOL b = [e isValidEMail];
    STAssertFalse(b, @"Email should be invalid", nil);
    
    [e release]; e = nil;
    e = [[NSString alloc] initWithString:@"samuel.grau@gmail.com"];
    b = [e isValidEMail];
    STAssertTrue(b, @"Email should be valid", nil);    
}

@end
