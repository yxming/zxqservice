//
//  MessageInfo.m
//  zxqservice
//
//  Created by nigel on 15/10/9.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "MessageInfo.h"

@implementation MessageInfo
- (id)initWithSrcComID:(NSUInteger)srcComID
              DstComID:(NSUInteger)dstComID
               Message:(NSString*)msg
{
    self = [super init];
    if (self) {
        self.srcComID=srcComID;
        self.dstComID=dstComID;
        self.msg=msg;
        self.source=1;
        self.type=2;
        self.cmd=1;
    }
    return self;
}

- (NSDictionary*)generateDictionary
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:[super generateDictionary]];
    [dic setObject:[NSNumber numberWithUnsignedLong:self.srcComID] forKey:@"srcComId"];
    [dic setObject:[NSNumber numberWithUnsignedLong:self.dstComID] forKey:@"dstComId"];
    [dic setObject:[NSString stringWithFormat:@"%@",self.msg] forKey:@"msg"];
    return dic;
}
@end
