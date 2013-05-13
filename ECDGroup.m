//
//  Group.m
//  EncryptedCoreData
//
//  Created by Michael Rourke on 05/06/11.
//  Copyright (c) 2011 Michael Rourke. All rights reserved.
//

#import "ECDManagedObject.h"
#import "ECDGroup.h"
#import "ECDEntry.h"

static NSArray *keys;

@implementation ECDGroup

@dynamic gD;
@dynamic groupName;
@dynamic e;

+ (void)initialize
{
    if (self == [ECDGroup class])
        keys = @[GROUPNAMEKEY];
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    if ([self decryptFileData:[self primitiveGD] keys:keys] == NO)
        [self setPrimitiveGroupName:decryptFailed];
}

- (void)willSave
{
    [self setPrimitiveGD:[self cryptDataWithKeys:keys]];
    [super willSave];
}

@end
