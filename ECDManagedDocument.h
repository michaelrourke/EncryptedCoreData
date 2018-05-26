//
//  SSManagedDocument.h
//  EncryptedCoreData
//
//  Created by Michael Rourke on 04/09/12.
//  Copyright (c) 2012 Michael Rourke. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <AppKit/NSPersistentDocument.h>

@interface ECDManagedDocument : NSPersistentDocument
@property (nonatomic) NSError *lastError;
@end
