//
//  SGCoreDataGrandCentralController.h
//  dicoreves
//
//  Created by Samuel Grau on 26/11/11.
//  Copyright (c) 2011 Samuel Grau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGCoreDataController.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@interface SGCoreDataGrandCentralController : NSObject {
    NSMutableDictionary * _coreDataControllers;
}

+ (SGCoreDataGrandCentralController *)instance;
- (SGCoreDataController *)controllerWithName:(NSString *)name;
- (BOOL)addController:(SGCoreDataController *)controller withName:(NSString *)name;
- (void)saveContexts;
- (void)releaseControllers;

@end
