#import <Foundation/Foundation.h>
#import "MListener.h"

@interface MListenerGlobal : NSObject {
    MListener *mListener;
}

@property (nonatomic, retain) MListener *mListener;

+ (id<MListener>)getListener:(NSString *)accountName
               accountNumber:(NSString *)accountNumber;

@end