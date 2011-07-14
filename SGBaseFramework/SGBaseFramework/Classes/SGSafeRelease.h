//
//  SGSafeRelease.h
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


////////////////////////////////////////////////////////////////////////////////
// Safe releases

static inline void sgReleaseSafely(NSObject **object);
static inline void sgInvalidateTimer(NSObject **object);

/**
 * Release a CoreFoundation object safely.
 */
static inline void sgReleaseCFSafely(NSObject **object);

/**
 * Shorthand for getting localized strings, 
 * used in formats
 */
static inline NSString *sgLocStr(NSString *key) {
    return [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil];
}
