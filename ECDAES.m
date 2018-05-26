//
//  AES.m
//  EncryptedCoreData
//
//  Created by Michael Rourke on 09/06/11.
//  Copyright 2011 Michael Rourke. All rights reserved.
//
//  Thanks to Paul Miller jettero@cpan.org https://github.com/jettero
//  for his BlowFish example code https://gist.github.com/96410
//  which was adapted after reading chapter 9 of Bruce Schneier's
//  Applied Cryptography (Cipher Block Chaining Mode)
//
//  Further adapted to use SHA256 and AES256.
//  With reference to http://robnapier.net/blog/aes-commoncrypto-564
//
//  Note salted passwords are recommended - but their primary use is a dictionary attack
//  against a large store of encrypted passwords. This isn't a likely attack vector for
//  this application (although a dictionary attack using the given salt is). So in this
//  case, to maintain simplicity, the salt is fixed. It could be set on a per file basis
//  as a future extension.
//
//  (Note: we do salt the encryption mechanism by seeding the iv with random data.)
//
//  NOTE: A corrupted object will look the same as a decrypt failure.
//
//        Adding a further SHA1 of the crypted text would allow detection of corruption...
//        but it would not protect against deliberate crypted text change (with a regenerated SHA1)
//
//-----------------------------------------------------------------------------------------------------------
//
//  How big a key is strong enough?
//
//  DSD approval for the use of Suite B cryptography for CONFIDENTIAL and above [2012]
//  ==================================================================================
//
//  The following table details the DSD-endorsed Suite B algorithms and the associated parameters
//  required to protect, CONFIDENTIAL, SECRET and TOP SECRET information.
//
//             Cryptographic algorithm  Applicable   Requirements for information  Requirements for information
//  Function   or protocol              standards    classified up to SECRET       classified TOP SECRET
//
//  Encryption AES                      FIPS 197     128-bit key                   256-bit key
//                                                   256-bit key
//
//  Hashing    SHA                      FIPS 180-3   SHA-256                       SHA-384
//                                                   SHA-384
//
//-----------------------------------------------------------------------------------------------------------

#import "ECDCommon.h"
#import "ECDAES.h"
#import <Security/SecRandom.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import <CommonCrypto/CommonDigest.h>

const CCAlgorithm kAlgorithm          = kCCAlgorithmAES128;     // AES with 128bit blocks
const NSUInteger  kAlgorithmBlockSize = kCCBlockSizeAES128;     // 16 bytes
const NSUInteger  kAlgorithmIVSize    = kCCBlockSizeAES128;     // 16 bytes

const NSUInteger  kAlgorithmKeySize   = AES_KEY_LENGTH;         // kCCKeySizeAES256 = 32 bytes
const char        kPBKDFSalt[] = "YOUROWNSALTHERE";             // use your own salt here
const NSUInteger  kPBKDFSaltSize = sizeof(kPBKDFSalt) - 1;
const NSUInteger  kPBKDFRoundsSHA384  = 3900;                   // ~100ms on an iPhone 4 ~77ms on iPad 2

@implementation ECDAES

// generate AES key
+ (unsigned char *)make384Key:(NSString *)key
{
    unsigned char *AESKey = malloc(kAlgorithmKeySize);
    if (!AESKey)
        return (unsigned char *)nil;

    // SHA384_DIGEST_LENGTH = 48
    // kCCKeySizeAES256 = 32

    int result = CCKeyDerivationPBKDF(kCCPBKDF2,                 // algorithm
                                      key.UTF8String,            // password
                                      strlen(key.UTF8String),    // passwordLength
                                      (uint8_t *) kPBKDFSalt,    // salt
                                      kPBKDFSaltSize,            // saltLen
                                      kCCPRFHmacAlgSHA384,       // PRF
                                      kPBKDFRoundsSHA384,        // rounds
                                      AESKey,                    // derivedKey
                                      kAlgorithmKeySize);        // derivedKeyLen   // ignoring 16 bytes of generated key
    
    MRASSERT(result == kCCSuccess, @"Unable to create AES key: %d", result);
    
    return AESKey;
}


#define IV_SIZE kAlgorithmBlockSize          // initialisation vector size
#define IV_PADI (kAlgorithmBlockSize+2)      // include 2 extra bytes:
                                             //   number of pad chars on the last block, plus a version number
#define CRYPT_VERSION 0                      // version number - for future use

