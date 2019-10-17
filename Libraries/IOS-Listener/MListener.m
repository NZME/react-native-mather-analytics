//
//  MListener.m
//  IOS Listener
//
//  Created by Doug Scher on 12/3/14.
//  Copyright (c) 2014-2018 Mather Economics. All rights reserved.
//

#import "MListener.h"
#import "MUserDB.h"
#import "SnowplowTracker.h"
#import "SnowplowEmitter.h"
#import <objc/message.h>

@implementation MListener {
    NSURL *                 _collectorUrl;
    NSString *              _appId;
    NSString *              _customerId;
    NSString *              _market;
    NSString *              _cookieDomain;
    BOOL                    _enableActivityTracking;
    BOOL                    _AppActivePending;
    BOOL                    _AppFirstActive;
    NSNumber *              _activityTrackingMinVisitTime;
    NSNumber *              _activityTrackingMinHeartBeatTime;
    NSTimer  *              _activityTimer;
    NSDictionary *          _options;
    SnowplowEmitter *       _emitter;
    SnowplowTracker *       _tracker;
    NSNumber *              _pageScrollPercent;
    NSDictionary *          _pageViewOptions;
    BOOL                    _pagePingsWhileActive;
    BOOL                    _debug;
}


- (id)  init:(NSString *)collectorUrl_
       appId:(NSString *)appId_
  customerId:(NSString *)customerId_
      market:(NSString *)market_
cookieDomain:(NSString *)cookieDomain_
{
    return [self init:collectorUrl_ appId:appId_ customerId:customerId_ market:market_ cookieDomain:cookieDomain_ enableActivityTracking:NO options:@{}];
}

- (id)             init:(NSString *)collectorUrl_
                  appId:(NSString *)appId_
             customerId:(NSString *)customerId_
                 market:(NSString *)market_
           cookieDomain:(NSString *)cookieDomain_
 enableActivityTracking:(BOOL)enableActivityTracking_
{
    return [self init:collectorUrl_ appId:appId_ customerId:customerId_ market:market_ cookieDomain:cookieDomain_ enableActivityTracking:enableActivityTracking_ options:@{}];
}


- (id)  init:(NSString *)collectorUrl_
       appId:(NSString *)appId_
  customerId:(NSString *)customerId_
      market:(NSString *)market_
cookieDomain:(NSString *)cookieDomain_
     options:(NSDictionary *)options_
{
    return [self init:collectorUrl_ appId:appId_ customerId:customerId_ market:market_ cookieDomain:cookieDomain_ enableActivityTracking:NO options:options_];
}

- (id)             init:(NSString *)collectorUrl_
                  appId:(NSString *)appId_
             customerId:(NSString *)customerId_
                 market:(NSString *)market_
           cookieDomain:(NSString *)cookieDomain_
 enableActivityTracking:(BOOL)enableActivityTracking_
                options:(NSDictionary *)options_
{
    self = [super init];

    if(self) {
        _collectorUrl = [[NSURL alloc] initWithString:collectorUrl_];
        _appId        = appId_;
        _customerId   = customerId_;
        _market       = market_;
        _cookieDomain = cookieDomain_;
        _enableActivityTracking = enableActivityTracking_;
        _AppActivePending = NO;
        _AppFirstActive = YES;
        _options      = options_;
        _pagePingsWhileActive = [_options[@"pagePingsWhileActive"] boolValue];

        _activityTrackingMinVisitTime = options_[@"activityTrackingMinVisitTime"] ?: @30;
        _activityTrackingMinHeartBeatTime = options_[@"activityTrackingMinHeartBeatTime"] ?: @10;

        _emitter = [[SnowplowEmitter alloc] initWithURLRequest:_collectorUrl httpMethod:@"GET" bufferOption:SnowplowBufferInstant];
        _tracker = [[SnowplowTracker alloc] initWithCollector:_emitter
                                                        appId:_appId
                                                base64Encoded:true
                                                    namespace:@"MListener"
                                                 cookieDomain:cookieDomain_
                                                      options:options_];

        [_tracker MAddBaseTrackerParam:@"cid" value:_customerId];
        [_tracker MAddBaseTrackerParam:@"mrk" value:_market];
    }

    return self;
}

