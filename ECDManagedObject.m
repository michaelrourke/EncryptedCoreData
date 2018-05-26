//
//  MyManagedObject.m
//  EncryptedCoreData
//
//  Created by Michael Rourke on 01/07/11.
//  Copyright 2011 Michael Rourke. All rights reserved.
//
//  We save space by using UTF8String/stringWithUTF8String for NSString objects
//  rather than archive/dearchive. All keys are strings except for MODIFIEDDATEKEY.
//

#import "ECDManagedObject.h"
#import "ECDPasswordFile.h"
#import "ECDAES.h"

NSString * const decryptFailed = @"??????";

@implementation ECDManagedObject

- (BOOL)decryptFileData:(NSData *)fileData keys:(NSArray <NSString *> *)keys;
{
    // decrypt the file data, unpack the entry components, dearchive, return YES if successfull
    //
    // data layout:
    // numsections (int16_t)
    // section 0 size (int16_t)
    // section 1 size (int16_t)
    // ...
    // section 0
    // section 1
    // ...
    NSManagedObjectContext *moc = self.managedObjectContext;
    
    // decrypt
    ECDPasswordFile *singleton = [ECDPasswordFile instance];
    NSData *entryData = [ECDAES decrypt:fileData key:[singleton passKeyWithManagedObjectContext:moc]];
    [singleton setDecryptFailedWithManagedObjectContext:moc boolValue:!entryData];

    if (!entryData)
        return NO;
    
    NSInteger clearLength = entryData.length;
    unsigned char *clearData = (unsigned char *) entryData.bytes;
    int16_t *clearHeader = (int16_t *) clearData;
    
    NSInteger numSections = keys.count;
    NSInteger section = 0;

    if (clearHeader[section] != numSections)
        MREXCEPTION(@"wrong section count");
    
    unsigned char *str = (unsigned char *) &clearHeader[numSections + 1];
    
    for (section++; section <= numSections; section++) {
        NSString *key = keys[section-1];
        if ([key isEqualToString:MODIFIEDDATEKEY]) {
            NSData *value = [NSData dataWithBytes:str length:clearHeader[section]];
            [self setPrimitiveValue:[NSKeyedUnarchiver unarchiveObjectWithData:value] forKey:key];
        } else if (clearHeader[section])
            [self setPrimitiveValue:@((const char *)str) forKey:key];
        str += clearHeader[section];
    }
    
    MRASSERT(str == &clearData[clearLength], @"str != &clearData[clearLength]");
    return YES;
}

- (NSData *) cryptDataWithKeys: (NSArray <NSString *> *)keys
{
    NSInteger numSections = keys.count;
    __strong NSData **parts = (__strong NSData **) calloc(sizeof(NSData *), numSections);
    NSInteger clearLength = sizeof(int16_t) * (numSections + 1);
    NSInteger partNum;

    // pack all the entry components together and save in entryData
    for (partNum = 0; partNum < numSections; partNum++) {
        NSString *key = keys[partNum];
        if ([key isEqualToString:MODIFIEDDATEKEY])
            parts[partNum] = [NSKeyedArchiver archivedDataWithRootObject:[self primitiveValueForKey:key]];
        else {
            const char * UTF8str = ((NSString *) [self primitiveValueForKey:key]).UTF8String;
            if (UTF8str)
                parts[partNum] = [NSData dataWithBytes:UTF8str length:strlen(UTF8str) + 1];
            else   
                parts[partNum] = [NSData dataWithBytes:"" length:0];
        }
        clearLength += parts[partNum].length;
    }

    // see encrypt: need to leave space for padding (zero filled)
    char *clearData = calloc(1, clearLength + AES128PADDING(clearLength));
    int16_t *clearHeader = (int16_t *) clearData;
    
    // build header
    NSInteger section = 0;    
    clearHeader[section] = numSections;
    for (section++; section <= numSections; section++)
        clearHeader[section] = parts[section-1].length;
    
    // populate data section
    char *str = (char *) &clearHeader[numSections + 1];
    for (partNum = 0; partNum < numSections; partNum++) {
        NSInteger len = parts[partNum].length;
        [parts[partNum] getBytes:str length:len];
        str += len;
    }
    
    MRASSERT(str == &clearData[clearLength], @"str != &clearData[clearLength");
    
    // repackage as NSData
    NSData *entryData = [NSData dataWithBytesNoCopy:clearData length:clearLength];
    NSManagedObjectContext *moc = self.managedObjectContext;

    ECDPasswordFile *singleton = [ECDPasswordFile instance];
    NSData *cryptData = [ECDAES encrypt:entryData key:[singleton passKeyWithManagedObjectContext:moc]];
    if (!cryptData)
        MREXCEPTION(@"crypt failed");
    
    // tell ARC to release objects
    for (partNum = 0; partNum < numSections; partNum++)
        parts[partNum] = nil;
    
    free(parts);
    
    return cryptData;
}

@end
