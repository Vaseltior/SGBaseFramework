//
//  SGDictionaryHelper.m
//
//  Created by Samuel Grau on 6/29/11.
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

#import "SGDictionaryHelper.h"

@implementation SGDictionaryHelper

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (id)valueForKey:(id)key 
     inDictionary:(NSDictionary *)aDict 
     expectedType:(Class)aClass 
  andDefaultValue:(id)defaultValue {
    
    if (nil == key) return defaultValue;
    id value = [aDict objectForKey:key];
    if (!value) return defaultValue;
    if (![value isKindOfClass:aClass]) {
        //NSLog(@"%@ %@", aClass, [value class]);
        return defaultValue;   
    }
    return value;
}

+ (id)vfk:(id)key 
     idic:(NSDictionary *)aDict 
       et:(Class)aClass 
       dv:(id)defaultValue {
    return [SGDictionaryHelper valueForKey:key inDictionary:aDict expectedType:aClass andDefaultValue:defaultValue];
}


@end
