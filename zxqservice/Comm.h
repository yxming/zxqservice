//
//  Comm.h
//  zxqservice
//
//  Created by nigel on 15/11/2.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#ifndef zxqservice_Comm_h
#define zxqservice_Comm_h
#import "ProgressInfo.h"
typedef NS_ENUM(NSInteger, TRANSFERTYPE) {
    TCP=1,
    UDP
};

@protocol TransferStateDelegate <NSObject>
- (void)transmissionCompleted:(NSUInteger)transferID;
- (void)transmissionFailed:(NSUInteger)transferID;
- (void)transmissionProgress:(ProgressInfo*)progressInfo;
@end

#endif
