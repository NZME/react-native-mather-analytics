//
//  MUserDB.h
//
//  Mather Listener User Database Handler
//  Authors: Doug Scher
//  Copyright: Copyright (c) 2014-2018 Mather Economics
//

#import "MListener.h"
#import "MUserDB.h"

@implementation MUserDB {
    NSMutableDictionary     *_options;
    SnowplowTracker         *_tracker;
}

// configUserDBDefaults = { minPageViews: 2, timeoutMs: 10000, noCache: false, userDBData: { segments: [], meterData: { meterThreshold: '0', resetMeter: '0' } } },
// tracker.setUserDBUrl(options.userDBUrl || 'app.matheranalytics.com') && options.userDBUrl && delete options.userDBUrl;


- (id) init:(SnowplowTracker *)tracker_ options:(NSDictionary *)options
{
    self = [super init];
    if(self) {
        _tracker = tracker_;

        NSDictionary *defaultOptions =
            @{
                @"minPageViews" : @2,
                @"timeoutMs" : @10.0,
                @"noCache" : @NO,
                @"userDBUrl" : @"https://app.matheranalytics.com",
                @"userDBData" :
                    @{
                        @"segments" : @[],
                        @"meterData" :
                            @{
                                @"meterThreshold": @"0",
                                @"resetMeter": @"0"
                            },
                        @"pageViews" : @0,
                        @"updateTS" : @0,
                        @"nextUpdate": @0,
                        @"nextUpdateTS": @0,
                        @"fromCache": @YES,
                        @"userDBFetch": @NO
                    }
            };

        _options = [defaultOptions mutableCopy];

        if (options != nil) {
            [options enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
                [self->_options setValue:object forKey:key];
            }];
        }
    }
    return self;
}

- (void) postError:(NSMutableDictionary *)response err:(NSString *)err {
    NSString *msg = [NSString stringWithFormat:@"UserDB failed: %@", err];

    [response setObject:msg forKey:@"err"];
    LogError(@"%@", msg);
}

- (NSMutableDictionary *)getUserDBCache {
    NSMutableDictionary *userDB = [[[_tracker defaultsDict] objectForKey:@"userDB"] mutableCopy];

    if (userDB == nil) {
        userDB = [_options[@"userDBData"] mutableCopy];
        [[_tracker defaultsDict] setObject:userDB forKey:@"userDB"];
    }

//    userDB = [_options[@"userDBData"] mutableCopy];

    return userDB;
}

- (void)setUserDBCache:(NSMutableDictionary *)userDB {
    [[_tracker defaultsDict] setObject:userDB forKey:@"userDB"];
    [[_tracker defaultsDict] removeObjectForKey:@"uid"]; // never store
    [_tracker saveDefaults];
}

- (void) userDBComplete:(NSMutableDictionary *)response fromCache:(BOOL)fromCache  callback:(void(^)(NSDictionary *response))callback {
    [self setUserDBCache:response];

    if (fromCache) {
        [response setObject:@YES forKey:@"fromCache"];

    } else {
        [response removeObjectForKey:@"fromCache"];
        [_tracker trackUserDB:response];
    }

    if (callback) callback(response);
}

