//
//  NSObject+Extensions.m
//  SGBaseFramework
//
//  Created by Samuel Grau on 14/07/11.
//  Copyright 2011 Samuel Grau. 
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
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