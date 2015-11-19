//
//  SongItem.h
//  zxqservice
//
//  Created by nigel on 15/10/19.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SongItem : NSObject
- (id)initSongItem:(NSString*)url;
- (id)initSongItem:(NSString*)url andID:(long)ID;
- (id)initSongItem:(NSString*)url andID:(long)ID Type:(int)type;
- (NSString*)url;
- (NSString*)path;
- (long)getId;
- (int)source;
- (int)type;
@end
