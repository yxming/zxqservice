//
//  ComponentInfo.m
//  zxqservice
//
//  Created by nigel on 15/10/9.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "ComponentInfo.h"

@implementation ComponentInfo

- (id)initWithRegisterComponentID:(NSUInteger)compID
{
    self = [super init];
    if (self) {
        _componentId = compID;
        self.source=1;
        self.type=1;
        self.cmd=4;
    }
    return self;
}
- (id)initWithUnRegisterComponentID:(NSUInteger)compID
{
    self = [super init];
    if (self) {
        _componentId = compID;
        self.source=1;
        self.type=1;
        self.cmd=5;
    }
    return self;
}
- (NSDictionary*)generateDictionary
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:[super generateDictionary]];
    [dic setObject:[NSArray arrayWithObjects:[NSNumber numberWithLong:self.componentId], nil] forKey:@"componentId"];
    return dic;
}
@end
