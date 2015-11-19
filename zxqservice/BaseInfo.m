//
//  BaseInfo.m
//  zxqservice
//
//  Created by nigel on 15/10/9.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "BaseInfo.h"
@interface BaseInfo ()
@end

@implementation BaseInfo
- (NSDictionary*)generateDictionary
{
    NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithUnsignedLong:self.source],@"source",[NSNumber numberWithUnsignedLong:self.type],@"type",[NSNumber numberWithUnsignedLong:self.cmd],@"cmd", nil];
    return dic;
}
@end
