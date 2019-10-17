//
//  SnowplowUtils.m
//  Snowplow
//
//  Copyright (c) 2013-2014 Snowplow Analytics Ltd. All rights reserved.
//
//  This program is licensed to you under the Apache License Version 2.0,
//  and you may not use this file except in compliance with the Apache License
//  Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
//  http://www.apache.org/licenses/LICENSE-2.0.
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Apache License Version 2.0 is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the Apache License Version 2.0 for the specific
//  language governing permissions and limitations there under.
//
//  Authors: Jonathan Almeida
//  Copyright: Copyright (c) 2013-2014 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SnowplowUtils.h"

#if TARGET_OS_IPHONE

#import <UIKit/UIScreen.h>
#import <UIKit/UIDevice.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

// to disable IDFA
// define #SNOWPLOW_NO_IDFA

#ifndef SNOWPLOW_NO_IDFA
#import <AdSupport/ASIdentifierManager.h>
#endif

#else

#import <AppKit/AppKit.h>
#import <Carbon/Carbon.h>
#include <sys/sysctl.h>

#endif

@implementation SnowplowUtils

+ (NSString *) getTimezone {
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    return [timeZone name];
}

+ (NSString *) getLanguage {
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

+ (NSString *) getPlatform {
    // There doesn't seem to be any reason to set any other value
    return @"mob";
}

+ (NSString *) getUUID {
    // Generates type 4 UUID
    return [[NSUUID UUID] UUIDString].lowercaseString;
}

+ (NSString *) getAppleIdfa {
    NSString* idfa = nil;
#if TARGET_OS_IPHONE
#ifndef SNOWPLOW_NO_IDFA
    if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
#endif
#endif
    return idfa;
}

+ (NSString *) getAppleIdfv {
    NSString * idfv = nil;
#if TARGET_OS_IPHONE
#ifndef SNOWPLOW_NO_IDFV
    idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
#endif
#endif
    return idfv;
}

+ (NSString *) getCarrierName {
    NSString *name = nil;
#if TARGET_OS_IPHONE
#ifndef TARGET_IPHONE_SIMULATOR
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    name = carrier == nil ? nil : [carrier carrierName ];
#endif
#endif
    return name;
}

+ (double) getTimestamp {
    NSDate *time = [[NSDate alloc] init];
    return [time timeIntervalSince1970]*1000;
}

+ (NSString *) getResolution {
#if TARGET_OS_IPHONE
    CGRect mainScreen = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
#else
    CGRect mainScreen = [[NSScreen mainScreen] frame];
    CGFloat screenScale = [[NSScreen mainScreen] backingScaleFactor];
#endif
    CGFloat screenWidth = mainScreen.size.width * screenScale;
    CGFloat screenHeight = mainScreen.size.height * screenScale;
    NSString *res = [NSString stringWithFormat:@"%.0fx%.0f", screenWidth, screenHeight];
    return res;
}

+ (NSString *) getViewPort {
    // This probably doesn't change as well
    return [self getResolution];
}

+ (NSString *) getDeviceVendor {
    return @"Apple Inc.";
}

+ (NSString *) getDeviceModel {
#if TARGET_OS_IPHONE
    return [[UIDevice currentDevice] model];
#else
    size_t size;
    char *model = nil;
    sysctlbyname("hw.model", NULL, &size, NULL, 0);
    model = malloc(size);
    sysctlbyname("hw.model", model, &size, NULL, 0);
    NSString *hwString = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    return hwString;
#endif
}

+ (NSString *) getOSVersion {
#if TARGET_OS_IPHONE
    return [[UIDevice currentDevice] systemVersion];
#else
    SInt32 osxMajorVersion;
    SInt32 osxMinorVersion;
    SInt32 osxPatchFixVersion;
    NSProcessInfo *info = [NSProcessInfo processInfo];
    if ([info respondsToSelector:@selector(operatingSystemVersion)])
    {
        NSOperatingSystemVersion systemVersion = [info operatingSystemVersion];
        osxMajorVersion = (int)systemVersion.majorVersion;
        osxMinorVersion = (int)systemVersion.minorVersion;
        osxPatchFixVersion = (int)systemVersion.patchVersion;
    }
    else
    {
        // TODO eliminate this block once minimum version is OS X 10+
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        Gestalt(gestaltSystemVersionMajor, &osxMajorVersion);
        Gestalt(gestaltSystemVersionMinor, &osxMinorVersion);
        Gestalt(gestaltSystemVersionBugFix, &osxPatchFixVersion);
#pragma clang diagnostic pop
    }
    NSString *versionString = [NSString stringWithFormat:@"%d.%d.%d", osxMajorVersion,
                               osxMinorVersion, osxPatchFixVersion];
    return versionString;
#endif
}

+ (NSString *) getOSType {
#if TARGET_OS_IPHONE
    return @"ios";
#else
    return @"osx";
#endif
}

+ (NSString *) getAppName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

+ (NSString *) getAppId {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

+ (NSString *) getAppVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)urlEncodeString:(NSString *)s {
    if (!s) {
        return @"";
    }
    return (NSString *)CFBridgingRelease(
      CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) s, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
      CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}

+ (NSString *)urlEncodeDictionary:(NSDictionary *)d {
    NSMutableArray *keyValuePairs = [NSMutableArray arrayWithCapacity:d.count];
    [d enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [keyValuePairs addObject:[NSString stringWithFormat:@"%@=%@", [self urlEncodeString:key], [self urlEncodeString:[value description]]]];
    }];
    return [keyValuePairs componentsJoinedByString:@"&"];
}

@end
