//
//  Password.h
//  EncryptedCoreData
//
//  Created by Michael Rourke on 02/07/11.
//  Copyright (c) 2011 Michael Rourke. All rights reserved.
//

#import "ECDManagedObject.h"

@class ECDEntry;

@interface ECDPassword : ECDManagedObject

// note these are retain - not copy - so we need to be careful when setting
@property(nonatomic,strong) NSData   *pD;           // passwordData [short because exposed in data file ]
@property(nonatomic,strong) NSString *password;
@property(nonatomic,strong) NSDate   *modifiedDate;
@property(nonatomic,strong) ECDEntry    *o;            // owner [short because exposed in data file ]

@end


@interface ECDPassword (PrimitiveAccessors)

- (NSData *)primitivePD;
- (void)setPrimitivePD:(NSData *)value;

- (NSString *)primitivePassword;
- (void)setPrimitivePassword:(NSString *)value;

- (NSDate *)primitiveModifiedDate;
- (void)setPrimitiveModifiedDate:(NSDate *)value;

@end


