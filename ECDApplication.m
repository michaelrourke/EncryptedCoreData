//
//  SSApplication.m
//  EncryptedCoreData
//
//  Created by Michael Rourke on 28/08/12.
//  Copyright (c) 2012 Michael Rourke. All rights reserved.
//

#import "ECDApplication.h"

@implementation ECDApplication

#pragma mark - Error Alerts
////////////////////////////////////////////////////////////////////////////////////////////////////////
//

// called from MRLOGERROR macro
- (void)logError:(NSError *)error inClass:(NSString *)classname inMethod:(SEL)method
{
    NSString *errorDescription = error.localizedDescription;
    if (!errorDescription) errorDescription = @"???";
    
    NSString *errorFailureReason = error.localizedFailureReason;
    if (!errorFailureReason) errorFailureReason = @"???";
    
    NSLog(@"[%@ %@] %@ (%@)", classname, NSStringFromSelector(method), errorDescription, errorFailureReason);
}

- (void)fileErrorAlert:(NSError *)error
{
 
}

@end
