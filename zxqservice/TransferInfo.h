//
//  TransferInfo.h
//  zxqservice
//
//  Created by nigel on 15/9/16.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "BaseInfo.h"

@interface TransferInfo : BaseInfo
@property(assign, nonatomic)NSUInteger srcComID;
@property(assign, nonatomic)NSUInteger dstComID;
@property(assign, nonatomic)NSUInteger transferId;
@property(strong, nonatomic)NSString*  path;
@property(strong, nonatomic)NSString*  filename;
@property(assign, nonatomic)NSUInteger length;
@property(strong, nonatomic)NSString*  attachInfo;

- (id)initWithSrcComID:(NSUInteger)srcComID
              DstComID:(NSUInteger)dstComID
            TransferID:(NSUInteger)transferID
              FileName:(NSString*)fileName
            FileLength:(NSUInteger)length;
@end
