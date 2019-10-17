#import "MListenerGlobal.h"

@implementation MListenerGlobal

@synthesize mListener;

static NSMutableDictionary *mListenerDictionary = nil;

+ (id)getListener:(NSString *)accountName accountNumber:(NSString *)accountNumber {
    if (!mListenerDictionary) {
        mListenerDictionary = [[NSMutableDictionary alloc] initWithCapacity:20];
    }

    NSString *listenerKey = [accountName stringByAppendingString:accountNumber];

    MListener *mListener;

    mListener = [mListenerDictionary valueForKey:listenerKey];
    if (!mListener) {
        mListener = [[MListener alloc] init:@"http:www.i.matheranalytics.com"
                appId:@"v1"
                customerId:accountName
                market:accountNumber
                cookieDomain:@"newsreader.com"
                enableActivityTracking:YES];

        mListenerDictionary[listenerKey] = mListener;
    }

    return mListener;
}

@end
