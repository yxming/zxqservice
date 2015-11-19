//
//  TcpConnection.m
//  zxqservice
//
//  Created by nigel on 15/10/10.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "TcpConnection.h"
@interface TcpConnection ()
@property (strong, nonatomic)NSInputStream* inputStream;
@property (strong, nonatomic)NSOutputStream* outputStream;
@end

@implementation TcpConnection

- (id)initWithHostNamed:(NSString*)ipaddr port:(UInt32)port
{
    self = [super init];
    if (self) {
        [self getStreamsToHostNamed:ipaddr port:port inputStream:&_inputStream outputStream:&_outputStream];
        
        //[self.inputStream setDelegate:self];
        [self.outputStream setDelegate:self];
        //[self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        //[self.inputStream open];
        [self.outputStream open];
        NSStreamStatus status=self.outputStream.streamStatus;
        NSError *err=self.outputStream.streamError;
        NSLog(@"Tcp Connect outputStream:%d",status);
        if (err!=nil) {
            NSLog(@"outputStream:\n       %@",err);
        }
    }
    return self;
}

- (NSInteger)sendCommand:(NSDictionary*)detailDic {
    
    NSError* err=nil;
    NSData* jsonData=[NSJSONSerialization dataWithJSONObject:detailDic options:NSJSONWritingPrettyPrinted error:&err];
    
    NSInteger len = [self.outputStream write:[jsonData bytes] maxLength:jsonData.length];
    return len;
}

- (void)setOutputStreamDelegate:(id<NSStreamDelegate>)delgate
{
    self.outputStream.delegate=delgate;
}

- (void)dealloc
{
    //[self.inputStream close];
    //[self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    
    [self.outputStream close];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [super dealloc];
}
/*
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    NSError* err;
    NSMutableData* _receivedData;
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            if (aStream==self.inputStream) {
                //
            }
            break;
        case NSStreamEventHasBytesAvailable:
            //[_logDisplay setText:[_logDisplay.text stringByAppendingString:[NSString stringWithFormat:@"%@ new data... \n",aStream]]];
            if (_receivedData == nil) {
                _receivedData = [[NSMutableData alloc] init];
            }
            
            uint8_t buf[128];
            int numBytesRead = (int)[(NSInputStream *)aStream read:buf maxLength:128];
            
            if (numBytesRead > 0) {
                //[self connectResulte:[NSData dataWithBytes:buf length:numBytesRead]];
                
            } else if (numBytesRead == 0) {
                NSLog(@" >> End of stream reached");
                
            } else {
                NSLog(@" >> Read error occurred");
            }
            
            break;
        case NSStreamEventHasSpaceAvailable:
            //[_logDisplay setText:[_logDisplay.text stringByAppendingString:[NSString stringWithFormat:@"%@ new space... \n",aStream]]];
            break;
        case NSStreamEventErrorOccurred:
            err=aStream.streamError;
            //[_logDisplay setText:[_logDisplay.text stringByAppendingString:[NSString stringWithFormat:@"Error code:%ld, cause:%@. \n",(long)err.code,err.localizedDescription]]];
            
            break;
        default:
            break;
    }
}
*/
- (void)getStreamsToHostNamed:(NSString *)hostName
                         port:(UInt32)port
                  inputStream:(out NSInputStream **)inputStreamPtr
                 outputStream:(out NSOutputStream **)outputStreamPtr
{
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    
    assert(hostName != nil);
    assert( (port > 0) && (port < 65536) );
    assert( (inputStreamPtr != NULL) || (outputStreamPtr != NULL) );
    
    readStream = NULL;
    writeStream = NULL;
    
    CFStreamCreatePairWithSocketToHost(
                                       NULL,
                                       (__bridge CFStringRef) hostName,
                                       port,
                                       ((inputStreamPtr  != NULL) ? &readStream : NULL),
                                       ((outputStreamPtr != NULL) ? &writeStream : NULL)
                                       );
    
    if (inputStreamPtr != NULL) {
        *inputStreamPtr  = CFBridgingRelease(readStream);
    }
    
    if (outputStreamPtr != NULL) {
        *outputStreamPtr = CFBridgingRelease(writeStream);
    }
}
@end
