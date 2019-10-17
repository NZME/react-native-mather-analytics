//
//  SnowplowTracker.m
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

#import "SnowplowTracker.h"
#import "SnowplowPayload.h"
#import "SnowplowUtils.h"

@implementation SnowplowTracker {
    NSDictionary *          _options;
    Boolean                 _base64Encoded;
    NSMutableDictionary *   _baseMetrics;
    NSMutableDictionary *   _extendedMetrics;
    NSMutableDictionary *   _ctx;
    NSString *              _pid;
    NSUserDefaults *        _defaultsStore;
    NSString *              _defaultsStoreKey;
    int64_t                 _lastVisitInterval;
    NSMutableDictionary *   _lastPV;
    NSString *              _setDuid;
}

NSString * const kSnowplowVendor        = @"com.snowplowanalytics.snowplow";
NSString * const kIglu                  = @"iglu:";
Boolean    const kDefaultEncodeBase64   = true;

#if TARGET_OS_IPHONE
NSString * const kVersion               = @"ios-1.0.5";
#else
NSString * const kVersion               = @"osx-1.0.5";
#endif

@synthesize collector;
@synthesize appId;
@synthesize trackerNamespace;
@synthesize cookieDomain;
@synthesize defaultsDict;

- (id) init {
    return [self initWithCollector:nil appId:nil base64Encoded:true namespace:nil cookieDomain:nil options:nil];
}

