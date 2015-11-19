//
//  ComponentInfo.h
//  zxqservice
//
//  Created by nigel on 15/10/9.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "BaseInfo.h"

@interface ComponentInfo : BaseInfo
@property(assign, nonatomic)NSUInteger componentId;
- (id)initWithRegisterComponentID:(NSUInteger)compID;
- (id)initWithUnRegisterComponentID:(NSUInteger)compID;
@end
