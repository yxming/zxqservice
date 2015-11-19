//
//  TransferServer.h
//  zxqservice
//
//  Created by nigel on 15/10/28.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comm.h"
@interface TransferServer : NSObject
{
    NSArray *theRunLoopModes;
    CFReadStreamRef theReadStream;
    CFWriteStreamRef theWriteStream;
    CFRunLoopRef theRunLoop;
}
@property(strong, nonatomic)id<TransferStateDelegate>statusDelegate;
- (id)initWithPort:(NSUInteger)port;
- (BOOL)createAcceptServer;
- (void)cancel;
- (NSString*)getServerIP;
+(NSUInteger)getPort;
- (TransferServer*)getNewSocket;
- (void)setStatus:(int)status;
- (void)setSavePath:(NSString*)path andSize:(NSUInteger)size;
@end
