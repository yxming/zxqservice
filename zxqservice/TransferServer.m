//
//  TransferServer.m
//  zxqservice
//
//  Created by nigel on 15/10/28.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "TransferServer.h"
#import <CoreFoundation/CoreFoundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
static NSUInteger _serverPort = 51000;
@interface TransferServer ()
{
    CFSocketRef _socket;
    CFSocketContext theContext;
    //int             serverPort;
    NSString*       savePath;
    NSUInteger      sizeFile;
    NSString*       saveFile;
    NSUInteger      transferID;
    //TransferServer* parentSocket;
    //NSMutableArray* childSocketList;
    TransferServer* newSocket;
    NSUInteger      receiveLength;
    int             _status;

}
@end
@implementation TransferServer
- (id)initWithPort:(NSUInteger)port
{
    self = [super init];
    if (self) {
        theContext.version = 0;
        theContext.info = (__bridge void *)(self);
        theContext.retain = nil;
        theContext.release = nil;
        theContext.copyDescription = nil;
        //parentSocket=nil;
        newSocket = nil;
        _serverPort = port;
        theRunLoopModes = [NSArray arrayWithObject:NSDefaultRunLoopMode];
        receiveLength = 0;
        _status=0;
    }
    return self;
}

- (void)setTransferID:(NSUInteger)transferid
{
    transferID = transferid;
}

- (void)setStatus:(int)status
{
    _status=status;
}

- (void)setSavePath:(NSString*)path andSize:(NSUInteger)size
{
    savePath = [[NSString alloc] initWithString:path];
    sizeFile = size;
}

- (void)setSaveFie:(NSString*)file
{
    saveFile = [[NSString  alloc] initWithString:file];
}

- (NSError *)errorFromCFStreamError:(CFStreamError)err
{
    if (err.domain == 0 && err.error == 0) return nil;
    
    // Can't use switch; these constants aren't int literals.
    NSString *domain = @"CFStreamError (unlisted domain)";
    NSString *message = nil;
    
    if(err.domain == kCFStreamErrorDomainPOSIX) {
        domain = NSPOSIXErrorDomain;
    }
    else if(err.domain == kCFStreamErrorDomainMacOSStatus) {
        domain = NSOSStatusErrorDomain;
    }
    else if(err.domain == kCFStreamErrorDomainMach) {
        domain = NSMachErrorDomain;
    }
    else if(err.domain == kCFStreamErrorDomainNetDB)
    {
        domain = @"kCFStreamErrorDomainNetDB";
        message = [NSString stringWithCString:gai_strerror(err.error) encoding:NSASCIIStringEncoding];
    }
    else if(err.domain == kCFStreamErrorDomainNetServices) {
        domain = @"kCFStreamErrorDomainNetServices";
    }
    else if(err.domain == kCFStreamErrorDomainSOCKS) {
        domain = @"kCFStreamErrorDomainSOCKS";
    }
    else if(err.domain == kCFStreamErrorDomainSystemConfiguration) {
        domain = @"kCFStreamErrorDomainSystemConfiguration";
    }
    else if(err.domain == kCFStreamErrorDomainSSL) {
        domain = @"kCFStreamErrorDomainSSL";
    }
    
    NSDictionary *info = nil;
    if(message != nil)
    {
        info = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
    }
    return [NSError errorWithDomain:domain code:err.error userInfo:info];
}

- (NSError *)getStreamError
{
    CFStreamError err;
    if (theReadStream != NULL)
    {
        err = CFReadStreamGetError (theReadStream);
        if (err.error != 0) return [self errorFromCFStreamError: err];
    }
    
    if (theWriteStream != NULL)
    {
        err = CFWriteStreamGetError (theWriteStream);
        if (err.error != 0) return [self errorFromCFStreamError: err];
    }
    
    return nil;
}

