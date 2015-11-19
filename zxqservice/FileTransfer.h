//
//  FileTransfer.h
//  zxqservice
//
//  Created by nigel on 15/10/12.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AcceptInfo.h"
#import "Comm.h"

@interface FileTransfer : NSObject<NSStreamDelegate>
@property(strong, nonatomic)id<TransferStateDelegate>statusDelegate;
- (id)initWithAcceptInfo:(AcceptInfo*)info andFile:(NSString*)path;
- (void)setType:(TRANSFERTYPE)type;
- (void)setFileSize:(NSUInteger)size;
- (void)setStatus:(int)status;
- (void)start:(unsigned long)seek;
- (void)cancel;
@end
