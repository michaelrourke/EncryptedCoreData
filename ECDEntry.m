//
//  Entry.m
//  EncryptedCoreData
//
//  Created by Michael Rourke on 05/06/11.
//  Copyright (c) 2011 Michael Rourke. All rights reserved.
//

#import "ECDManagedObject.h"
#import "ECDEntry.h"
#import "ECDGroup.h"

static NSArray *keys;

@implementation ECDEntry

@dynamic eD;
@dynamic modifiedDate;
@dynamic title;
@dynamic notes;
@dynamic url;
@dynamic username;

@dynamic g;
@dynamic p;

+ (void)initialize
{
    if (self == [ECDEntry class])
        keys  = @[TITLEKEY, NOTESKEY, URLKEY, USERNAMEKEY, MODIFIEDDATEKEY];
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    if ([self decryptFileData:[self primitiveED] keys:keys] == NO) {
        [self setPrimitiveTitle:decryptFailed];
        [self setPrimitiveUsername:decryptFailed];
        [self setPrimitiveNotes:decryptFailed];
    }
}

- (void)willSave
{
    [self setPrimitiveED:[self cryptDataWithKeys:keys]];
    [super willSave];
}

@end