- (BOOL)createAcceptServer
{
    _socket = CFSocketCreate(
                             kCFAllocatorDefault, //内存分配类型一般为默认KCFAllocatorDefault
                             PF_INET, //协议族,一般为Ipv4:PF_INET,(Ipv6,PF_INET6)
                             SOCK_STREAM,     //套接字类型TCP:SOCK_STREAM UDP:SOCK_DGRAM
                             IPPROTO_TCP,        //套接字协议TCP:IPPROTO_TCP UDP:IPPROTO_UDP;
                             kCFSocketAcceptCallBack, //回调事件触发类型
                             //                                Enum CFSocketCallBACKType{
                             //                                    KCFSocketNoCallBack = 0,
                             //                                    KCFSocketReadCallBack =1,
                             //                                    KCFSocketAcceptCallBack = 2,(常用)
                             //                                    KCFSocketDtatCallBack = 3,
                             //                                    KCFSocketConnectCallBack = 4,
                             //                                    KCFSocketWriteCallBack = 8
                             //                                }
                             ServerAcceptCallBack,      // 触发时调用的函数
                             &theContext //  用户定义数据指针
                             );
    
    int optval = 1;
    setsockopt(CFSocketGetNative(_socket), SOL_SOCKET, SO_REUSEADDR, // 允许重用本地地址和端口
               (void *)&optval, sizeof(optval));
    
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = htons(_serverPort);
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addr4, sizeof(addr4));
    
    if (kCFSocketSuccess != CFSocketSetAddress(_socket, address)) {
        NSLog(@"Bind to address failed!");
        if (_socket)
            CFRelease(_socket);
        _socket = NULL;
        return NO;
    }
    
    CFRunLoopRef cfRunLoop = CFRunLoopGetCurrent();
    CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, 0);
    CFRunLoopAddSource(cfRunLoop, source, kCFRunLoopCommonModes);
    CFRelease(source);
    return YES;
}

- (BOOL)createStreamsFromNative:(CFSocketNativeHandle)native error:(NSError **)errPtr
{
    // Create the socket & streams.
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, native, &theReadStream, NULL);
    if (theReadStream == NULL)
    {
        NSError *err = [self getStreamError];
        
        NSLog(@"AsyncSocket %p couldn't create streams from accepted socket: %@", self, err);
        
        if (errPtr) *errPtr = err;
        return NO;
    }
    
    // Ensure the CF & BSD socket is closed when the streams are closed.
    CFReadStreamSetProperty(theReadStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    //CFWriteStreamSetProperty(theWriteStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    
    return YES;
}


- (void)doAcceptFromSocket:(CFSocketRef)parentSocket withNewNativeSocket:(CFSocketNativeHandle)newNativeSocket
{
    if(newNativeSocket)
    {
        // New socket inherits same delegate and run loop modes.
        // Note: We use [self class] to support subclassing AsyncSocket.
        newSocket = [[[self class] alloc] initWithPort:0];
        [newSocket setSavePath:savePath andSize:sizeFile];
        if (![newSocket createStreamsFromNative:newNativeSocket error:nil])
        {
            return;
        }
        /*
        
        if ([theDelegate respondsToSelector:@selector(onSocket:didAcceptNewSocket:)])
            [theDelegate onSocket:self didAcceptNewSocket:newSocket];
        
        newSocket->theFlags |= kDidStartDelegate;
        
        NSRunLoop *runLoop = nil;
        if ([theDelegate respondsToSelector:@selector(onSocket:wantsRunLoopForNewSocket:)])
        {
            runLoop = [theDelegate onSocket:self wantsRunLoopForNewSocket:newSocket];
        }
        */
        NSRunLoop *runLoop = nil;
        if(![newSocket attachStreamsToRunLoop:runLoop error:nil]) goto Failed;
        if(![newSocket configureStreamsAndReturnError:nil])       goto Failed;
        if(![newSocket openStreamsAndReturnError:nil])            goto Failed;
        
        return;
        
    Failed:
        NSLog(@"config new socket failed");
    }
}


- (void)doCFSocketCallback:(CFSocketCallBackType)type
               forSocket:(CFSocketRef)sock
             withAddress:(NSData *)address
                withData:(const void *)pData
{
#pragma unused(address)
#pragma unused(sock)
    
    switch (type)
    {
        case kCFSocketConnectCallBack:
            // The data argument is either NULL or a pointer to an SInt32 error code, if the connect failed.
//            if(pData)
//                [self doSocketOpen:sock withCFSocketError:kCFSocketError];
//            else
//                [self doSocketOpen:sock withCFSocketError:kCFSocketSuccess];
//            break;
        case kCFSocketAcceptCallBack:
            [self doAcceptFromSocket:sock withNewNativeSocket:*((CFSocketNativeHandle *)pData)];
            break;
        default:
            NSLog(@"AsyncSocket %p received unexpected CFSocketCallBackType %i", self, (int)type);
            break;
    }
}

