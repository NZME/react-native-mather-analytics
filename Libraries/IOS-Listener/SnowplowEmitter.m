//
//  SnowplowEmitter.m
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

#import "SnowplowEmitter.h"
#import "SnowplowUtils.h"

@implementation SnowplowEmitter {
    NSURL *                     _urlEndpoint;
    NSString *                  _httpMethod;
    NSLock *                    _arrayLock;
    NSMutableArray *            _sendQueue;
    dispatch_semaphore_t        _sendSema;
}


+ (NSURLSession *)snowplowURLSession
{
    static NSURLSession *sharedSession = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^()
    {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.allowsCellularAccess = YES;
        sessionConfig.HTTPShouldUsePipelining = YES;
        sessionConfig.HTTPShouldSetCookies = YES;

        sharedSession = [NSURLSession sessionWithConfiguration:sessionConfig
                                                      delegate:nil
                                                 delegateQueue:nil];
    });
    
    return sharedSession;
}

- (id) init {
    return [self initWithURLRequest:nil httpMethod:@"POST" bufferOption:SnowplowBufferDefault];
}

- (id) initWithURLRequest:(NSURL *)url {
    return [self initWithURLRequest:url httpMethod:@"POST" bufferOption:SnowplowBufferDefault];
}

- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString* )method {
    return [self initWithURLRequest:url httpMethod:method bufferOption:SnowplowBufferDefault];
}

- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString *)method bufferOption:(enum SnowplowBufferOptions)option {
    self = [super init];
    if(self) {
        _arrayLock = [[NSLock alloc] init];
        _sendSema = dispatch_semaphore_create(0);
        _sendQueue = [[NSMutableArray alloc] init];
        
        //[NSThread detachNewThreadSelector:@selector(sendThread) toTarget:self withObject:nil];
        
        _urlEndpoint = url;
        _httpMethod = method;
        _urlEndpoint = [url URLByAppendingPathComponent:@"/i"];
    }
    return self;
}

- (void) sendRequest:(NSInteger)delay
{
    NSDictionary *payloadDict = nil;
    [NSThread sleepForTimeInterval:delay];

    [_arrayLock lock];
    if ([_sendQueue count] > 0)
    {
        payloadDict = [_sendQueue objectAtIndex:0];
    }
    [_arrayLock unlock];
    
    if (payloadDict)
    {
        NSString *url = [NSString stringWithFormat:@"%@?%@", [_urlEndpoint absoluteString], [SnowplowUtils urlEncodeDictionary:payloadDict]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:20.0];
        request.HTTPMethod = @"GET";
        [request setValue:[self acceptContentTypeHeader] forHTTPHeaderField:@"Accept"];

        [[[[self class] snowplowURLSession]
          dataTaskWithRequest:request
          completionHandler:^(NSData *data,
                              NSURLResponse *response,
                              NSError *error) {
              
              [[NSURLCache sharedURLCache] removeAllCachedResponses];

              NSInteger count = 1;
              NSInteger delay;

              if (error) {
                  NSLog(@"Error: %@", error);
                  delay = 5.0f;
              }
              else {
                  //DLog(@"JSON: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                  [self->_arrayLock lock];
                  [self->_sendQueue removeObjectAtIndex:0];
                  count = [self->_sendQueue count];
                  [self->_arrayLock unlock];

                  delay = 0.1f;
              }
              
              if (count > 0)
              {
                  [self sendRequest:delay];
              }
          }] resume];
    }
}

- (void) addPayloadToBuffer:(SnowplowPayload *)spPayload {
    NSDictionary *payloadDict = [spPayload getPayloadAsDictionary];
    NSInteger count;
    [_arrayLock lock];
    [_sendQueue addObject:payloadDict];
    count = [_sendQueue count];
    [_arrayLock unlock];
    
    if (count == 1)
    {
        [self sendRequest:0.0f];
    }
}

- (void) setHttpMethod:(NSString *)method {
    _httpMethod = method;
}

- (void) setUrlEndpoint:(NSURL *) url {
    _urlEndpoint = [url URLByAppendingPathComponent:@"/i"];
}

- (NSString *)acceptContentTypeHeader
{
    return @"text/html, application/x-www-form-urlencoded, text/plain, image/gif";
}
                       
@end
