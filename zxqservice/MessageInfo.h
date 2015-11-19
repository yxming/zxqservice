//
//  MessageInfo.h
//  zxqservice
//
//  Created by nigel on 15/10/9.
//  Copyright (c) 2015年 nigel. All rights reserved.
//


#import "BaseInfo.h"
@interface MessageInfo : BaseInfo
@property(assign, nonatomic)NSUInteger srcComID;
@property(assign, nonatomic)NSUInteger dstComID;
@property(strong, nonatomic)NSString* msg;
- (id)initWithSrcComID:(NSUInteger)srcComID
              DstComID:(NSUInteger)dstComID
               Message:(NSString*)msg;
@end