- (void)doCFReadStreamCallback:(CFStreamEventType)type forStream:(CFReadStreamRef)stream
{
#pragma unused(stream)
    
    NSParameterAssert(theReadStream != NULL);
    
    CFStreamError err;
    switch (type)
    {
        case kCFStreamEventOpenCompleted:
            //theFlags |= kDidCompleteOpenForRead;
            //[self doStreamOpen];
            break;
        case kCFStreamEventHasBytesAvailable:
            /*if(theFlags & kStartingReadTLS) {
                [self onTLSHandshakeSuccessful];
            }
            else {
                theFlags |= kSocketHasBytesAvailable;
                [self doBytesAvailable];
            }*/
            {
                UInt8 buff[1024]={0};
                int len = (int)CFReadStreamRead(stream, buff, 1024);
                printf("received: %s", buff);
                
                CFWriteStreamWrite(theWriteStream, buff, len);
                receiveLength+=len;
                int percentage = ((float)receiveLength/sizeFile)*100;
                ProgressInfo* progInfo = [[ProgressInfo alloc] init];
                progInfo.transferID=transferID;
                progInfo.percentage=percentage;
                [self.statusDelegate transmissionProgress:progInfo];
            }
            break;
        case kCFStreamEventErrorOccurred:
            err = CFReadStreamGetError (theReadStream);
            CFWriteStreamClose(theWriteStream);
            if (_status!=1) {
                [self.statusDelegate transmissionFailed:transferID];
            }
            break;
        case kCFStreamEventEndEncountered:
            CFWriteStreamClose(theWriteStream);
            [self.statusDelegate transmissionCompleted:transferID];
            //[self closeWithError: [self errorFromCFStreamError:err]];
            
            break;
        default:
            NSLog(@"AsyncSocket %p received unexpected CFReadStream callback, CFStreamEventType %i", self, (int)type);
    }
    
}

/**
 * This is the callback we setup for CFReadStream.
 * This method does nothing but forward the call to it's Objective-C counterpart
 **/
static void MyCFReadStreamCallback (CFReadStreamRef stream, CFStreamEventType type, void *pInfo)
{
    @autoreleasepool {

        TransferServer *theSocket = (__bridge TransferServer *)pInfo;
        [theSocket doCFReadStreamCallback:type forStream:stream];
        
    }
}

- (BOOL)attachStreamsToRunLoop:(NSRunLoop *)runLoop error:(NSError **)errPtr
{
    // Get the CFRunLoop to which the socket should be attached.
    theRunLoop = (runLoop == nil) ? CFRunLoopGetCurrent() : [runLoop getCFRunLoop];
    
    // Setup read stream callbacks
    
    CFOptionFlags readStreamEvents = kCFStreamEventHasBytesAvailable |
    kCFStreamEventErrorOccurred     |
    kCFStreamEventEndEncountered    |
    kCFStreamEventOpenCompleted;
    
    if (!CFReadStreamSetClient(theReadStream,
                               readStreamEvents,
                               (CFReadStreamClientCallBack)&MyCFReadStreamCallback,
                               (CFStreamClientContext *)(&theContext)))
    {
        NSError *err = [self getStreamError];
        
        NSLog (@"AsyncSocket %p couldn't attach read stream to run-loop,", self);
        NSLog (@"Error: %@", err);
        
        if (errPtr) *errPtr = err;
        return NO;
    }
    
    // Setup write stream callbacks
    
    //CFStringRef strRef = (__bridge CFStringRef)savePath;
    //CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, strRef, NULL);
    CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                                     (CFStringRef)savePath,
                                                     kCFURLPOSIXPathStyle,
                                                     (Boolean)false);
    theWriteStream=CFWriteStreamCreateWithFile(kCFAllocatorDefault, fileURL);
    
    
    // Add read and write streams to run loop
    
    for (NSString *runLoopMode in theRunLoopModes)
    {
        CFReadStreamScheduleWithRunLoop(theReadStream, theRunLoop, (__bridge CFStringRef)runLoopMode);
        //CFWriteStreamScheduleWithRunLoop(theWriteStream, theRunLoop, (__bridge CFStringRef)runLoopMode);
    }
    
    return YES;
}

