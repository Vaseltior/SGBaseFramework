//
//  SGDHelper.m
//  SGBaseFramework
//
//  Created by Samuel Grau on 9/9/11.
//  Copyright 2011 YouMag. All rights reserved.
//

#import "SGDHelper.h"

@implementation SGDHelper

+ (id)vfk:(id)key wd:(NSDictionary *)aDict et:(Class)aClass dv:(id)defaultValue {
    
    if (nil == key) return defaultValue;
    id value = [aDict objectForKey:key];
    if (!value) return defaultValue;
    if (![value isKindOfClass:aClass]) {
        //NSLog(@"%@ %@", aClass, [value class]);
        return defaultValue;   
    }
    return value;
}


@end
