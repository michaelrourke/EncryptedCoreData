/*
 *	PasswordFile.h
 *	EncryptedCoreData
 *	
 *	Created by Michael Rourke on 29/07/12.
 *	Copyright 2012 Michael Rourke. All rights reserved.
 */

#import "ECDManagedDocument.h"

@interface ECDPasswordFile : NSObject
@property (readonly, nonatomic) ECDManagedDocument *currentDocument;
@property (readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

typedef enum { OpenResultSuccess, OpenResultFailure, OpenResultError } OpenResult;

+ (ECDPasswordFile *) instance;
- (void)initializeCoreDataStack;
- (void)openPasswordFile:(NSURL *)fileName password:(NSString *)password completionHandler:(void (^)(OpenResult success))handler;
- (void)closePasswordFile;

// help encrypt/decrypt communicate with current document
- (unsigned char *)passKeyWithManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)setDecryptFailedWithManagedObjectContext:(NSManagedObjectContext *)moc boolValue:(BOOL)val;
@end