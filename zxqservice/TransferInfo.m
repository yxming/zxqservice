//
//  TransferInfo.m
//  zxqservice
//
//  Created by nigel on 15/9/16.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "TransferInfo.h"

@implementation TransferInfo
- (id)initWithSrcComID:(NSUInteger)srcComID
              DstComID:(NSUInteger)dstComID
            TransferID:(NSUInteger)transferID
              FileName:(NSString*)fileName
            FileLength:(NSUInteger)length
{
    self = [super init];
    if (self) {
        self.srcComID=srcComID;
        self.dstComID=dstComID;
        self.transferId=transferID;
        self.filename=fileName;
        self.length=length;
        self.source=1;
        self.type=1;
        self.cmd=7;
        self.attachInfo=@"";
    }
    return  self;
}

- (NSDictionary*)generateDictionary
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:[super generateDictionary]];
    [dic setObject:[NSNumber numberWithLong:self.srcComID] forKey:@"srcComId"];
    [dic setObject:[NSNumber numberWithLong:self.dstComID] forKey:@"dstComId"];
    [dic setObject:[NSNumber numberWithLong:self.transferId] forKey:@"transferId"];
    
    [dic setObject:[NSString stringWithFormat:@"%@",self.filename] forKey:@"filename"];
    [dic setObject:[NSNumber numberWithLong:self.length] forKey:@"length"];
    
    [dic setObject:self.attachInfo forKey:@"attachInfo"];
    return dic;
}

@end
