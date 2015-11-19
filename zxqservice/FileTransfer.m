//
//  FileTransfer.m
//  zxqservice
//
//  Created by nigel on 15/10/12.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "FileTransfer.h"
#import "TcpConnection.h"
@interface FileTransfer ()
{
    @private
    
    NSString*      _sendFileName;
    NSInputStream* _inputFileStream;
    NSMutableData* _buffer;
    NSUInteger     _balance;
    NSUInteger     _transferID;
    NSUInteger     _fileSize;
    NSUInteger     _sendLength;
    int          _status;
}
@property(assign, nonatomic)TRANSFERTYPE mType;
@property(strong, nonatomic)TcpConnection* fileSender;
@end

@implementation FileTransfer
- (id)initWithAcceptInfo:(AcceptInfo*)info andFile:(NSString*)path
{
    self = [super init];
    if (self) {
        
        _sendFileName = [[NSString alloc]initWithString:path];
        _fileSender = [[TcpConnection alloc] initWithHostNamed:info.ip port:(UInt32)info.port];
        [_fileSender setOutputStreamDelegate:self];

        _transferID = info.transferId;
        _buffer = [[NSMutableData alloc] initWithLength:1024*128];
        [_buffer resetBytesInRange:NSMakeRange(0,1024*128)];
        _balance = 0;
        _sendLength=0;
        _status=0;
    }
    return self;
}

- (void)setType:(TRANSFERTYPE)type
{
    _mType = type;
}

- (void)setFileSize:(NSUInteger)size
{
    _fileSize = size;
}
- (void)setStatus:(int)status
{
    _status = status;
}

- (void)start:(unsigned long)seek
{
    _inputFileStream = [[NSInputStream alloc] initWithFileAtPath:_sendFileName];
    [_inputFileStream open];
    [_inputFileStream setProperty:[NSNumber numberWithUnsignedLong:seek] forKey:NSStreamFileCurrentOffsetKey];
    _sendLength = seek;
    NSLog(@"will send file: %@",_sendFileName);
}

- (void)cancel
{
    [_inputFileStream close];
    [_inputFileStream release];
    [_fileSender release];
}

- (void)dealloc
{
    [_inputFileStream close];
    [_inputFileStream release];
    [_sendFileName release];
    if (_fileSender) {
        [_fileSender release];
    }
    [_buffer release];
    [super dealloc];
    NSLog(@".....FileTransfer dealloc....");
}



- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    NSError* err;
    NSLog(@"-----------------------------------------------");
    //NSMutableData* _receivedData;
    if (_fileSender == nil) {
        return;
    }
    NSUInteger length;
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"file transefer is ready...");
            break;
//        case NSStreamEventHasBytesAvailable:
//            break;
        case NSStreamEventHasSpaceAvailable:

            if ([_inputFileStream hasBytesAvailable]) {
                if (_balance==0) {
                    [_buffer resetBytesInRange:NSMakeRange(0,1024*128)];
                    length = (NSUInteger)[_inputFileStream read:[_buffer mutableBytes] maxLength:_buffer.length];
                    if (length==0) {
                        NSLog(@"send all:%lu",(unsigned long)_sendLength);
                        [_inputFileStream close];
                        [_fileSender release];
                        _fileSender = nil;
                        [self.statusDelegate transmissionCompleted:_transferID];
                        return;
                    }
                }else{
                    length = _balance;
                }

                NSLog(@"_buffer.length:%lu,read data length:%lu ",(unsigned long)_buffer.length,(unsigned long)length);
                
                if (length>0) {
                    NSUInteger wlen = [(NSOutputStream*)aStream write:[_buffer bytes] maxLength:length];
                    _sendLength+=wlen;
                    int percentage = ((float)_sendLength/_fileSize)*100;
                    ProgressInfo* progInfo = [[ProgressInfo alloc] init];
                    progInfo.transferID=_transferID;
                    progInfo.percentage=percentage;
                    [self.statusDelegate transmissionProgress:progInfo];
                    [progInfo release];
                    _balance=length-wlen;
                    NSLog(@"all:%lu ,buffer len:%lu, write len:%lu, balance len:%lu",(unsigned long)_sendLength,(unsigned long)length,(unsigned long)wlen,(unsigned long)_balance);
                    if (_balance>0) {
                        NSData* blaData = [_buffer subdataWithRange:NSMakeRange(wlen,_balance)];
                        
                        NSLog(@"write data len:%ld",(long)wlen);
                        //[_buffer resetBytesInRange:NSMakeRange(0,1024*128)];
                        //NSLog(@"clear buffer len:%lu",(unsigned long)_buffer.length);
                        
                        [_buffer setData:blaData];
                        NSLog(@"bla buffer len:%lu",(unsigned long)_buffer.length);
                    }
                }
            }else{
                [_inputFileStream close];
                [_fileSender release];
                _fileSender = nil;
                [self.statusDelegate transmissionCompleted:_transferID];
                return;
            }
            break;
        case NSStreamEventErrorOccurred:
            err=aStream.streamError;
            NSLog(@"error:%@",err);
            if (_status!=1) {
                [self.statusDelegate transmissionFailed:_transferID];
                return;
            }
            break;
        default:
            break;
    }
    NSLog(@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
}
@end
