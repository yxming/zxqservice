//
//  NetWorkManager.m
//  zxqservice
//
//  Created by nigel on 15/10/8.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "NetWorkManager.h"
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
static NetWorkManager *sNetIns;

@interface NetWorkManager ()

@property (strong, nonatomic)NSInputStream* inputStream;
@property (strong, nonatomic)NSOutputStream* outputStream;
@property (strong, nonatomic)id<NetWorkDelegate> netWorkDelegate;
@end

@implementation NetWorkManager
+ (id)getInstance
{
    if (sNetIns==nil) {
        sNetIns = [[NetWorkManager alloc] init];
    }
    return sNetIns;
}

- (NSString*)getLocalIPAddress
{
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);

    return address;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString* ipAddr=[self getLocalIPAddress];
        NSRange range= [ipAddr rangeOfString:@"." options:NSBackwardsSearch];
        range.location+=1;
        range.length=ipAddr.length-range.location;
        NSString* serverIp=[ipAddr stringByReplacingCharactersInRange:range withString:@"1"];
        [self getStreamsToHostNamed:serverIp port:50001 inputStream:&_inputStream outputStream:&_outputStream];
        NSLog(@"......Server IP:%@, Port:%d",serverIp,50001);
        [self.inputStream setDelegate:self];
        [self.outputStream setDelegate:self];
        [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.inputStream open];
        [self.outputStream open];
        
        [self.inputStream setProperty:@"inputstream" forKey:@"type"];
        [self.outputStream setProperty:@"outputstream" forKey:@"type"];
        
        NSStreamStatus status=self.outputStream.streamStatus;
        NSError *err=self.outputStream.streamError;
        NSLog(@"....NetWorkManager....init....status:%d    err:%@",status,err);
    }
    return self;
}

- (void)setNetWorkDelegate:(id<NetWorkDelegate>) netDelegate
{
    [_netWorkDelegate release];
    _netWorkDelegate = netDelegate;
}

- (void)sendCommand:(NSDictionary*)detailDic {
    NSLog(@"data will sending:\n   %@",detailDic);
    NSError* err=nil;
    NSData* jsonData=[NSJSONSerialization dataWithJSONObject:detailDic options:NSJSONWritingPrettyPrinted error:&err];

    NSMutableData* streamData = [[NSMutableData alloc] initWithCapacity:128];
  

    [streamData appendData:[[NSString stringWithFormat:@"ABBC"] dataUsingEncoding:NSASCIIStringEncoding]];
    short version = 1;
    [streamData appendData:[NSData dataWithBytes:&version length:2]];
    NSUInteger bodylen = [jsonData length];

    [streamData appendData:[NSData dataWithBytes:&bodylen length:4]];
    
    [streamData appendData:jsonData];
    
    if (self.outputStream.hasSpaceAvailable==YES) {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSInteger len = [self.outputStream write:[streamData bytes] maxLength:streamData.length];
            if(len<0)
            {
                NSError* err = [self.outputStream streamError];
                NSLog(@"send data error:%@",err);
            }else{
                NSLog(@"send data success! length:%ld",(long)len);
            }
        });
    }else{
        NSLog(@"outputstream no space to write data");
    }
    
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    NSError* err;
    NSMutableData* _receivedData;
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            if (aStream==self.outputStream) {
                //[self.netWorkDelegate receiveMessageFromCar:[NSDictionary dictionaryWithObjectsAndKeys:@"open",@"status", nil]];
                //dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    //[self.netWorkDelegate receiveMessageFromCar:[NSDictionary dictionaryWithObjectsAndKeys:@"open",@"status", nil]];
                //});
            }
            NSLog(@"%@ open completed.",[aStream propertyForKey:@"type"]);
            break;
        case NSStreamEventHasBytesAvailable:
            if (_receivedData == nil) {
                _receivedData = [[NSMutableData alloc] init];
            }
            uint8_t buf[512]={0};
            char* pt = (char*)&buf;
            uint8_t body[512]={0};
            int numBytesRead = (int)[(NSInputStream *)aStream read:buf maxLength:512];
            NSLog(@"NetWorkManager receive data:%d",numBytesRead);
            if (numBytesRead > 0) {
                //[self connectResulte:[NSData dataWithBytes:buf length:numBytesRead]];
                memcpy(body, (pt+10), numBytesRead-10);
            
                [self.netWorkDelegate receiveMessageFromCar:[NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:body length:numBytesRead-10] options:NSJSONReadingAllowFragments error:&err]];
                
            } else if (numBytesRead == 0) {
                NSLog(@" >> End of stream reached");
                
            } else {
                NSLog(@" >> Read stream error occurred");
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

- (void)dealloc
{
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream close];
    
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream close];
    [super dealloc];
}
@end
