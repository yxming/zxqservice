//
//  ConnectInfo.h
//  zxqservice
//
//  Created by nigel on 15/10/9.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "BaseInfo.h"
@interface ConnectInfo : BaseInfo
@property(strong, nonatomic)NSString* phoneName;
@property(strong, nonatomic)NSString* imei;
@property(assign, nonatomic)BOOL loginStatus;
@property(strong, nonatomic)NSString* loginAccount;
@property(strong, nonatomic)NSString* CarName;
@property(assign, nonatomic)BOOL isCarOwner;
@property(strong, nonatomic)NSString* bluetoothMac;
@property(strong, nonatomic)NSString* version;
@property(assign, nonatomic)int OSVer;
- (id)initWithPhoneName:(NSString*)phone Version:(NSString*)version;
@end
