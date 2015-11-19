//
//  CancelInfo.m
//  zxqservice
//
//  Created by nigel on 15/10/9.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "CancelInfo.h"

@implementation CancelInfo
- (id)initWithTransferID:(NSUInteger)transferID IsSender:(BOOL)isSender
{
    self = [super init];
    if (self) {
        self.transferId=transferID;
        self.issender=isSender;
        self.source=1;
        self.type=1;
        self.cmd=10;

    }
    return self;
}

- (NSDictionary*)generateDictionary
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:[super generateDictionary]];
    [dic setObject:[NSNumber numberWithLong:self.transferId] forKey:@"transferId"];
    [dic setObject:[NSNumber numberWithBool:self.issender] forKey:@"isSender"];
    return dic;
}
@end
