//
//  MListener.h
//  IOS Listener
//
//  Created by Doug Scher on 12/3/14.
//  Copyright (c) 2014-2018 Mather Economics. All rights reserved.
//

#ifndef IOS_Listener_MListener_h
#define IOS_Listener_MListener_h

#import <Foundation/Foundation.h>

@interface MListener : NSObject

/**
 *  Initializes a newly allocated MListener
 *  @return An MListener object.
 */

- (id)  init:(NSString *)collectorUrl_
       appId:(NSString *)appId_
  customerId:(NSString *)customerId_
      market:(NSString *)market_
cookieDomain:(NSString *)cookieDomain_;


- (id)             init:(NSString *)collectorUrl_
                  appId:(NSString *)appId_
             customerId:(NSString *)customerId_
                 market:(NSString *)market_
           cookieDomain:(NSString *)cookieDomain_
 enableActivityTracking:(BOOL)enableActivityTracking_;


- (id)  init:(NSString *)collectorUrl_
       appId:(NSString *)appId_
  customerId:(NSString *)customerId_
     market:(NSString *)market_
 cookieDomain:(NSString *)cookieDomain_
      options:(NSDictionary *)options_;

- (id)             init:(NSString *)collectorUrl_
                  appId:(NSString *)appId_
             customerId:(NSString *)customerId_
                 market:(NSString *)market_
           cookieDomain:(NSString *)cookieDomain_
 enableActivityTracking:(BOOL)enableActivityTracking_
                options:(NSDictionary *)options_;


- (void) setAppIdle;
- (void) setAppActive;

- (void) setUrl:(NSString *)pageUrl;
- (void) setTitle:(NSString *)title;
- (void) setUserId:(NSString *)userId;
- (void) setSection:(NSString *)section;
- (void) setAuthor:(NSString *)author;
- (void) setPageType: (NSString *)pageType;
- (void) setPremium:(BOOL)premium;
- (void) setArticlePublishTime:(NSDate *)articlePublishTime;
- (void) setDebug:(BOOL)enable;
- (void) setContext:(NSDictionary *)contextDict;
- (NSDictionary *) setContextJson:(NSString *)contextJson;
- (void) setMetered:(NSString *)metered;
- (void) setPublication:(NSString *)pubName;
- (void) setCategories:(NSArray *)categories;
- (void) setAppName:(NSString *)appName;
- (void) setReferenceNav:(NSString *)referenceNav;
- (void) setArticleId:(NSString *)articleId;
- (void) setArticleUpdateTime:(NSDate *)articleUpdateTime;
- (void) setHierarchy:(NSArray *)hierarchy;
- (void) setEmail:(NSString *)email;
- (void) setArticleSource:(NSString *)articleSource;
- (void) setMediaType:(NSString *)mediaType;
- (void) setArticleType:(NSString *)articleType;
- (void) setWordCount:(NSInteger)wordCount;
- (void) setParagraphCount:(NSInteger)paragraphCount;
- (void) setReferrer:(NSString *)referrer;
- (void) setScrollPercent:(NSNumber *)scrollPercent;
- (void) setPageNumber:(NSString *)pageNumber;
- (void) setCharacterCount:(NSInteger)characterCount;


- (NSString *) getDuid;
- (void) setDuid:(NSString *)duid;

- (BOOL) trackPageView:(NSString *)pageUrl;

- (BOOL) trackPageView:(NSString *)pageUrl
               options:(NSDictionary *)options;

- (BOOL) trackPageView:(NSString *)pageUrl
               options:(NSDictionary *)options
               context:(NSDictionary *)context;

- (BOOL) trackAdImpression:(NSDictionary *)adDict;

- (BOOL) trackAdImpression:(NSDictionary *)adDict
                   options:(NSDictionary *)options;

- (BOOL) trackEvent:(NSDictionary *)eventDict;

- (BOOL) trackEvent:(NSDictionary *)eventDict
            options:(NSDictionary *)options;

- (BOOL) trackVideoEvent:(NSString *)operation
              videotDict:(NSDictionary *)videotDict;

- (BOOL) trackVideoEvent:(NSString *)operation
              videotDict:(NSDictionary *)videotDict
                 options:options;

- (BOOL) trackUnstructuredEvent:(NSString *)name
                      eventDict:(NSDictionary *)eventDict;

- (BOOL) trackUnstructuredEvent:(NSString *)name
                      eventDict:(NSDictionary *)eventDict
                        options:(NSDictionary *)options;

- (void)getUserDBData:(NSDictionary *)options callback:(void(^)(NSArray *segments, NSString *error))callback;

//- (BOOL) getUserDBData:(NSDictionary *)options;
//- (BOOL) getUserDBData;
- (NSArray *) getUserDBSegments;

@end

#endif
