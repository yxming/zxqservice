//
//  zxqservice.h
//  zxqservice
//
//  Created by nigel on 15/9/14.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModleInfo.h"

#pragma mark -
#pragma mark ZxqServiceDelegate
/**
 *  the interface of ZxqService event callback
 */
@protocol ZxqServiceDelegate<NSObject>
@optional
/**
 *  phone connect to car service
 *
 *  @param connected indicate whether connected car service
 */
- (void)carHasConnected:(BOOL)connected;

/**
 *  phone has lose connect with car
 */
- (void)carHasDisconnect;
@required
/**
 *  receive transmission request from car
 *
 *  @param file     the name of transfer file
 *  @param len      transfer file length
 *  @param componentid  identify the sender who is request caller
 *  @param index    transmission indicate
 */
- (void)transmissionRequested:(NSString*)file length:(NSUInteger)len
                  componentID:(NSUInteger)componentid
                   transferID:(NSUInteger)transferid;

/**
 *  transmission interrupted by some unexpected accident
 *
 *  @param transferID     the name of transfer file
 */
- (void)transmissionInterrupted:(NSUInteger)transferID;

/**
 *  transmission option has canceled by car side will call back for this mothed
 *
 *  @param transferID transferID description
 */
- (void)transmissionCancelled:(NSUInteger)transferID;

/**
 *  indicate whether the car side is willing to receive the file
 *
 *  @param accepted indecate whether car receive file
 *  @param file     the name of transfer file
 */
- (void)transmissionAccepted:(BOOL)accepted transferID:(NSUInteger)transferid;

/**
 *  indicate transmission was Completed
 *  @param file     the name of transfer file
 */
- (void)transmissionCompleted:(NSUInteger)transferID;

/**
 *  <#Description#>
 *
 *  @param progressInfo include transsmion id and percentage value
 */
- (void)transmissionPercent:(ProgressInfo*)progressInfo;
@end

#pragma mark -
#pragma mark ZxqService
/**
 *  provider ZXQ information share to car services
 */
@interface ZxqService : NSObject <NetWorkDelegate,TransferStateDelegate>
/**
 *  service delegate call back for caller
 */
@property(strong,nonatomic)id<ZxqServiceDelegate> zxqServiceDelegate;
/**
 *  connect car server prepare to interconnection serivce
 *
 *  @param phone   phone description
 *  @param version version description
 */
- (void)connectToCarWithPhoneName:(NSString*)phone;

/**
 *  disconnect server of nterconnection serivce
 */
- (void)disconnectFromCar;

/**
 *  <#Description#>
 *
 *  @param transferID an indentify id of the file transmission
 *
 *  @return return value transmission file name
 */
- (NSString*)getTransMissionFileWith:(NSUInteger)transferID;

/**
 *  obtain connect car's identifier
 *
 *  @return return value is current connect car's identifier
 */
- (NSString*)getConnectedCar;

/**
 *  register application component id to car
 *
 *  @param componentID application indentify use for car
 */
- (void)registerComponent:(NSUInteger)componentID;


/**
 *  unregister application component id from car
 */
- (void)unregisterComponent;

/**
 *  send custom data to car
 *
 *  @param msg the custom data of application send to car side
 *  @param componentID  the id indicate receiver who will receive message in car side
 */
- (void)sendMessageToCar:(NSString*)msg withTargetComponentID:(NSUInteger)componentID;

/**
 *  request file transmission
 *
 *  @param file     the name of transfer file
 *  @param componentID  the id indicate receiver who will receive file in car side
 */
- (void)sendFileToCar:(NSString*)filePath withTargetComponentID:(NSUInteger)componentID attachInfo:(NSString*)attachInfo;

/**
 *  indicate whether accept transmission
 *
 *  @param transferID transmission id
 *  @param accept     1: accept 0:reject
 *  @param accept
 */
- (BOOL)acceptFileWithTransferID:(NSUInteger)transferID IsAccept:(short)accept savePath:(NSString*)filePath;

/**
 *  interrupt transmission
 *
 *  @param transferID transmission id
 */
- (void)cancelTansfer:(NSUInteger)transferID;

/**
 *  xiaming special interface deal with xiaming music business
 *
 *  @param songArray song information
 */
- (void)shareMusicList:(NSArray*)songArray;

@end
