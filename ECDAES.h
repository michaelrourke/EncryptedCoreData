//
//  AES.h
//  EncryptedCoreData
//
//  Created by Michael Rourke on 09/06/11.
//  Copyright 2011 Michael Rourke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECDAES : NSObject

+ (NSData *)encrypt:(NSData *)clear key:(unsigned char *)AESKey;
+ (NSData *)decrypt:(NSData *)cypher key:(unsigned char *)AESKey;
+ (unsigned char *)make384Key:(NSString *)key;

@end
