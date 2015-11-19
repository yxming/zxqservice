//
//  FileInTransfer.h
//  zxqservice
//
//  Created by nigel on 15/10/26.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileTransfer.h"
#import "TransferServer.h"
@interface FileInTransfer : NSObject
@property(assign, nonatomic)NSUInteger transferID;
@property(assign, nonatomic)NSUInteger fileSize;
@property(strong, nonatomic)NSString*  fileName;
@property(strong, nonatomic)NSString*  filePath;
@property(strong, nonatomic)NSString*  fullPath;
@property(assign, nonatomic)BOOL       isSender;
@property(strong, nonatomic)FileTransfer* ft;
@property(strong, nonatomic)TransferServer* tsf;
@end
