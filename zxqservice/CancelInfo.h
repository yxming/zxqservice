//
//  CancelInfo.h
//  zxqservice
//
//  Created by nigel on 15/10/9.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "BaseInfo.h"

@interface CancelInfo : BaseInfo
@property(assign, nonatomic)NSUInteger transferId;
@property(assign, nonatomic)BOOL issender;
- (id)initWithTransferID:(NSUInteger)transferID IsSender:(BOOL)isSender;
@end
