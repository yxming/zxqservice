//
//  TcpConnection.h
//  zxqservice
//
//  Created by nigel on 15/10/10.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TcpConnection : NSObject<NSStreamDelegate>
- (id)initWithHostNamed:(NSString*)ipaddr port:(UInt32)port;
- (void)setOutputStreamDelegate:(id<NSStreamDelegate>)delgate;
@end
