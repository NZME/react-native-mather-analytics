//
//  SnowplowPayload.m
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

#import "SnowplowPayload.h"

@implementation SnowplowPayload {
    NSMutableDictionary * _payload;
}

- (id) init {
    self = [super init];
    if(self) {
        _payload = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id) initWithNSDictionary:(NSDictionary *) dict {
    self = [super init];
    if(self) {
        _payload = [NSMutableDictionary dictionaryWithDictionary:dict];
    }
    return self;
}

+ (instancetype) payloadWithDictionary:(NSDictionary *) dict {
    return [[self alloc] initWithDictionary:dict];
}

- (void) addValueToPayload:(NSString *)value forKey:(NSString *)key {
    if (value == nil) {
        [_payload removeObjectForKey:key];
        
    } else {
        [_payload setObject:value forKey:key];
    }
}

- (void) addDictionaryToPayload:(NSDictionary *)dict {
    return dict == nil ? nil : [_payload addEntriesFromDictionary:dict];
}

- (id)processParsedObject:(id)object
{
    [self processParsedObject:object depth:0 parent:nil key:nil];
    return object;
}

- (void)processParsedObject:(id)object depth:(int)depth parent:(id)parent key:(id)key
{
    if ([object isKindOfClass:[NSDictionary class]])
    {
        for (NSString *key in [object allKeys])
        {
            id child = [object objectForKey:key];
            [self processParsedObject:child depth:(depth + 1) parent:object key:key];
        }
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        for (int i = 0; i <  [object count]; i++)
        {
            id child = [object objectAtIndex:i];
            [self processParsedObject:child depth:(depth + 1) parent:object key:[NSNumber numberWithInt:i]];
        }
    }
    else if ([object isKindOfClass:[NSNumber class]])
    {
        NSString *num = [object stringValue];
        
        if ([parent isKindOfClass:[NSArray class]]) {
            NSUInteger idx = [((NSNumber *)key) intValue];
            
            [parent replaceObjectAtIndex:idx withObject:num];
            
        } else {
            [parent setObject:num forKey:(NSString *)key];
        }
    }
}

- (void) addDictionaryToPayload:(NSDictionary *)dict
                  base64Encoded:(Boolean)encode
                typeWhenEncoded:(NSString *)typeEncoded
             typeWhenNotEncoded:(NSString *)typeNotEncoded {
    
    NSError* error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSMutableDictionary *mdict = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:&error];
    json = [NSJSONSerialization dataWithJSONObject:[self processParsedObject:mdict] options:0 error:&error];
    
    if (error) {
        LogError(@"addJsonToPayload: error: %@", error.userInfo);
        return;
    }
    
    // Checks if it conforms to NSDictionary type
    if ([mdict isKindOfClass:[NSDictionary class]]) {
        NSString *encodedString = nil;
        if (encode) {
            encodedString = [json base64EncodedStringWithOptions:0];
            
            // We need URL safe with no padding. Since there is no built-in way to do this, we transform
            // the encoded payload to make it URL safe by replacing chars that are different in the URL-safe
            // alphabet. Namely, 62 is - instead of +, and 63 _ instead of /.
            // See: https://tools.ietf.org/html/rfc4648#section-5
            encodedString = [[encodedString stringByReplacingOccurrencesOfString:@"/" withString:@"_"]
                             stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
            
            // There is also no padding since the length is implicitly known.
            encodedString = [encodedString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
            
            [self addValueToPayload:encodedString forKey:typeEncoded];
        } else {
            [self addValueToPayload:[[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding] forKey:typeNotEncoded];
        }
    } // else handle a bad name-value pair even though it passes JSONSerialization?
}

- (void) addJsonStringToPayload:(NSString *)json
                  base64Encoded:(Boolean)encode
                typeWhenEncoded:(NSString *)typeEncoded
             typeWhenNotEncoded:(NSString *)typeNotEncoded {
    
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if (error) {
        LogError(@"addJsonToPayload: error: %@", error.userInfo);
        return;
    }
    
    [self addDictionaryToPayload:dict
                   base64Encoded:encode
                 typeWhenEncoded:typeEncoded
              typeWhenNotEncoded:typeNotEncoded];
    
}


- (NSDictionary *) getPayloadAsDictionary {
    return _payload;
}

- (NSString *) description {
    return [[self getPayloadAsDictionary] description];
}

@end