- (void) sendRequest:(void(^)(NSDictionary *response))callback;
{
    NSMutableDictionary *userDBResponse = [self getUserDBCache];
    Boolean noCache = [_options[@"noCache"] boolValue];
    
    int64_t pageViews = [userDBResponse[@"pageViews"] integerValue];
    pageViews += 1;
    [userDBResponse setObject:@(pageViews) forKey:@"pageViews"];
    
    int64_t currentTime = [[NSDate date] timeIntervalSince1970];
    int64_t nextUpdateTS = [userDBResponse[@"nextUpdateTS"] integerValue];

    if (!noCache &&
        (pageViews  < [_options[@"minPageViews"] integerValue] ||
         (nextUpdateTS > 0 && currentTime < nextUpdateTS))) {

        [self userDBComplete:userDBResponse fromCache:YES callback:callback];
    }
    else {
        [userDBResponse removeObjectForKey:@"err"];
        [userDBResponse removeObjectForKey:@"userDBFetch"];
        [userDBResponse setObject:[_tracker getDuid] forKey:@"duid"];

        NSString *uid = [_tracker MGetBaseTrackerParam:@"uid"];

        if (uid == nil) {
            uid = _options[@"uid"];
        }

        if (uid != nil) {
            [userDBResponse setObject:uid forKey:@"uid"];
        }
        
        NSString *url = [NSString stringWithFormat:@"%@%@", _options[@"userDBUrl"], @"/u/getuserdbdata"];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:[_options[@"timeoutMs"] doubleValue]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"text/plain; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];

//      [request setHTTPBody:[@"{\"duid\":\"4\",\"muid\":\"4\",\"customerId\":\"ma34789\",\"market\":\"234578999\"}" dataUsingEncoding:NSUTF8StringEncoding]];

        NSMutableDictionary *body = [NSMutableDictionary dictionary];
        NSString            *customerId = _options[@"customerId"] ? _options[@"customerId"] :[_tracker MGetBaseTrackerParam:@"cid"];
        NSString            *market = _options[@"market"] ? _options[@"market"] :[_tracker MGetBaseTrackerParam:@"mrk"];

        [body setObject:customerId forKey:@"customerId"];
        [body setObject:market forKey:@"market"];
        [body setObject:userDBResponse[@"duid"] forKey:@"duid"];
        if (uid) {
            [body setObject:uid forKey:@"uid"];
        }

        if (!noCache && userDBResponse[@"muid"]) {
            [body setObject:userDBResponse[@"muid"] forKey:@"muid"];
        }

        NSString *metered = [_tracker MGetBaseTrackerParam:@"metered"];
        if (metered) {
            NSArray *counts = [metered componentsSeparatedByString:@"|"];

            [body setObject:counts[0] forKey:@"meterCount"];
            if ([counts count] > 1) {
                [body setObject:counts[1] forKey:@"meterThreshold"];
            }
        }

        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:0 error:nil]];
        [userDBResponse setObject:@YES forKey:@"userDBFetch"];

        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];

        sessionConfig.allowsCellularAccess = YES;
        sessionConfig.HTTPShouldUsePipelining = YES;
        sessionConfig.HTTPShouldSetCookies = YES;

        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                              delegate:nil
                                                         delegateQueue:[NSOperationQueue mainQueue]];

        //Create task
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *err) {
            //NSMutableDictionary *userDBResponse = [self getUserDBCache];

            [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];

            if (err == nil) {
                NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];

                if (responseDict == nil) {
                    [self postError:userDBResponse err:[NSString stringWithFormat:@"response contains invalid JSON: %@", err.userInfo]];

                } else {
                    // merge in the returned values
                    [responseDict enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
                        userDBResponse[key] = object;
                    }];

                    [userDBResponse removeObjectForKey:@"uid"];  // db may return an incorrect uid

                    int64_t responsePageViews = [responseDict[@"pageViews"] integerValue];
                    if (responsePageViews > pageViews) {
                        [userDBResponse setObject:@(responsePageViews) forKey:@"pageViews"];
                    }

                    int64_t now = [[NSDate date] timeIntervalSince1970];
                    now += ([[userDBResponse objectForKey:@"nextUpdate"] integerValue] / 1000);
                    [userDBResponse setObject:[NSNumber numberWithDouble: now] forKey:@"nextUpdateTS"];
                }

            } else {
                NSMutableString *msg = [[NSMutableString alloc]init];
                NSString *localizedDescription = err.userInfo[@"NSLocalizedDescription"];

                if (localizedDescription != nil) {
                    [msg setString:localizedDescription];

                } else {
                    [msg setString:@"unknown error"];
                }
                
                [self postError:userDBResponse err:[NSString stringWithFormat:@"fetch failed: %@",msg]];
            }

            [self userDBComplete:userDBResponse fromCache:NO callback:callback];
            
            [session finishTasksAndInvalidate];
        }];
        [dataTask resume];
    }
}

@end