- (void) activityTracking:(NSTimer *)timer
{
    if (!_enableActivityTracking)
    {
        return;
    }

    if (timer)
    {
        // timer popped
        
        if (_AppActivePending)
        {
            [_tracker trackPagePing:_pageScrollPercent];
            if ([_pageScrollPercent intValue] > 0 || !_pagePingsWhileActive) _AppActivePending = NO;
        }
    }
    
    if (timer == nil && _activityTimer != nil) {
        [_activityTimer invalidate];
    }
    
    NSTimeInterval interval = [(timer == nil ? _activityTrackingMinVisitTime : _activityTrackingMinHeartBeatTime) doubleValue];
    
    _activityTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(activityTracking:) userInfo:nil repeats:NO];
}


- (void) setAppIdle
{
    _AppActivePending = NO;
}


- (void) setAppActive
{
    if (_AppFirstActive) {
        _AppFirstActive = NO;
    }
    else
    {
        _AppActivePending = YES;
    }
}


- (void) setUrl:(NSString *)url
{
    [_tracker MAddTrackerParam:@"url" value:url];
}

- (void)setTitle:(NSString *)title
{
    [_tracker MAddTrackerParam:@"page" value:title];
}

- (void) setUserId:(NSString *)userId
{
    [_tracker MAddBaseTrackerParam:@"uid" value:userId];
}

- (void) setSection:(NSString *)section
{
    [_tracker MAddTrackerParam:@"sec" value:section];
}

/**
 * Specify the article author
 *
 * @param author string
 */
- (void)setAuthor:(NSString *)author {
    [_tracker MAddTrackerParam:@"auth" value:author];
}

/**
 * Specify the page type
 *
 * @param pageType string
 */
- (void) setPageType: (NSString *)pageType {
    [_tracker MAddTrackerParam:@"ptype" value:pageType];
}

/**
 * Specify if page contains premium content
 *
 * @param premium BOOL
 */
- (void) setPremium:(BOOL)premium {
    [_tracker MAddTrackerParam:@"prem" value:premium ? @"1" : @"0"];
}

/**
 * Specify the article publish time
 *
 * @param articlePublishTime Date object, constructor string value
 */
- (void) setArticlePublishTime:(NSDate *)articlePublishTime {
    long long unixTime = [articlePublishTime timeIntervalSince1970];
    [_tracker MAddTrackerParam:@"artpubt" value:[NSString stringWithFormat:@"%lld", unixTime]];
}


/**
 * Specify if page is eligible for paywall metering
 *
 * @param metered BOOL
 */
- (void) setMetered:(NSString *)metered {
    [_tracker MAddBaseTrackerParam:@"metered" value:metered];
}


/**
 * Specify the publication name
 *
 * @param pubName string
 */
- (void) setPublication:(NSString *)pubName {
    [_tracker MAddTrackerParam:@"pubname" value:pubName];
}

/**
 * Specify an array of categories or category paths (sports|local)
 *
 * @param categories Array
 */
- (void) setCategories:(NSArray *)categories {
    [_tracker MAddCtxSection:@"categories" value:@[categories]];
}

/**
 * Specify the application name
 *
 * @param appName string
 */
- (void) setAppName:(NSString *)appName {
    [_tracker MAddTrackerParam:@"appname" value:appName];
}

/**
 * Specify the UI operation that invoked current page view (Swipe, Navigation, Alert, etc.)
 * @param referenceNav string
 */
- (void) setReferenceNav:(NSString *)referenceNav {
    [_tracker MAddTrackerParam:@"refnav" value:referenceNav];
}

/**
 * Specify the article id
 *
 * @param articleId string
 */
- (void) setArticleId:(NSString *)articleId {
    [_tracker MAddTrackerParam:@"artid" value:articleId];
}

/**
 * Specify the article publish time
 *
 * @param articleUpdateTime Date object, constructor string value
 */
- (void) setArticleUpdateTime:(NSDate *)articleUpdateTime {
    long long unixTime = [articleUpdateTime timeIntervalSince1970];
    [_tracker MAddTrackerParam:@"artupt" value:[NSString stringWithFormat:@"%lld", unixTime]];
}


/**
 * Specify an array of hierarchical sections ([sports,local,badgers])
 *
 * @param hierarchy string
 */
- (void) setHierarchy:(NSArray *)hierarchy {
    [_tracker MAddTrackerParam:@"hier" value:[hierarchy componentsJoinedByString:@"|"]];
}

