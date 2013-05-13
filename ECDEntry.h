//
//  Entry.h
//  EncryptedCoreData
//
//  Created by Michael Rourke on 05/06/11.
//  Copyright (c) 2011 Michael Rourke. All rights reserved.
//

#import "ECDManagedObject.h"

@class ECDGroup;
@class ECDPassword;

@interface ECDEntry : ECDManagedObject 

// note these are retain - not copy - so we need to be careful when setting
@property(nonatomic,strong) NSData   *eD;              // entryData [short because exposed in data file ]
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *notes;
@property(nonatomic,strong) NSString *url;
@property(nonatomic,strong) NSString *username;
@property(nonatomic,strong) NSDate   *modifiedDate;
@property(nonatomic,strong) ECDGroup    *g;               // [short because exposed in data file ]
@property(nonatomic,strong) ECDPassword *p;               // [short because exposed in data file ]

@end


@interface ECDEntry (PrimitiveAccessors)

- (NSData *)primitiveED;
- (void)setPrimitiveED:(NSData *)value;

- (NSString *)primitiveTitle;
- (void)setPrimitiveTitle:(NSString *)value;

- (NSString *)primitiveNotes;
- (void)setPrimitiveNotes:(NSString *)value;

- (NSString *)primitiveUrl;
- (void)setPrimitiveUrl:(NSString *)value;

- (NSString *)primitiveUsername;
- (void)setPrimitiveUsername:(NSString *)value;

- (NSDate *)primitiveModifiedDate;
- (void)setPrimitiveModifiedDate:(NSDate *)value;

@end
