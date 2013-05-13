//
//  MyManagedObject.h
//  EncryptedCoreData
//
//  Common encrypt/decrypt methods for all Core Data objects
//
//  Created by Michael Rourke on 01/07/11.
//  Copyright 2011 Michael Rourke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ECDCommon.h"

extern NSString * const decryptFailed;

@interface ECDManagedObject : NSManagedObject

- (BOOL)decryptFileData:(NSData *)fileData keys:(NSArray *)keys;
- (NSData *)cryptDataWithKeys:(NSArray *)keys;

@end
