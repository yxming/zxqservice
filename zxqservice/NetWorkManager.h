//
//  NetWorkManager.h
//  zxqservice
//
//  Created by nigel on 15/10/8.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol NetWorkDelegate <NSObject>
- (void)receiveMessageFromCar:(NSDictionary*)msgDic;
@end

@interface NetWorkManager : NSObject<NSStreamDelegate>
+ (id)getInstance;
- (void)sendCommand:(NSDictionary*)detailDic;
- (void)setNetWorkDelegate:(id<NetWorkDelegate>) netDelegate;
@end
