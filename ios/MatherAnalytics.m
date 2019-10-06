#import "MatherAnalytics.h"
#import <React/RCTConvert.h>

@implementation MatherAnalytics

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(trackPageView:(nonnull NSString *)accountName
                  accountNumber:(nonnull NSString *)accountNumber
                  payload:(nonnull NSDictionary *)payload)
{
//    MListener *mListener;
//    mListener = [[MListener alloc] init:@"http:www.i.matheranalytics.com"
//        appId:@"v1"
//        customerId:accountName
//        market:accountNumber
//        cookieDomain:@"newsreader.com"
//        enableActivityTracking:YES];

    /**
     @"setTitle" : @"Welcome to the News Reader",
     @"setUserId" : @"user1@newsreader.com",
     @"setSection" : @"sports",
     @"setAuthor" : @"Kurt Vonnegut",
     @"setPageType" : @"home page",
     @"setPremium" : @YES,
     @"setArticlePublishTime" : [formatter dateFromString:@"20170905102322+0400"],
     @"setContext" : @{@"identities" : @[@{ @"type" : @"paywallUserId", @"id" : @"paywallUserId" }]},
     @"setMetered": @"1|5",
     @"setPublication" : @"The Reader News",
     @"setCategories" : @[@"cat", @"dog", @"chipmonk"],
     @"setAppName" : @"Best News Reader",
     @"setReferenceNav" : @"SectionScroll",
     @"setArticleId" : @"3245671.b",
     @"setArticleUpdateTime" : [formatter dateFromString:@"20170905160033+0400"],
     @"setHierarchy" : @[@"sports", @"local", @"highschool"],
     @"setEmail" : @"kurt@gmail.com",
     @"setArticleSource" : @"AP",
     @"setArticleType" : @"editorial",
     @"setMediaType" : @"video",
     @"setWordCount" : @1200,
     @"setParagraphCount" : @33,
     @"setReferrer" : @"/last/url",
     @"setScrollPercent" : @50,
     @"setPageNumber" : @"2A",
     @"setCharacterCount" : @2500
     @"setUrl" : @"http://newsreader.com/sports", // for non page view events
     */
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    NSString* pageUrl = [RCTConvert NSString:payload[@"pageUrl"]];
    
     if (pageUrl) {
        options[@"setUrl"] = pageUrl;
    }
    NSString* pageTitle = [RCTConvert NSString:payload[@"pageTitle"]];
    if (pageTitle) {
        options[@"setTitle"] = pageTitle;
    }
    NSString* referrer = [RCTConvert NSString:payload[@"referrer"]];
    if (referrer) {
        options[@"setReferrer"] = referrer;
    }
    NSDictionary* userId = [RCTConvert NSDictionary:payload[@"userId"]];
    if (userId) {
        options[@"setUserId"] = [RCTConvert NSString:userId[@"user"]];
        // no support for logedin
//        bool loggedIn = [userId[@"loggedIn"] boolValue];
    }
    NSString* section = [RCTConvert NSString:payload[@"section"]];
    if (section) {
        options[@"setSection"] = section;
    }
    NSString* author = [RCTConvert NSString:payload[@"author"]];
    if (author) {
        options[@"setAuthor"] = author;
    }
    NSString* pageType = [RCTConvert NSString:payload[@"pageType"]];
    if (pageType) {
        options[@"setPageType"] = pageType;
    }
    NSDictionary* articlePublishTime = [RCTConvert NSDictionary:payload[@"articlePublishTime"]];
    if (articlePublishTime) {
        options[@"setArticlePublishTime"] =
        getDateFromString(
                          [RCTConvert NSString:articlePublishTime[@"time"]],
                          [RCTConvert NSString:articlePublishTime[@"timeZone"]],
                          [RCTConvert NSString:articlePublishTime[@"format"]]
                          );
    }
    if (payload[@"premium"]) {
        bool premium = [payload[@"premium"] boolValue];
        options[@"setPremium"] = [NSNumber numberWithBool:premium];
    }
    NSString* metered = [RCTConvert NSString:payload[@"metered"]];
    if (metered) {
        options[@"setMetered"] = metered;
    }
    NSString* publication = [RCTConvert NSString:payload[@"publication"]];
    if (publication) {
        options[@"setPublication"] = publication;
    }
    NSArray<NSString *>* categories = [RCTConvert NSStringArray:payload[@"categories"]];
    if (categories) {
        options[@"setCategories"] = categories;
    }
    NSString* appName = [RCTConvert NSString:payload[@"appName"]];
    if (appName) {
        options[@"setAppName"] = appName;
    }
    NSString* referenceNav = [RCTConvert NSString:payload[@"referenceNav"]];
    if (referenceNav) {
        options[@"setReferenceNav"] = referenceNav;
    }
    NSString* articleId = [RCTConvert NSString:payload[@"articleId"]];
    if (articleId) {
        options[@"setArticleId"] = articleId;
    }
    NSDictionary* articleUpdateTime = [RCTConvert NSDictionary:payload[@"articleUpdateTime"]];
    if (articleUpdateTime) {
        options[@"setArticleUpdateTime"] =
        getDateFromString(
                          [RCTConvert NSString:articleUpdateTime[@"time"]],
                          [RCTConvert NSString:articleUpdateTime[@"timeZone"]],
                          [RCTConvert NSString:articleUpdateTime[@"format"]]
                          );
    }
    NSArray<NSString *>* hierarchy = [RCTConvert NSStringArray:payload[@"hierarchy"]];
    if (hierarchy) {
        options[@"setHierarchy"] = hierarchy;
    }
    NSString* email = [RCTConvert NSString:payload[@"email"]];
    if (email) {
        options[@"setEmail"] = email;
    }
    NSString* articleSource = [RCTConvert NSString:payload[@"articleSource"]];
    if (articleSource) {
        options[@"setArticleSource"] = articleSource;
    }
    NSString* mediaType = [RCTConvert NSString:payload[@"mediaType"]];
    if (mediaType) {
        options[@"setMediaType"] = mediaType;
    }
    NSString* articleType = [RCTConvert NSString:payload[@"articleType"]];
    if (articleType) {
        options[@"setArticleType"] = articleType;
    }
    NSString* characterCount = [RCTConvert NSString:payload[@"characterCount"]];
    if (characterCount) {
        options[@"setCharacterCount"] = [NSNumber numberWithInteger:[characterCount intValue]];
    }
    NSString* wordCount = [RCTConvert NSString:payload[@"wordCount"]];
    if (wordCount) {
        options[@"setWordCount"] = [NSNumber numberWithInteger:[wordCount intValue]];
    }
    NSString* paragraphCount = [RCTConvert NSString:payload[@"paragraphCount"]];
    if (paragraphCount) {
        options[@"setParagraphCount"] = [NSNumber numberWithInteger:[paragraphCount intValue]];
    }
    NSString* scrollPercent = [RCTConvert NSString:payload[@"scrollPercent"]];
    if (scrollPercent) {
        options[@"setScrollPercent"] = [NSNumber numberWithInteger:[scrollPercent intValue]];
    }
    NSString* pageNumber = [RCTConvert NSString:payload[@"pageNumber"]];
    if (pageNumber) {
        options[@"setPageNumber"] = pageNumber;
    }
    NSDictionary* addCtxSection = [RCTConvert NSDictionary:payload[@"addCtxSection"]];
    if (addCtxSection) {
        NSString* contextName = [RCTConvert NSString:addCtxSection[@"name"]];
        NSDictionary* contextValue = [RCTConvert NSDictionary:addCtxSection[@"value"]];
        options[@"setContext"] = @{contextName : contextValue};
    }
    // no support for userDB
//    NSDictionary* userDB = [RCTConvert NSDictionary:payload[@"userDB"]];
//    if (userDB) {
//    }
    
    
//    [mListener trackPageView:pageUrl options:options];
}

