//
//  SongItem.m
//  zxqservice
//
//  Created by nigel on 15/10/19.
//  Copyright (c) 2015年 nigel. All rights reserved.
//

#import "SongItem.h"
const int SINGLE_SONG = 1;
const int SELECTION = 2;
const int SINGER = 3;
const int SPECIAL = 4;
@interface SongItem ()
{
    @private
    NSString* mUrl;
    NSString* mPath;
    long mId;
    int mSource;
    int mType;
}

@end

@implementation SongItem
- (id)initSongItem:(NSString*)url
{
    self = [super init];
    if (self) {
        mUrl = url;
        mPath = @"";
        mId = 0;
        mSource = 0;
        mType = SINGLE_SONG;
    }
    return self;
}

- (id)initSongItem:(NSString*)url andID:(long)ID
{
    self = [super init];
    if (self) {
        mUrl = url;
        mPath = @"";
        mId = ID;
        mSource = 1;
    }
    return self;
}

- (id)initSongItem:(NSString*)url andID:(long)ID Type:(int)type
{
    self = [super init];
    if (self) {
        mUrl = url;
        mPath = @"";
        mId = ID;
        mSource = 1;
        mType = type;
    }
    return self;
}

- (NSString*)url{
    return mUrl;
}

- (NSString*)path{
    return mPath;
}

- (long)getId{
    return mId;
}

- (int)source{
    return mSource;
}

- (int)type{
    return mType;
}
@end
