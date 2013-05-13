//
//  SSApplication.h
//  EncryptedCoreData
//
//  Created by Michael Rourke on 28/08/12.
//  Copyright (c) 2012 Michael Rourke. All rights reserved.
//


@interface ECDApplication : NSApplication
- (void)logError:(NSError *)error inClass:(NSString *)classname inMethod:(SEL)method;
- (void)fileErrorAlert:(NSError *)error;
@end
