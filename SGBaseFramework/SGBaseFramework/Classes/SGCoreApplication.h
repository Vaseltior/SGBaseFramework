//
//  SGCoreApplication.h
//  SGBaseFramework
//
//  Created by Samuel Grau on 16/07/11.
//  Copyright 2011 YouMag. All rights reserved.
//

#ifndef SGBaseFramework_SGCoreApplication_h
#define SGBaseFramework_SGCoreApplication_h

static inline NSString *sgApplicationName(void) {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

static inline NSString *sgApplicationVersion(void) {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

static inline NSString *sgApplicationBundleIdentifier(void) {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

#endif