RCT_EXPORT_METHOD(trackAction:(nonnull NSString *)accountName
                  accountNumber:(nonnull NSString *)accountNumber
                  payload:(nonnull NSDictionary *)payload)
{
    //    MListener *mListener;
    //    mListener = [[MListener alloc] init:@"http:www.i.matheranalytics.com"
    //        appId:@"v1"
    //        customerId:accountName
    //        market:accountNumber
    //        cookieDomain:@"newsreader.com"
    //        enableActivityTracking:YES];

    NSMutableDictionary *event = [[NSMutableDictionary alloc] init];
        
    // no support for type
//    NSString* type = [RCTConvert NSString:payload[@"type"]];
//    if (type) {
//        event[@"type"] = type;
//    }
    NSString* category = [RCTConvert NSString:payload[@"category"]];
    if (category) {
        event[@"category"] = category;
    }
    NSString* action = [RCTConvert NSString:payload[@"action"]];
    if (action) {
        event[@"action"] = action;
    }
    
    // no support for custom
//    NSDictionary* custom = [RCTConvert NSDictionary:payload[@"custom"]];
//    if (custom) {
//        impression[@"custom"] = custom;
//    }

//    [mListener trackEvent:event];
}

RCT_EXPORT_METHOD(trackImpression:(nonnull NSString *)accountName
                  accountNumber:(nonnull NSString *)accountNumber
                  payload:(nonnull NSDictionary *)payload)
{
//    MListener *mListener;
//    mListener = [[MListener alloc] init:@"http:www.i.matheranalytics.com"
//        appId:@"v1"
//        customerId:accountName
//        market:accountNumber
//        cookieDomain:@"newsreader.com"
//        enableActivityTracking:YES];

    NSMutableDictionary *impression = [[NSMutableDictionary alloc] init];
    
    NSString* eaid = [RCTConvert NSString:payload[@"eaid"]];
    if (eaid) {
        impression[@"eaid"] = eaid;
    }
    NSString* ebuy = [RCTConvert NSString:payload[@"eaid"]];
    if (ebuy) {
        impression[@"ebuy"] = ebuy;
    }
    NSString* eadv = [RCTConvert NSString:payload[@"eadv"]];
    if (eadv) {
        impression[@"eadv"] = eadv;
    }
    NSString* ecid = [RCTConvert NSString:payload[@"ecid"]];
    if (ecid) {
        impression[@"ecid"] = ecid;
    }
    NSString* epid = [RCTConvert NSString:payload[@"epid"]];
    if (eaid) {
        impression[@"epid"] = epid;
    }
    NSString* esid = [RCTConvert NSString:payload[@"esid"]];
    if (esid) {
        impression[@"esid"] = esid;
    }
    
    // no support for custom
//    NSDictionary* custom = [RCTConvert NSDictionary:payload[@"custom"]];
//    if (custom) {
//        impression[@"custom"] = custom;
//    }

//    [mListener trackAdImpression:impression];
}

static NSDate* getDateFromString(NSString* time, NSString* timeZone, NSString* format)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setTimeZone: [NSTimeZone timeZoneWithName:timeZone]];
    return [formatter dateFromString:time];
}

@end
