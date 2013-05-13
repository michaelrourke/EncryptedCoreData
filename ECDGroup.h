//
//  Group.h
//  EncryptedCoreData
//
//  Created by Michael Rourke on 05/06/11.
//  Copyright (c) 2011 Michael Rourke. All rights reserved.
//

#import "ECDManagedObject.h"

@class ECDEntry;

@interface ECDGroup : ECDManagedObject 

// note these are retain - not copy - so we need to be careful when setting
@property(nonatomic,strong) NSData   *gD;           // groupData [short because exposed in data file ]
@property(nonatomic,strong) NSString *groupName;   
@property(nonatomic,strong) NSSet    *e;            // entries [short because exposed in data file ]

@end

@interface ECDGroup (PrimitiveAccessors)

- (NSString *)primitiveGroupName;
- (void)setPrimitiveGroupName:(NSString *)value;

- (NSData *)primitiveGD;
- (void)setPrimitiveGD:(NSData *)value;

@end