//
//  BCMMerchantManager.m
//  Merchant
//
//  Created by User on 11/10/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "BCMMerchantManager.h"

#import "PEPinEntryController.h"

#import "SSKeyChain.h"

#import "Merchant.h"

NSString *const kBCMBusinessNameSettingsKey = @"BCMBusinessNameSettings";
NSString *const kBCMBusinessAddressSettingsKey = @"BCMBusinessAddressSettings";
NSString *const kBCMTelephoneSettingsKey = @"BCMTelephoneSettings";
NSString *const kBCMDescriptionSettingsKey = @"BCMDescriptionSettings";
NSString *const kBCMWebsiteSettingsKey = @"BCMWebsiteSettings";
NSString *const kBCMCurrencySettingsKey = @"BCMCurrencySettings";
NSString *const kBCMWalletSettingsKey = @"MerchantAddress";
NSString *const kBCMPinSettingsKey = @"BCMPinSettings";
NSString *const kBCMDirectoryListingSettingsKey = @"BCMDirectoryListingSettings";

NSString *const kBCMPinEntryCompletedSuccessfulNotification = @"successfulPinEntry";
NSString *const kBCMPinEntryCompletedFailNotification = @"failedPinEntry";
NSString *const kBCMPinEntryCAddedPinSuccessfulNotification = @"addedPinSuccessful";
NSString *const kBCMPinEntryCAddedPinFailedNotification = @"addPinFailed";

// Pin Entry
static NSString *const kBCMPinManagerEncryptedPinKey = @"encryptedPinKey";

@interface BCMMerchantManager ()

@end

@implementation BCMMerchantManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (Merchant *)activeMerchant
{
    NSArray *merchants = [Merchant MR_findAll];
    
    return [merchants firstObject];
}

@synthesize directoryListing = _directoryListing;

- (void)setDirectoryListing:(BOOL)directoryListing
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:directoryListing] forKey:kBCMDirectoryListingSettingsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)directoryListing
{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:kBCMCurrencySettingsKey];
    return [number boolValue];
}

- (BOOL)requirePIN
{
    return [SSKeychain accountsForService:kBCMServiceName] > 0;
}

- (NSString *)currencySymbol
{
    NSString *currencyKey = [[NSUserDefaults standardUserDefaults] objectForKey:kBCMCurrencySettingsKey];
    if ([currencyKey length] == 0) {
        currencyKey = @"USD";
    }
    currencyKey = [currencyKey stringByAppendingString:@"_symbol"];
    
    NSString *symbol = [[NSUserDefaults standardUserDefaults] objectForKey:currencyKey];
    
    if ([symbol length] == 0) {
        symbol = @"$";
    }
    
    return symbol;
}

- (UIImage *)merchantQRCodeImage
{
    CGFloat scale = 4 * [[UIScreen mainScreen] scale];
    NSString *mechantName = self.activeMerchant.name;
    NSData *stringData = [mechantName dataUsingEncoding:NSUTF8StringEncoding ];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    // Render the image into a CoreGraphics image
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:[filter outputImage] fromRect:[[filter outputImage] extent]];
    
    //Scale the image usign CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake([[filter outputImage] extent].size.width * scale, [filter outputImage].extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *preImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //Cleaning up .
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    // Rotate the image
    UIImage *qrImage = [UIImage imageWithCGImage:[preImage CGImage]
                                           scale:[preImage scale]
                                     orientation:UIImageOrientationDownMirrored];
    return qrImage;
}

static NSString *const kBCMServiceName = @"BCMMerchant";

- (void)savePIN:(NSString *)pin
{
    NSString *currentPIN = [SSKeychain passwordForService:kBCMServiceName account:self.activeMerchant.name];
    if ([currentPIN length] > 0) {
        [SSKeychain deletePasswordForService:kBCMServiceName account:self.activeMerchant.name];
    }
    
    [SSKeychain setPassword:pin forService:kBCMServiceName account:self.activeMerchant.name];
}

#pragma mark - 

- (void)pinEntryController:(PEPinEntryController *)c shouldAcceptPin:(NSUInteger)pin callback:(void(^)(BOOL))callback
{
    NSString *enteredPassword = [NSString stringWithFormat:@"%lu", (unsigned long)pin];
    NSString *currentPassword = [SSKeychain passwordForService:kBCMServiceName account:self.activeMerchant.name];
    
    BOOL validPassword = [enteredPassword isEqualToString:currentPassword];
    callback(validPassword);
    if (validPassword) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kBCMPinEntryCompletedSuccessfulNotification object:c];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kBCMPinEntryCompletedFailNotification object:c];
    }
}

- (void)pinEntryController:(PEPinEntryController *)c changedPin:(NSUInteger)pin
{
    [self savePIN:[NSString stringWithFormat:@"%lu", (unsigned long)pin]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBCMPinEntryCAddedPinSuccessfulNotification object:c];
}

- (void)pinEntryControllerDidCancel:(PEPinEntryController *)c
{
    
}

@end