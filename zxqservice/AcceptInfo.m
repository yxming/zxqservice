//
//  AcceptInfo.m
//  zxqservice
//
//  Created by nigel on 15/10/9.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "AcceptInfo.h"

@implementation AcceptInfo
- (id)initWithTransferID:(NSUInteger)transferID
                Accept:(short)accept
             IPAddress:(NSString*)ipAddr Port:(NSUInteger)port
{
    self = [super init];
    if (self) {
        self.transferId=transferID;
        self.accept=accept;
        self.ip=ipAddr;
        self.port=port;
        self.source=1;
        self.type=1;
        self.cmd=8;
        self.seek=0;
    }
    return self;
}

- (NSDictionary*)generateDictionary
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:[super generateDictionary]];
    [dic setObject:[NSNumber numberWithLong:self.transferId] forKey:@"transferId"];
    
    [dic setObject:[NSNumber numberWithShort:self.accept] forKey:@"accept"];
    [dic setObject:[NSString stringWithFormat:@"%@",self.ip] forKey:@"ip"];
    [dic setObject:[NSNumber numberWithUnsignedInteger:self.port] forKey:@"port"];
    [dic setObject:[NSNumber numberWithUnsignedLong:self.seek] forKey:@"seek"];
    return dic;
}
@end
