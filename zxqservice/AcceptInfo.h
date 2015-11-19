//
//  AcceptInfo.h
//  zxqservice
//
//  Created by nigel on 15/10/9.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "BaseInfo.h"

@interface AcceptInfo : BaseInfo
@property(assign, nonatomic)NSUInteger transferId;
@property(assign, nonatomic)short accept;
@property(strong, nonatomic)NSString*  ip;
@property(assign, nonatomic)NSUInteger port;
@property(assign, nonatomic)unsigned long seek;
- (id)initWithTransferID:(NSUInteger)transferID
                Accept:(short)accept
             IPAddress:(NSString*)ipAddr Port:(NSUInteger)port;
@end