// output clearText components:
//
// a. initialization vector (ivec) - kAlgorithmBlockSize [16]
// b. padding size (ivec[IV_SIZE]) -                     [1]
// c. version info -                                     [1]
// d. SHA1(ivec, cleartext) - CC_SHA1_DIGEST_LENGTH      [20]
// e. encrypt(cleartext)
// f. padding bytes (.) - 0..kAlgorithmBlockSize-1 bytes
//
// ivec is random data, so same cleartext will encrypt differently each time
// SHA1 provides verification of completeness, and as it contains ivec will be different each time
//
+ (NSData *)encrypt:(NSData *)clear key:(unsigned char *)AESKey
{
    unsigned int clearLength  = (unsigned int) clear.length;
    unsigned char *clearText = (unsigned char *) clear.bytes;
    unsigned int padding = AES128PADDING(clearLength);
    unsigned int paddedLength = clearLength + padding;
    unsigned int allocSize = paddedLength + IV_PADI + CC_SHA1_DIGEST_LENGTH;
     
    unsigned char *cryptOut  = malloc(allocSize);
    if (!cryptOut)
        return (NSData *)nil;   // malloc failure
        
    unsigned char *ivec      = &cryptOut[0];
    unsigned char *SHA1      = &cryptOut[IV_PADI];
    unsigned char *cryptText = &cryptOut[IV_PADI + CC_SHA1_DIGEST_LENGTH];
    
    if (SecRandomCopyBytes(kSecRandomDefault, IV_SIZE, ivec) != 0) {
        free(cryptOut);
        return (NSData *)nil;   // failed to create ivec
    }
    ivec[IV_SIZE]   = padding;
    ivec[IV_SIZE+1] = CRYPT_VERSION;        // version number
    
    // build verification SHA1 (ivec, cleartext)
    CC_SHA1_CTX SHA1c;
    CC_SHA1_Init(&SHA1c);
    CC_SHA1_Update(&SHA1c, ivec, IV_SIZE);
    CC_SHA1_Update(&SHA1c, clearText, clearLength);
    CC_SHA1_Final(SHA1, &SHA1c);
    
    size_t outLength;
    int result = CCCrypt(kCCEncrypt,          // operation
                         kAlgorithm,          // Algorithm
                         0,                   // options (do our own padding)
                         AESKey,              // key
                         kAlgorithmKeySize,   // keylength
                         ivec,                // iv
                         clearText,           // dataIn
                         paddedLength,        // dataInLength,
                         cryptText,           // dataOut
                         paddedLength,        // dataOutAvailable
                         &outLength);         // dataOutMoved
    
    MRASSERT(result == kCCSuccess && outLength == paddedLength, @"Unable to encrypt: %d len: %zd", result, outLength);
    
    return [NSData dataWithBytesNoCopy:cryptOut length:allocSize];
}

+ (NSData *)decrypt:(NSData *)cypher key:(unsigned char *)AESKey
{  
    unsigned int allocSize = (unsigned int) cypher.length;
    unsigned char * cryptIn = (unsigned char *) cypher.bytes;
    
    int paddedLength = allocSize - IV_PADI - CC_SHA1_DIGEST_LENGTH;
    if (paddedLength < 0 || paddedLength % kAlgorithmBlockSize)
        return (NSData *) nil;  // bad crypt length - some sort of corruption
    
    unsigned char *ivec      = &cryptIn[0];
    unsigned char *SHA1      = &cryptIn[IV_PADI];
    unsigned char *cryptText = &cryptIn[IV_PADI + CC_SHA1_DIGEST_LENGTH];
    
    unsigned int padding = ivec[IV_SIZE];
    unsigned int version = ivec[IV_SIZE+1];
    if (padding >= kAlgorithmBlockSize || version != CRYPT_VERSION)
        return (NSData *) nil;  // bad padding - some sort of corruption
    
    unsigned int clearLength = paddedLength - padding;
    
    // ivec is changed during decrypt process - so create SHA1 first
    CC_SHA1_CTX SHA1c;
    unsigned char SHA1chk[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1_Init(&SHA1c);
    CC_SHA1_Update(&SHA1c, ivec, IV_SIZE);
    
    unsigned char *clearText = malloc(paddedLength);
    if (!clearText)
        return (NSData *) nil;  // malloc failure
    
    size_t outLength;
    int result = CCCrypt(kCCDecrypt,          // operation
                         kAlgorithm,          // Algorithm
                         0,                   // options (do our own padding)
                         AESKey,              // key
                         kAlgorithmKeySize,   // keylength
                         ivec,                // iv
                         cryptText,           // dataIn
                         paddedLength,        // dataInLength,
                         clearText,           // dataOut
                         paddedLength,        // dataOutAvailable
                         &outLength);         // dataOutMoved
    
    MRASSERT(result == kCCSuccess && outLength == paddedLength, @"Unable to decrypt: %d len: %zd", result, outLength);
    
    CC_SHA1_Update(&SHA1c, clearText, clearLength);
    CC_SHA1_Final(SHA1chk, &SHA1c);
    if (memcmp(SHA1, SHA1chk, CC_SHA1_DIGEST_LENGTH) != 0) {
        free(clearText);
        return (NSData *) nil;  // verification failed - corruption or pad passkey
    }
    
    return [NSData dataWithBytesNoCopy:clearText length:clearLength];
}

@end
