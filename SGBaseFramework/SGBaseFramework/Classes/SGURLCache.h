//
//  SGURLCache.h
//  SGBaseFramework
//
//  Created by Samuel Grau on 26/11/11.
//  Copyright (c) 2011 YouMag. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kSGCEtagCacheDirectoryName;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@interface SGURLCache : NSObject {
    NSString * _cachePath;
    NSString * _name;
    
    BOOL _diskCacheEnabled;
    BOOL _imageCacheEnabled;
}

/**
 * Disables the disk cache. Disables etag support as well.
 */
@property (nonatomic, assign) BOOL diskCacheEnabled;

/**
 * Disables the in-memory cache for images.
 */
@property (nonatomic) BOOL imageCacheEnabled;

/**
 * Gets the path to the directory of the disk cache.
 */
@property (nonatomic, copy) NSString * cachePath;

/**
 * Gets the path to the directory of the disk cache for etags.
 */
@property (nonatomic, readonly) NSString * etagCachePath;

/**
 * The maximum number of pixels to keep in memory for cached images.
 *
 * Setting this to zero will allow an unlimited number of images to be cached.  The default
 * is zero.
 */
@property (nonatomic) NSUInteger maxPixelCount;

/**
 * The amount of time to set back the modification timestamp on files when invalidating them.
 */
@property (nonatomic) NSTimeInterval invalidationAge;

+ (SGURLCache *)instance;

@end
