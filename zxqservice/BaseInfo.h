//
//  BaseInfo.h
//  zxqservice
//
//  Created by nigel on 15/10/9.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseInfo : NSObject
@property(assign, nonatomic)NSUInteger source;
@property(assign, nonatomic)NSUInteger type;
@property(assign, nonatomic)NSUInteger cmd;
- (NSDictionary*)generateDictionary;
@end