/**
 * Allows the delegate method to configure the CFReadStream and/or CFWriteStream as desired before we connect.
 *
 * If being called from a connect method,
 * the CFSocket and CFNativeSocket will not be available until after the connection is opened.
 **/
- (BOOL)configureStreamsAndReturnError:(NSError **)errPtr
{
    // Call the delegate method for further configuration.
    /*if([theDelegate respondsToSelector:@selector(onSocketWillConnect:)])
    {
        if([theDelegate onSocketWillConnect:self] == NO)
        {
            if (errPtr) *errPtr = [self getAbortError];
            return NO;
        }
    }*/
    return YES;
}

- (BOOL)openStreamsAndReturnError:(NSError **)errPtr
{
    BOOL pass = YES;
    
    if(pass && !CFReadStreamOpen(theReadStream))
    {
        NSLog (@"AsyncSocket %p couldn't open read stream,", self);
        pass = NO;
    }
    
    if(pass && !CFWriteStreamOpen(theWriteStream))
    {
        NSLog (@"AsyncSocket %p couldn't open write stream,", self);
        pass = NO;
    }
    
    if(!pass)
    {
        if (errPtr) *errPtr = [self getStreamError];
    }
    
    return pass;
}

static void ServerAcceptCallBack(       //名字可以任意取，但参数是固定的
                     CFSocketRef   socket,
                     CFSocketCallBackType callbacktype,
                     CFDataRef           inAddress,
                     const void * pData,      //与回调函数有关的特殊数据指针，对于接受连接请求事件，这个指针指向该socket的句柄，对于连接事件，则指向Sint32类型的错误代码
                     void   *pInfo)         //与套接字关联的自定义的任意数据
{
    @autoreleasepool {
        
        TransferServer *theSocket = (__bridge TransferServer *)pInfo;
        NSData *address = [(__bridge NSData *)inAddress copy];
        
        [theSocket doCFSocketCallback:callbacktype forSocket:socket withAddress:address withData:pData];
        
    }
}
- (void)runLoopUnscheduleReadStream
{
    for (NSString *runLoopMode in theRunLoopModes)
    {
        CFReadStreamUnscheduleFromRunLoop(theReadStream, theRunLoop, (__bridge CFStringRef)runLoopMode);
    }
    CFReadStreamSetClient(theReadStream, kCFStreamEventNone, NULL, NULL);
}
/*
- (void)runLoopUnscheduleWriteStream
{
    for (NSString *runLoopMode in theRunLoopModes)
    {
        CFWriteStreamUnscheduleFromRunLoop(theWriteStream, theRunLoop, (__bridge CFStringRef)runLoopMode);
    }
    CFWriteStreamSetClient(theWriteStream, kCFStreamEventNone, NULL, NULL);
}*/

- (NSString*)getServerIP
{
    NSString *address = nil;
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

+ (NSUInteger)getPort
{
    if (_serverPort>59999) {
        _serverPort=51000;
    }
    return _serverPort++;
}

- (TransferServer*)getNewSocket
{
    return newSocket;
}

- (void)cancel
{
    if (theReadStream != NULL)
    {
        [self runLoopUnscheduleReadStream];
        CFReadStreamClose(theReadStream);
        CFRelease(theReadStream);
        theReadStream = NULL;
    }
    if (theWriteStream != NULL)
    {
        //[self runLoopUnscheduleWriteStream];
        CFWriteStreamClose(theWriteStream);
        CFRelease(theWriteStream);
        theWriteStream = NULL;
    }
    
    newSocket = nil;
}

-(void)dealloc
{
    if (theReadStream != NULL)
    {
        [self runLoopUnscheduleReadStream];
        CFReadStreamClose(theReadStream);
        CFRelease(theReadStream);
        theReadStream = NULL;
    }
    if (theWriteStream != NULL)
    {
        //[self runLoopUnscheduleWriteStream];
        CFWriteStreamClose(theWriteStream);
        CFRelease(theWriteStream);
        theWriteStream = NULL;
    }

    newSocket = nil;
    
    if (_socket!=NULL) {
        CFSocketInvalidate (_socket);
        CFRelease (_socket);
        _socket = NULL;
    }
    
    savePath = nil;
    saveFile = nil;
}

@end