- (id) initWithCollector:(SnowplowEmitter *)collector_
                   appId:(NSString *)appId_
           base64Encoded:(Boolean)encoded
               namespace:(NSString *)namespace_
            cookieDomain:(NSString *)cookieDomain_
                 options:(NSDictionary *)options_ {
    self = [super init];
    if(self) {
        trackerNamespace = namespace_;
        _base64Encoded = encoded;
        collector = collector_;
        cookieDomain = cookieDomain_;
        _options = options_ ? options_ : @{};

        if ([[SnowplowUtils getOSVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending) // IOS 8 only
        {
            _defaultsStore = [[NSUserDefaults alloc] initWithSuiteName:@"group.mather"];
        }
        else
        {
            _defaultsStore = [NSUserDefaults standardUserDefaults];
        }
        
        _defaultsStoreKey = [NSString stringWithFormat:@"%@(%@)", @"_MatherDict", cookieDomain];
        if (!(defaultsDict = [[_defaultsStore dictionaryForKey:_defaultsStoreKey] mutableCopy]))
        {
            defaultsDict = [@{
                              @"visits": [NSNumber numberWithInt:0],
                              @"lastVisitTime": [NSNumber numberWithDouble:0],
                             } mutableCopy];
        }

        [defaultsDict removeObjectForKey:@"duid"]; // clean up from previous versions
        [self saveDefaults];

        _baseMetrics = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         kVersion, @"tv",
                         namespace_, @"tna",
                         appId_, @"aid",
                         nil];

        _extendedMetrics = [NSMutableDictionary dictionary];
        _lastPV = [NSMutableDictionary dictionary];
        _ctx = [NSMutableDictionary dictionary];
        
        id lastVisitIntervalMins = _options[@"lastVisitIntervalMins"];
        
        if (lastVisitIntervalMins == nil) {
            _lastVisitInterval = 30 * 60; // 30 minutes

        } else {
            _lastVisitInterval = [lastVisitIntervalMins integerValue] * 60;
        }
    }
    return self;
}

- (void) setMobileContext: (SnowplowPayload *)pb {
    NSMutableDictionary *mx = [NSMutableDictionary dictionary];
    
    mx[@"osType"] = [SnowplowUtils getOSType];
    mx[@"osVersion"] = [SnowplowUtils getOSVersion];
    mx[@"appName"] = [SnowplowUtils getAppName];
    mx[@"appId"] = [SnowplowUtils getAppId];
    mx[@"appVersion"] = [SnowplowUtils getAppVersion];
    mx[@"deviceManufacturer"] = [SnowplowUtils getDeviceVendor];
    mx[@"deviceModel"] = [SnowplowUtils getDeviceModel];

    if (![_options[@"disableAppleIdfv"] boolValue]) mx[@"appleIdfv"]  = [SnowplowUtils getAppleIdfv];
    if (![_options[@"disableCarrier"] boolValue]) mx[@"carrier"]  = [SnowplowUtils getCarrierName];
    if ([_options[@"enableAppleIdfa"] boolValue]) mx[@"appleIdfa"]  = [SnowplowUtils getAppleIdfa];

    [pb addDictionaryToPayload:mx
                 base64Encoded:_base64Encoded
               typeWhenEncoded:@"mx"
            typeWhenNotEncoded:@"mo"];
}

- (void) saveDefaults {
    [_defaultsStore setObject:defaultsDict forKey:_defaultsStoreKey];
    [_defaultsStore synchronize];
}

- (NSHTTPCookie *) getCookie: (NSString *)name {
    NSHTTPCookie *cookie;

    for (cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        // DLog(@"%@ = %@ d=%@ p=%@ v=%lu cd=%@", [cookie name], [cookie value], [cookie domain], [cookie path], [cookie version], cookieDomain);
        if ([[cookie name] isEqual:name] && [[cookie domain] isEqual:cookieDomain])
        {
            return (cookie);
        }
    }

    return nil;
/*
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:name forKey:NSHTTPCookieName];
    [cookieProperties setObject:defaultsDict[@"duid"] forKey:NSHTTPCookieValue];
    [cookieProperties setObject:cookieDomain forKey:NSHTTPCookieDomain];
//    [cookieProperties setObject:@"www.example.com" forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:63072000] forKey:NSHTTPCookieExpires]; // 2 years
    
    cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    return cookie;
 */
}

- (void) updateUrl:(SnowplowPayload *)pb key:(NSString *)key eventName:(NSString *)eventName {
    NSString *url = [pb getPayloadAsDictionary][key];

    if (url == nil) {
        url = eventName;
    }

    url = [url lowercaseString];

    if (![url hasPrefix:@"http"]) {
        if ( ![[url substringToIndex:1] isEqual: @"/"] )
        {
            url = [NSString stringWithFormat:@"/%@", url];
        }

        url = [url stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        url = [NSString stringWithFormat:@"http://%@%@", [self MGetBaseTrackerParam:@"cid"], url];
    }

    [pb addValueToPayload:url forKey:key];
}

- (void) addStandardValuesToPayload:(SnowplowPayload *)pb eventName:(NSString *)eventName {
    [pb addDictionaryToPayload:_baseMetrics];
    [pb addDictionaryToPayload:_extendedMetrics];
    [pb addValueToPayload:[SnowplowUtils getPlatform] forKey:@"p"];
    [pb addValueToPayload:[SnowplowUtils getResolution] forKey:@"res"];
    [pb addValueToPayload:[SnowplowUtils getViewPort] forKey:@"vp"];
    [pb addValueToPayload:[SnowplowUtils getUUID] forKey:@"tid"];
    if (_pid == nil) {
        _pid = [SnowplowUtils getUUID];
    }
    [pb addValueToPayload:_pid forKey:@"pid"];
    [pb addValueToPayload:[SnowplowUtils getLanguage] forKey:@"lang"];
    [pb addValueToPayload:[NSString stringWithFormat:@"%.0f", [SnowplowUtils getTimestamp]] forKey:@"dtm"];
    [pb addValueToPayload:[self getDuid] forKey:@"duid"];

    int64_t visits = [defaultsDict[@"visits"] integerValue];
    int64_t currentTime = [[NSDate date] timeIntervalSince1970];
    int64_t lastVisitTime = [defaultsDict[@"lastVisitTime"] integerValue];

    if (currentTime > lastVisitTime + _lastVisitInterval) {
        [defaultsDict setObject:@(visits += 1) forKey:@"visits"];
    }

    [defaultsDict setObject:@(currentTime) forKey:@"lastVisitTime"];
    [self saveDefaults];

    [pb addValueToPayload:[NSString stringWithFormat:@"%.0lld", visits] forKey:@"vid"];

    [self setMobileContext:pb];

    if ([_ctx count] != 0) {
        [pb addDictionaryToPayload:_ctx
                     base64Encoded:_base64Encoded
                   typeWhenEncoded:@"cx"
                typeWhenNotEncoded:@"co"];
    }

    NSDictionary *payload = [pb getPayloadAsDictionary];
    NSArray *keys = @[@"page", @"url", @"refr"];
    
    if ([eventName isEqualToString:@"page_view"]) {
        if (payload[@"refr"] == nil && _lastPV[@"url"] != nil) {
            [pb addValueToPayload:_lastPV[@"url"] forKey:@"refr"];
        }
        for (NSString *key in keys) {
            if (payload[key] != nil) {
                [_lastPV setObject:payload[key] forKey:key];
            }
        }
        
    } else {
        // reuse values from last page view
        
        for (NSString *key in keys) {
            if (payload[key] == nil && _lastPV[key] != nil) {
                [pb addValueToPayload:_lastPV[key] forKey:key];
            }
        }
    }

    [self updateUrl:pb key:@"url" eventName:eventName];
    [self updateUrl:pb key:@"refr" eventName:eventName];
}

- (void) addTracker:(SnowplowPayload *)pb event:(NSString *)event eventName:(NSString *)eventName {
    [pb addValueToPayload:event forKey:@"e"];
    [self addStandardValuesToPayload:pb eventName:eventName];
    [collector addPayloadToBuffer:pb];
    [_extendedMetrics removeAllObjects];
    [_ctx removeAllObjects];
}

- (void) trackPageView:(NSString *)pageUrl
               context:(NSDictionary *)context
{
    // handle case where initial events are not page views so these events are associated with this page view
    if (_pid == nil || _lastPV != nil) {
        _pid = [SnowplowUtils getUUID];
    }

    SnowplowPayload *pb = [[SnowplowPayload alloc] init];

    [self addTracker:pb event:@"pv" eventName:@"page_view"];
}

- (void) trackUnstructuredEvent:(NSString *)name
                      eventDict:(NSDictionary *)eventDict
{
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];

    [pb addValueToPayload:name forKey:@"ue_na"];

    [pb addDictionaryToPayload:eventDict
                 base64Encoded:_base64Encoded
               typeWhenEncoded:@"ue_px"
            typeWhenNotEncoded:@"ue_pr"];

    [self addTracker:pb event:@"ue" eventName:@"ad_impression"];
}


// Mather extensions follow

- (void) trackPagePing:(NSNumber *)scrollPercent
{
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];

    [pb addValueToPayload:[scrollPercent stringValue] forKey:@"scrollp"];
    [self addTracker:pb event:@"pp" eventName:@"page_ping"];
}

