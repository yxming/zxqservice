//
//  ConnectInfo.m
//  zxqservice
//
//  Created by nigel on 15/10/9.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "ConnectInfo.h"

@implementation ConnectInfo
- (id)initWithPhoneName:(NSString*)phone Version:(NSString*)version
{
    self = [super init];
    if (self) {
        _phoneName = phone;
        _imei = @"";
        _loginStatus=NO;
        _loginAccount=@"";
        _version = version;
        _OSVer=1;
        self.source=1;
        self.type=1;
        self.cmd=1;
        
    }
    return self;
}
- (NSDictionary*)generateDictionary
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:[super generateDictionary]];
    [dic setObject:[NSString stringWithFormat:@"%@",self.phoneName] forKey:@"phoneName"];
    [dic setObject:_imei forKey:@"imei"];
    [dic setObject:[NSNumber numberWithBool:_loginStatus] forKey:@"loginStatus"];
    [dic setObject:self.loginAccount forKey:@"loginAccount"];
    [dic setObject:[NSString stringWithFormat:@"%@",self.version] forKey:@"version"];
    [dic setObject:@"" forKey:@"bluetoothMac"];
    [dic setObject:@"" forKey:@"bluetoothName"];
    [dic setObject:[NSNumber numberWithInt:_OSVer] forKey:@"OSVer"];
    
    return dic;
}
@end
