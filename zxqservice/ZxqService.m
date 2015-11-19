//
//  zxqservice.m
//  zxqservice
//
//  Created by nigel on 15/9/14.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "ZxqService.h"
//#import "NetWorkManager.h"
//#import "FileTransfer.h"
#import "FileInTransfer.h"
//#import "TransferServer.h"
#pragma mark -
#pragma mark ZxqService private
@interface ZxqService ()
{
    NetWorkManager*      _networkmanager;
    NSString*            _sendFilePath;
    FileTransfer*        _fileTransfer;
    NSUInteger           _srcComponentID;
    NSMutableDictionary* _sendTransferDic;
    NSMutableDictionary* _receiveTransferDic;
    NSMutableArray*      _transmissionList;
    NSMutableArray*      _file;
    NSString*            _currentCarName;
    NSUInteger           _transferCount;
}
@end

#pragma mark -
#pragma mark ZxqService implementation
@implementation ZxqService

-(id)init
{
    self = [super init];
    if (self) {
        _networkmanager = [NetWorkManager getInstance];
        [_networkmanager setNetWorkDelegate:self];
        _srcComponentID = 0;
        _transferCount = 1000;
    }
    return self;
}

- (void)connectToCarWithPhoneName:(NSString*)phone
{
    ConnectInfo* info = [[ConnectInfo alloc] initWithPhoneName:phone Version:@"1.0"];
    [_networkmanager sendCommand:[info generateDictionary]];
    [info release];
}

- (void)disconnectFromCar
{
    BaseInfo* info = [[BaseInfo alloc] init];
    info.source=1;
    info.type=1;
    info.cmd = 3;
    [_networkmanager sendCommand:[info generateDictionary]];
    [info release];
}

- (NSString*)getTransMissionFileWith:(NSUInteger)transferID
{
    for (FileInTransfer* item in _transmissionList) {
        if(item.transferID==transferID){
            return item.fileName;
        }
    }
    return @"";
}

- (NSString*)getConnectedCar
{
    return _currentCarName;
}

- (void)registerComponent:(NSUInteger)componentID
{
    ComponentInfo* info = [[ComponentInfo alloc] initWithRegisterComponentID:componentID];
    _srcComponentID = componentID;
    [_networkmanager sendCommand:[info generateDictionary]];
    [info release];
}


- (void)unregisterComponent
{
    ComponentInfo* info = [[ComponentInfo alloc] initWithUnRegisterComponentID:_srcComponentID];
    [_networkmanager sendCommand:[info generateDictionary]];
    [info release];
}

- (void)sendMessageToCar:(NSString*)msg withTargetComponentID:(NSUInteger)componentID
{
    MessageInfo* info = [[MessageInfo alloc] initWithSrcComID:_srcComponentID DstComID:componentID Message:msg];
    [_networkmanager sendCommand:[info generateDictionary]];
    [info release];
}

- (NSUInteger)getTransferID
{
    if (_transferCount>9999) {
        _transferCount = 1000;
    }else{
        _transferCount++;
    }
    return _transferCount;
}

