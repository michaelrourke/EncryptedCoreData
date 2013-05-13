//
//  Password.m
//  EncryptedCoreData
//
//  Created by Michael Rourke on 02/07/11.
//  Copyright (c) 2011 Michael Rourke. All rights reserved.
//

#import "ECDManagedObject.h"
#import "ECDPassword.h"

static NSArray *keys;

@implementation ECDPassword

@dynamic pD;
@dynamic password;
@dynamic modifiedDate;

@dynamic o;

+ (void)initialize
{
    if (self == [ECDPassword class])
        keys = @[PASSWORDKEY, MODIFIEDDATEKEY];
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    if ([self decryptFileData:[self primitivePD] keys:keys] == NO)
        [self setPrimitivePassword:decryptFailed];
}

- (void)willSave
{
    [self setPrimitivePD:[self cryptDataWithKeys:keys]];
    [super willSave];
}

@end