/**
 * Specify user's email, value will be base64 encoded
 *
 * @param email string
 */
- (void) setEmail:(NSString *)email {
    [_tracker MAddCtxSection:@"userData" value:@{@"email" : email}];
}

/**
 * Specify the source of article (pub name, AP, etc)
 *
 * @param articleSource string
 */
- (void) setArticleSource:(NSString *)articleSource {
    [_tracker MAddTrackerParam:@"artsrc" value:articleSource];
}

/**
 * Specify the media technology used for the current article (video, photogallery, etc)
 *
 * @param mediaType string
 */
- (void) setMediaType:(NSString *)mediaType {
    [_tracker MAddTrackerParam:@"mediat" value:mediaType];
}

/**
 * Specify the article type (News flas, editorial, blog, etc)
 *
 * @param articleType string
 */
- (void) setArticleType:(NSString *)articleType {
    [_tracker MAddTrackerParam:@"arttype" value:articleType];
}

/**
 * Specify total words in article
 *
 * @param wordCount integer
 */
- (void) setWordCount:(NSInteger)wordCount {
    [_tracker MAddTrackerParam:@"wrdcnt" value:[@(wordCount) stringValue]];
}

/**
 * Specify total paragraphs in article
 *
 * @param paragraphCount integer
 */
- (void) setParagraphCount:(NSInteger)paragraphCount {
    [_tracker MAddTrackerParam:@"paracnt" value:[@(paragraphCount) stringValue]];
}

/**
 * Specify a url that led to this page
 *
 * @param referrer string
 */
- (void) setReferrer:(NSString *)referrer {
    [_tracker MAddTrackerParam:@"refr" value:referrer];
}

/**
 * Percentage of article has been scrolled
 *
 * @param scrollPercent number
 */
- (void) setScrollPercent:(NSNumber *)scrollPercent {
    _pageScrollPercent = scrollPercent;
    if ([_pageScrollPercent intValue] > 100) _pageScrollPercent = @100;
    _AppActivePending = YES;
}

/**
 * Page number of the current article
 *
 * @param pageNumber string
 */
- (void) setPageNumber:(NSString *)pageNumber {
    [_tracker MAddTrackerParam:@"pnum" value:pageNumber];
}

/**
 * Specify total characters in article
 *
 * @param characterCount number
 */
- (void) setCharacterCount:(NSInteger)characterCount {
    [_tracker MAddTrackerParam:@"chrcnt" value:[@(characterCount) stringValue]];
}


- (NSString *) getDuid {
    return [_tracker getDuid];
}

- (void) setDuid:duid {
    [_tracker setDuid:duid];
}


/**
 * Enable console logging
 *
 * @param enable bool default=NO - YES to enable all logging
 */

- (void) setDebug:(BOOL)enable {
    _debug = enable;
}


- (void) setContext:(NSDictionary *)contextDict
{
    [_tracker MAddCtxSection:contextDict];
}

- (NSDictionary *) setContextJson:(NSString *)contextJson
{
    NSDictionary *contextDict;
    
    NSError *error;
    NSData *objectData = [contextJson dataUsingEncoding:NSUTF8StringEncoding];
    contextDict = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&error];
    
    if (error != nil)
    {
        LogError(@"setContext: Invalid json data(%@)", error);
    }
    else
    {
        [_tracker MAddCtxSection:contextDict];
    }
    
    return contextDict;
}