- (void)sendFileToCar:(NSString*)filePath withTargetComponentID:(NSUInteger)componentID attachInfo:(NSString*)attachInfo
{
    if (_transmissionList==nil) {
        _transmissionList = [[NSMutableArray alloc] initWithCapacity:5];
    }
    NSUInteger transferID = [self getTransferID];
    NSUInteger length = 0;
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        length = (NSUInteger)[[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    
    /*******/
    //NSFileHandle* fhd = [NSFileHandle fileHandleForReadingAtPath:filePath];
    //[fhd seekToFileOffset:10];
    //unsigned long offset = fhd.offsetInFile;
    //NSData* data=[fhd readDataOfLength:10];
    /********/
    
    FileInTransfer* fint = [[FileInTransfer alloc] init];
    fint.transferID =transferID;
    fint.fileSize=length;
    
    NSRange range = [filePath rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location!=NSNotFound) {
        fint.fileName=[filePath substringFromIndex:range.location+1];
        fint.filePath=[filePath substringToIndex:range.location];
    }
    fint.fullPath = filePath;
    fint.isSender=YES;
    [_transmissionList addObject:fint];
    
    TransferInfo* info = [[TransferInfo alloc] initWithSrcComID:_srcComponentID DstComID:componentID TransferID:transferID FileName:fint.fileName FileLength:length];
    [info setAttachInfo:attachInfo];
    NSLog(@"...start send file to Car:%@",fint.fileName);
    [_networkmanager sendCommand:[info generateDictionary]];
    [info release];
    [fint release];
}

- (BOOL)acceptFileWithTransferID:(NSUInteger)transferID IsAccept:(short)accept savePath:(NSString*)path
{

    NSString* addr=@"";
    NSUInteger port=0;
    NSString* fileName=nil;
    FileInTransfer* transferItem=nil;
    for (FileInTransfer* item in _transmissionList) {
        if (item.transferID == transferID) {
            fileName = item.fileName;
            transferItem = item;
        }
    }
    if(accept==0){
        //拒绝接收文件
        if (transferItem!=nil) {
            [_transmissionList removeObject:transferItem];
        }
    }else if(accept==1){
        //同意接收文件
        //创建文件接收服务器准备接收文件，服务创建成功后，向对方发送Accpet消息。
        
        TransferServer* tfs = [[TransferServer alloc] initWithPort:[TransferServer getPort]];
        BOOL success = [tfs createAcceptServer];
        if (success==YES) {
            tfs.statusDelegate=self;
            [tfs setSavePath:[NSString stringWithFormat:@"%@/%@",path,fileName] andSize:transferItem.fileSize];
            transferItem.tsf=tfs;
            addr = [tfs getServerIP];
            port = [TransferServer getPort];
        }else{
            [tfs release];
            return NO;
        }
        [tfs release];
    }
    AcceptInfo* info = [[AcceptInfo alloc] initWithTransferID:transferID Accept:accept IPAddress:addr Port:port];
    [_networkmanager sendCommand:[info generateDictionary]];
    [info release];
    return YES;
}

- (void)cancelTansfer:(NSUInteger)transferID
{
    for (FileInTransfer* item in _transmissionList) {
        if (item.transferID==transferID) {
            CancelInfo* info = [[CancelInfo alloc] initWithTransferID:transferID IsSender:item.isSender];
            [_networkmanager sendCommand:[info generateDictionary]];
            [info release];
            if (item.isSender) {
                [item.ft setStatus:1];
            }else{
                [[item.tsf getNewSocket] setStatus:1];
            }
        }
    }
}

- (void)heartBeat
{
    NSDictionary* detailDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithShort:1],@"source",[NSNumber numberWithShort:1],@"type",[NSNumber numberWithShort:9],@"cmd",nil];
    [_networkmanager sendCommand:detailDic];
}

- (void)shareMusicList:(NSArray*)songArray
{
    NSMutableArray* msgArray = [[NSMutableArray alloc] init];
    
    for (SongItem* item in songArray) {
        NSDictionary* dicItem = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",[item type]],@"id_type",[NSString stringWithFormat:@"%d",[item source]],@"cp_id",[NSString stringWithFormat:@"%ld",[item getId]],@"id",[item path],@"path",[item url],@"url", nil];
        [msgArray addObject:dicItem];
    }
    NSDictionary* detailDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"source",[NSNumber numberWithInt:2],@"type",[NSNumber numberWithInt:1],@"cmd",[NSNumber numberWithInt:2],@"srcComId",[NSNumber numberWithInt:2],@"dstComId",msgArray,@"msg",nil];
    [_networkmanager sendCommand:detailDic];
    [msgArray release];
}

#pragma mark -
#pragma mark file transfer call back
- (void)transmissionCompleted:(NSUInteger)transferID
{
    [self.zxqServiceDelegate transmissionCompleted:transferID];
    //
    for (FileInTransfer* item in _transmissionList) {
        if(item.transferID==transferID)
        {
            [_transmissionList removeObject:item];
        }
    }
}

- (void)transmissionFailed:(NSUInteger)transferID
{
    [self.zxqServiceDelegate transmissionInterrupted:transferID];
    for (FileInTransfer* item in _transmissionList) {
        if(item.transferID==transferID)
        {
            [_transmissionList removeObject:item];
        }
    }
}

- (void)transmissionProgress:(ProgressInfo*)percentage
{
    
    [(NSObject*)self.zxqServiceDelegate performSelectorOnMainThread:@selector(transmissionProgress:) withObject:percentage waitUntilDone:(NO)];
    //[self.zxqServiceDelegate transmissionPercent:percentage withTransferID:transferID];
}

