//
//  SnowplowTracker.h
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

#import <Foundation/Foundation.h>
#import "SnowplowEmitter.h"
#import "SnowplowPayload.h"

@interface SnowplowTracker : NSObject

@property (retain)              SnowplowEmitter *   collector;
@property (retain)              NSString *          appId;
@property (retain)              NSString *          trackerNamespace;
@property (retain, nonatomic)   NSString *          userId;
@property (retain)              NSString *          cookieDomain;
@property (retain)              NSMutableDictionary *defaultsDict;

//NSMutableDictionary *   _defaultsDict;


extern NSString * const kSnowplowVendor;
extern NSString * const kIglu;
extern Boolean    const kDefaultEncodeBase64;
extern NSString * const kVersion;

/**
 *  Initializes a newly allocated SnowplowTracker. All class properties default to nil, and require you to use setCollector, setNamespace, setAppId. Using initUsingCollector:appId:base64Encoded:namespace is recommended.
 *  @return A SnowplowTracker instance.
 */
- (id) init;

/**
 *  Initializes a newly allocated SnowplowTracker with all the required properties to send events to it.
 *  @param collector_ A SnowplowEmitter object that is initialized to send the events created by the SnowplowTracker.
 *  @param appId_ Your app ID
 *  @param namespace_ Identifier for the tracker instance.
 *  @return A SnowplowTracker instance.
 */
- (id) initWithCollector:(SnowplowEmitter *)collector_
                   appId:(NSString *)appId_
           base64Encoded:(Boolean)encoded
               namespace:(NSString *)namespace_
            cookieDomain:(NSString *)cookieDomain_
                 options:(NSDictionary *)options_;

/**
 *  Lets you track a page view using all the variables entered here.
 *  @param pageUrl The URL of the page
 *  @param context An array of custom context for the event
 */
- (void) trackPageView:(NSString *)pageUrl
               context:(NSDictionary *)context;

/**
 *  Used to send a page ping which is used to indicate page activity.
 *  @param scrollPercent Position of current scroll 0 to 100
 */
- (void) trackPagePing:(NSNumber *)scrollPercent;

/**
 *  An unstructured event allows you to create an event custom structured to your requirements
 *  @param eventDict A dictionary of event data.
 */
- (void) trackUnstructuredEvent:(NSString *)name
                      eventDict:(NSDictionary *)eventDict;

// Mather extension - add/get params to all requests

// send a genereric event such as a video event
- (void) trackEvent:(NSDictionary *)eventDict;

- (void) trackUserDB:(NSDictionary *)userDBDict;

- (NSString *) getDuid;
- (void) setDuid:(NSString *)duid;

// Mather extension - add/get params to all requests

- (void) MAddTrackerParam:(NSString *)key value:(NSString *)value;
- (NSString *) MGetTrackerParam:(NSString *)key;

- (void) MAddBaseTrackerParam:(NSString *)key value:(NSString *)value;
- (NSString *) MGetBaseTrackerParam:(NSString *)key;

- (void) MAddCtxSection:(NSString *)section value:(id)value;
- (void) MAddCtxSection:(id)value;

- (void) saveDefaults;

@end
