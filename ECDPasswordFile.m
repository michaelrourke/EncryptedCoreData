/*
 *	PasswordFile.m
 *	EncryptedCoreData
 *
 *  Singleton to contain currently open file.
 *	
 *	Created by Michael Rourke on 29/07/12.
 *	Copyright 2012 Michael Rourke. All rights reserved.
 */

#import "ECDPasswordFile.h"

@interface ECDPasswordFile()
@property (nonatomic) ECDManagedDocument *currentDocument;
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator; 
@property (nonatomic) unsigned char *keySHA;
@property (nonatomic) NSInteger decryptFailCount;     // fail count since last open/reset/revert
@property (nonatomic) NSInteger decryptOKCount;       // OK count since last open/reset/revert
@property (nonatomic) BOOL decryptWarned;             // Warned off partial failures
@end

@implementation ECDPasswordFile
////////////////////////////////////////////////////////////////////////////////////////////////////////
//

// called early from AppDelegate
- (void)initializeCoreDataStack
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ECDDocument" withExtension:@"momd"];
    MRASSERT(modelURL, @"Failed to find model URL");
    
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    MRASSERT(mom, @"Failed to initialise model");
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    MRASSERT(psc, @"Failed to initialise persistent store coordinator");
    
    self.persistentStoreCoordinator = psc;
}

- (void)openPasswordFile:(NSURL *)fileName password:(NSString *)password completionHandler:(void (^)(OpenResult result))handler
{
    // stub only
}

- (void)closePasswordFile
{
    // stub only
}

#pragma mark - Decrypt/Encrypt callbacks
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
- (unsigned char *)passKeyWithManagedObjectContext:(NSManagedObjectContext *)moc
{
    MRASSERT(moc == self.currentDocument.managedObjectContext, @"Unrecognised managed object context");
    return self.keySHA;
}

//
// Set decrypt failure status
// Called from MyManagedObject.
//
- (void)setDecryptFailedWithManagedObjectContext:(NSManagedObjectContext *)moc boolValue:(BOOL)failed
{
    MRASSERT(moc == self.currentDocument.managedObjectContext, @"Unrecognised managed object context");
    
    if (failed)
        _decryptFailCount = self.decryptFailCount + 1;
    else
        _decryptOKCount = self.decryptOKCount + 1;

    // detect partial failure, warn once per open
    if (self.decryptOKCount > 0 && self.decryptFailCount > 0 && !self.decryptWarned) {
        _decryptWarned = YES;
        [self warnDecryptFailure];
    }
}

- (void)warnDecryptFailure
{
    [self performSelectorOnMainThread:@selector(postWarnDecryptFailure) withObject:nil waitUntilDone:NO];
}

- (void)postWarnDecryptFailure
{
    // stub only
}

#pragma mark - Singleton
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
+ (ECDPasswordFile *) instance
{
	static dispatch_once_t safer;
    static ECDPasswordFile *instance;
	
    dispatch_once(&safer, ^(void) {
        instance = [[ECDPasswordFile alloc] init];
    });

	return instance;
}
    
@end
