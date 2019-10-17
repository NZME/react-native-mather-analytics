//
//  MUserDB.h
//
//  Mather Listener User Database Handler
//  Authors: Doug Scher
//  Copyright: Copyright (c) 2014-2018 Mather Economics
//

#import <Foundation/Foundation.h>
#import "SnowplowTracker.h"

@interface MUserDB : NSObject

/**
 *  Initializes a newly allocated MUserDB
 *  @return A MUserDB.
 */
- (id) init:(SnowplowTracker *)_tracker options:(NSDictionary *)options;

- (void) sendRequest:(void(^)(NSDictionary *response))callback;


@end