- (BOOL) processOptions:(NSDictionary *)options
{
    if (!options)
    {
        return YES;
    }
    
    NSDictionary *funcs = @{
                            @"setDebug" : [NSNumber class],
                            @"setUrl" : [NSString class],
                            @"setTitle" : [NSString class],
                            @"setUserId" : [NSString class],
                            @"setSection" : [NSString class],
                            @"setAuthor" : [NSString class],
                            @"setPageType" : [NSString class],
                            @"setPremium" : [NSNumber class],
                            @"setArticlePublishTime" : [NSDate class],
                            @"setContext" : [NSDictionary class],
                            @"setContextJson" : [NSString class],
                            @"setMetered": [NSString class],
                            @"setPublication" : [NSString class],
                            @"setCategories" : [NSArray class],
                            @"setAppName" : [NSString class],
                            @"setReferenceNav" : [NSString class],
                            @"setArticleId" : [NSString class],
                            @"setArticleUpdateTime" : [NSDate class],
                            @"setHierarchy" : [NSArray class],
                            @"setEmail" : [NSString class],
                            @"setArticleSource" : [NSString class],
                            @"setMediaType" : [NSString class],
                            @"setArticleType" : [NSString class],
                            @"setWordCount" : [NSNumber class],
                            @"setParagraphCount" : [NSNumber class],
                            @"setReferrer" : [NSString class],
                            @"setScrollPercent" : [NSNumber class],
                            @"setPageNumber" : [NSString class],
                            @"setCharacterCount" : [NSNumber class],
                            };
    
    for (id func in options)
    {
        id value = options[func];

        if (!funcs[func])
        {
            LogError(@"(%@) is not a valid function", func);
            return NO;
        }
        
        if (![value isKindOfClass:[funcs[func] class]])
        {
            LogError(@"(%@) value(%@) is not of type(%@)", func, [value class], [funcs[func] class]);
            return NO;
        }
        
        NSNumber *number = value;
        
        if ([func isEqualToString: @"setDebug"])
        {
            [self setDebug:[number boolValue]];
        }
        else if ([func isEqualToString: @"setUrl"])
        {
            [self setUrl:value];
        }
        else if ([func isEqualToString: @"setTitle"])
        {
            [self setTitle:value];
        }
        else if ([func isEqualToString: @"setUserId"])
        {
            [self setUserId:value];
        }
        else if ([func isEqualToString: @"setSection"])
        {
            [self setSection:value];
        }
        else if ([func isEqualToString: @"setAuthor"])
        {
            [self setAuthor:value];
        }
        else if ([func isEqualToString: @"setPageType"])
        {
            [self setPageType:value];
        }
        else if ([func isEqualToString: @"setPremium"])
        {
            [self setPremium:[number boolValue]];
        }
        else if ([func isEqualToString: @"setArticlePublishTime"])
        {
            [self setArticlePublishTime:value];
        }
        else if ([func isEqualToString: @"setContext"])
        {
            [self setContext:value];
        }
        else if ([func isEqualToString: @"setContextJson"])
        {
            if ([self setContextJson:value] == nil)
            {
                return NO;
            }
        }
        else if ([func isEqualToString: @"setMetered"])
        {
            [self setMetered:value];
        }
        else if ([func isEqualToString: @"setPublication"])
        {
            [self setPublication:value];
        }
        else if ([func isEqualToString: @"setCategories"])
        {
            [self setCategories:value];
        }
        else if ([func isEqualToString: @"setAppName"])
        {
            [self setAppName:value];
        }
        else if ([func isEqualToString: @"setReferenceNav"])
        {
            [self setReferenceNav:value];
        }
        else if ([func isEqualToString: @"setArticleId"])
        {
            [self setArticleId:value];
        }
        else if ([func isEqualToString: @"setArticleUpdateTime"])
        {
            [self setArticleUpdateTime:value];
        }
        else if ([func isEqualToString: @"setHierarchy"])
        {
            [self setHierarchy:value];
        }
        else if ([func isEqualToString: @"setEmail"])
        {
            [self setEmail:value];
        }
        else if ([func isEqualToString: @"setArticleSource"])
        {
            [self setArticleSource:value];
        }
        else if ([func isEqualToString: @"setMediaType"])
        {
            [self setMediaType:value];
        }
        else if ([func isEqualToString: @"setArticleType"])
        {
            [self setArticleType:value];
        }
        else if ([func isEqualToString: @"setWordCount"])
        {
            [self setWordCount:[number intValue]];
        }
        else if ([func isEqualToString: @"setParagraphCount"])
        {
            [self setParagraphCount:[number intValue]];
        }
        else if ([func isEqualToString: @"setReferrer"])
        {
            [self setReferrer:value];
        }
        else if ([func isEqualToString: @"setScrollPercent"])
        {
            [self setScrollPercent:value];
        }
        else if ([func isEqualToString: @"setPageNumber"])
        {
            [self setPageNumber:value];
        }
        else if ([func isEqualToString: @"setCharacterCount"])
        {
            [self setCharacterCount:[number intValue]];
        }
    }
    
    return YES;
}

