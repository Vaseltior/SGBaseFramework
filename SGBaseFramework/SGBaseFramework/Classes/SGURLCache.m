//
//  SGURLCache.m
//  SGBaseFramework
//
//  Created by Samuel Grau on 26/11/11.
//  Copyright (c) 2011 YouMag. All rights reserved.
//

#import "SGURLCache.h"

NSString * const kSGCEtagCacheDirectoryName = @"etag";

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@interface SGURLCache (Private) 

/**
 * Creates paths as necessary and returns the cache path for the given name.
 */
+ (NSString*)cachePathWithName:(NSString*)name;

@end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@implementation SGURLCache (Private)

+ (NSString*)cachePathWithName:(NSString*)name {
    return @"";
}

@end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@implementation SGURLCache


@synthesize diskCacheEnabled = _diskCacheEnabled;
@synthesize imageCacheEnabled = _imageCacheEnabled;
@synthesize cachePath = _cachePath;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - Singleton definition
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


GTMOBJECT_SINGLETON_BOILERPLATE(SGURLCache, instance)


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - Public
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (NSString*)etagCachePath {
    return [self.cachePath stringByAppendingPathComponent:kSGCEtagCacheDirectoryName];
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (NSString *)cachePathForKey:(NSString *)key {
    return [_cachePath stringByAppendingPathComponent:key];
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)storeData:(NSData *)data forKey:(NSString *)key {
    if (!_diskCacheEnabled) {
        NSString* filePath = [self cachePathForKey:key];
        NSFileManager* fm = [NSFileManager defaultManager];
        [fm createFileAtPath:filePath contents:data attributes:nil];
    }
}


@end
