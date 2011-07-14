//
//  NSObject+Extensions.m
//  SGBaseFramework
//
//  Created by Samuel Grau on 14/07/11.
//  Copyright 2011 Samuel Grau. All rights reserved.
//

#import "NSObject+Extensions.h"

@implementation NSObject (Extensions)

- (id)performSelectorIfResponds:(SEL)aSelector
{
    if ( [self respondsToSelector:aSelector] ) {
        return [self performSelector:aSelector];
    }
    return NULL;
}

- (id)performSelectorIfResponds:(SEL)aSelector withObject:(id)anObject
{
    if ( [self respondsToSelector:aSelector] ) {
        return [self performSelector:aSelector withObject:anObject];
    }
    return NULL;
}

@end