#pragma mark -
#pragma mark message call back from NetWorkManager
- (void)receiveMessageFromCar:(NSDictionary*)msgDic
{
    NSLog(@"receiveMessageFromCar: \n  %@",msgDic);
    if ([[msgDic objectForKey:@"type"] integerValue]==1) {
        switch ([[msgDic objectForKey:@"cmd"] integerValue]) {
            case 2:
                //连接回应
            {
                ConnectInfo* info = [[ConnectInfo alloc] init];
                info.CarName=[msgDic objectForKey:@"carName"];
                info.version=[msgDic objectForKey:@"version"];
                if(_currentCarName!=nil){
                    [_currentCarName release];
                }
                _currentCarName = [[NSString alloc] initWithString:info.CarName];
                
                [self.zxqServiceDelegate carHasConnected:YES];
                [info release];
            }
                break;
            case 3:
                //断开手机
                [self.zxqServiceDelegate carHasDisconnect];
                break;
            case 7:
                //收到发送文件请求
            {
                
                NSUInteger componentid = [[msgDic objectForKey:@"srcComId"] longValue];
                NSUInteger transferid = [[msgDic objectForKey:@"transferId"] longValue];
                NSUInteger len = [[msgDic objectForKey:@"length"] longValue];
                NSString*  file= [msgDic objectForKey:@"filename"];
                FileInTransfer* fint = [[FileInTransfer alloc] init];
                fint.transferID=transferid;
                fint.fileName=[file stringByReplacingOccurrencesOfString:@"/" withString:@"."];
                fint.fileSize=len;
                fint.isSender=NO;
                [_transmissionList addObject:fint];
                [fint release];
                [self.zxqServiceDelegate transmissionRequested:file length:len componentID:componentid transferID:transferid];
            }
                break;
            case 8:
                //收到是否接受文件请求
            {
                
                int accept = [[msgDic objectForKey:@"accept"] intValue];
                NSUInteger transferid = [[msgDic objectForKey:@"transferId"] longValue];

                NSString* fileName = nil;
                NSString* fullPath = nil;

                FileInTransfer* fint = nil;
                for (FileInTransfer* item in _transmissionList) {
                    if(item.transferID==transferid && item.isSender==YES){
                        fileName = item.fileName;
                        fullPath = item.fullPath;
                        fint = item;
                        break;
                    }
                }
                
                if(accept==1){
                    
                     AcceptInfo* info = [[AcceptInfo alloc] initWithTransferID:[[msgDic objectForKey:@"transferId"] longValue] Accept:[[msgDic objectForKey:@"accept"] shortValue] IPAddress:[msgDic objectForKey:@"ip"] Port:[[msgDic objectForKey:@"port"] intValue]];
                    info.seek=[(NSNumber*)[msgDic objectForKey:@"seek"] unsignedLongValue];
                    NSLog(@"I'll accept car's file....");
                    //连接对方服务器，准备传数据
                    FileTransfer* ft = [[FileTransfer alloc] initWithAcceptInfo:info andFile:fullPath];
                    ft.statusDelegate = self;
                    [ft setFileSize:fint.fileSize];
                    [ft setType:TCP];
                    [ft start:info.seek];
                    fint.ft=ft;
                    [ft release];
                    [info release];
                }else if(fint!=nil){
                    [_transmissionList removeObject:fint];
                }
                
                [self.zxqServiceDelegate transmissionAccepted:accept==1?YES:NO transferID:fint.transferID];
            }
                break;
            case 10:
                //取消文件传输请求
            {
                NSUInteger transferid = [[msgDic objectForKey:@"transferId"] longValue];
                for (FileInTransfer* item in _transmissionList) {
                    if (item.transferID==transferid) {
                        if (item.isSender==YES) {
                            [item.ft cancel];
                        }else{
                            //停止接收，删除已经生成的文件
                            [item.tsf cancel];
                            NSError* err=nil;
                            [[NSFileManager defaultManager] removeItemAtPath:item.fullPath error:&err];
                        }
                        [_transmissionList removeObject:item];
                        break;
                    }
                }
                [self.zxqServiceDelegate transmissionCancelled:transferid];
            }
                break;
            case 9:
                //心跳
                [self heartBeat];
                break;
            default:
                break;
        } 
    }
}

-(void)dealloc
{
    [_networkmanager release];
    [_sendFilePath release];
    [_fileTransfer release];
    [_sendTransferDic release];
    [_receiveTransferDic release];
    [_transmissionList release];
    [_file release];
    [_currentCarName release];
    [super dealloc];
}

@end