- (BOOL) trackPageView:(NSString *)pageUrl
               options:(NSDictionary *)options_
               context:(NSDictionary *)context_

{
    if (![self processOptions:options_])
    {
        return NO;
    }

    [_tracker MAddTrackerParam:@"url" value:pageUrl];

    [_tracker trackPageView:pageUrl context:context_];

    _pageScrollPercent = @0;

    if (!_pagePingsWhileActive) _AppActivePending = NO;

    [self activityTracking:nil];

    return YES;
}

- (BOOL) trackPageView:(NSString *)pageUrl
{
    return [self trackPageView:pageUrl options:nil context:nil];
}

- (BOOL) trackPageView:(NSString *)pageUrl
               options:(NSDictionary *)options_
{
    return [self trackPageView:pageUrl options:options_ context:nil];
}

- (BOOL) trackAdImpression:(NSDictionary *)adDict
{
    return [self trackAdImpression:adDict options:nil];
}

- (BOOL) trackAdImpression:(NSDictionary *)adDict
                   options:(NSDictionary *)options
{
    if (![self processOptions:options])
    {
        return NO;
    }

    // 'Ad Impression', {eaid: '%eaid!', ebuy: '%ebuy!', eadv: '%eadv!', ecid: '%ecid!', eenv: '%eenv!', epid: '%epid!', esid: '%esid!'}]);

    NSMutableDictionary * eventDict = [NSMutableDictionary dictionaryWithDictionary:adDict];

    eventDict[@"eenv"] = @"IOS";

    NSArray * attrs = @[@"eaid", @"ebuy", @"eadv", @"ecid", @"epid", @"esid"];

    for (NSString * attr in attrs) {
        if (eventDict[attr] == nil) {
            eventDict[attr] = @"";
        }
    }

    [_tracker trackUnstructuredEvent:@"Ad Impression" eventDict:eventDict];
    return YES;
}

- (BOOL) trackEvent:(NSDictionary *)eventDict
{
    return [self trackEvent:eventDict options:nil];
}

- (BOOL) trackEvent:(NSDictionary *)eventDict
            options:(NSDictionary *)options
{
    if (![self processOptions:options])
    {
        return NO;
    }

    [_tracker trackEvent: @{@"action" : eventDict}];
    return YES;
}

- (BOOL) trackVideoEvent:(NSString *)operation
              videotDict:(NSDictionary *)videotDict
{
    return [self trackVideoEvent:operation videotDict:videotDict options:nil];
}

- (BOOL) trackVideoEvent:(NSString *)operation
              videotDict:(NSDictionary *)videotDict
                 options:options
{
    return [self trackEvent:@{@"category": @"video", @"action": operation,@"data": videotDict} options:options];
}

- (BOOL) trackUnstructuredEvent:(NSString *)name
                      eventDict:(NSDictionary *)eventDict
{
    return [self trackUnstructuredEvent:name eventDict:eventDict options:nil];
}

- (BOOL) trackUnstructuredEvent:(NSString *)name
                      eventDict:(NSDictionary *)eventDict
                        options:(NSDictionary *)options
{
    if (![self processOptions:options])
    {
        return NO;
    }

    [_tracker trackUnstructuredEvent:name eventDict:eventDict];
    return YES;
}

- (void)getUserDBData:(NSDictionary *)options callback:(void(^)(NSArray *segments, NSString *error))callback {
    MUserDB *userDB = [[MUserDB alloc] init:_tracker options:options];

    [userDB sendRequest:^(NSDictionary *response) {
        if(callback) callback(response[@"segments"], response[@"err"]);
    }];
}

/*
 - (BOOL) getUserDBData:(NSDictionary *)options
 {
 MUserDB *userDB = [[MUserDB alloc] init:_tracker options:options];

 [userDB sendRequest];

 return YES;
 }

- (BOOL) getUserDBData
{
    return [self getUserDBData:nil];
}
*/

- (NSArray *) getUserDBSegments
{
    NSMutableDictionary *userDB = [[_tracker defaultsDict] objectForKey:@"userDB"];

    NSArray *noSegments = [NSArray array];

    if (userDB == nil) {
        return noSegments;

    } else {
        if ([userDB[@"segments"] isKindOfClass:[NSArray class]]) {
            return [userDB[@"segments"] copy];

        } else {
            return noSegments;
        }
    }
}


@end