- (void) trackEvent:(NSDictionary *)eventDict
{
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];

    [self MAddCtxSection:eventDict];
    [self addTracker:pb event:@"ev" eventName:@"event"];
}

- (void) trackUserDB:(NSDictionary *)userDBDict
{
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];
    NSString *err = userDBDict[@"err"];

    if (err != nil) {
        [pb addValueToPayload:err forKey:@"error"];
    }

    [self MAddCtxSection:@"userDB" value:userDBDict];
    [self addTracker:pb event:@"ud" eventName:@"userdb"];
}

- (NSString *) getDuid
{
    NSString *duid = _setDuid;

    if (![duid length] && (duid = [[self getCookie:@"sp"] value]) == nil) {
        duid = [SnowplowUtils getAppleIdfv];
    }

    return duid;
}

- (void) setDuid:(NSString *)duid;
{
    _setDuid = duid;
}

- (void) MAddTrackerParam:(NSString *)key value:(NSString *)value
{
    if (value.length) {
        [_extendedMetrics setObject:value forKey:key];
    }
}

- (NSString *) MGetTrackerParam:(NSString *)key
{
    return [_extendedMetrics objectForKey:key];
}

- (void) MAddBaseTrackerParam:(NSString *)key value:(NSString *)value
{
    if (value.length) {
        [_baseMetrics setObject:value forKey:key];
    }
}

- (NSString *) MGetBaseTrackerParam:(NSString *)key
{
    return [_baseMetrics objectForKey:key];
}

- (void) MAddCtxSection:(NSString *)section value:(id)value
{
    if (value == nil) {
        return;
    }

    id sec = _ctx[section];
    
    if (sec != nil) {
        if ([sec isKindOfClass:[NSMutableDictionary class]]) {
            [sec addEntriesFromDictionary:[value mutableCopy]];
            
        } else if ([sec isKindOfClass:[NSMutableArray class]]) {
            for (id e in value) {
                [sec addObject:[e mutableCopy]];
            }
            
        } else {
            _ctx[section] = value;
        }
        
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        _ctx[section] = [value mutableCopy];
        
    } else if ([value isKindOfClass:[NSArray class]]) {
        _ctx[section] = [value mutableCopy];
        
    } else {
        _ctx[section] = value;
    }
}
- (void) MAddCtxSection:(id)value {
    if (value == nil) {
        return;
    }

    for (id key in value) {
        [self MAddCtxSection:key value:value[key]];
    }
}
@end
