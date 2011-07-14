//
//  NSObject+Extensions.h
//  SGBaseFramework
//
//  Created by Samuel Grau on 14/07/11.
//  Copyright 2011 Samuel Grau. All rights reserved.
//


@interface NSObject (Extensions)

- (id)performSelectorIfResponds:(SEL)aSelector;
- (id)performSelectorIfResponds:(SEL)aSelector withObject:(id)anObject;

@end
