//
//  SGSafetySqlite.m
//  SGSqlite
//
//  Created by Shangen Zhang on 2018/1/5.
//  Copyright © 2018年 Shangen Zhang. All rights reserved.
//

#import "SGSafetySqlite.h"


@interface SGSafetySqlite ()

/** sqlite */
@property (nonatomic,strong)SGSqlite * sqlite;

/** sqlite op queue */
@property(nonatomic,strong,readonly) dispatch_queue_t safetyQueue;

@end

@implementation SGSafetySqlite

+ (instancetype)safetySlqiteWithPath:(NSString *)sqlitePath {
    return [[self alloc] initWithSqlitePath:sqlitePath];
}

- (instancetype)initWithSqlitePath:(NSString *)sqlitePath {
    
    if (sqlitePath.length == 0) {
        return nil;
    }
    if (self = [super init]) {
        [self createSqlitePath:sqlitePath];
        _sqlitePath = sqlitePath;
        NSString * safeQueueId = [NSString stringWithFormat:@"SG_safety_sqlite_squeue_%p",&self];
        _safetyQueue = dispatch_queue_create([safeQueueId UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}
- (void)createSqlitePath:(NSString *)sqlitePath {
    // 创建文件夹
    NSFileManager * defaultManager = [NSFileManager defaultManager] ;
    NSString *folderPath = [sqlitePath stringByDeletingLastPathComponent];
    if (![defaultManager fileExistsAtPath:folderPath]) {
        [defaultManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"sqlitePath directory is not exists:\n%@",folderPath);
    }
}

- (SGSqlite *)sqlite {
    if (!_sqlite) {
        _sqlite = [SGSqlite slqiteWithPath:self.sqlitePath];
        [_sqlite openSqlite];
    }
    return _sqlite;
}

- (void)close {
    if (!_sqlite) {
        return;
    }
    dispatch_sync(_safetyQueue, ^{
        // close sqlite
        [_sqlite  closeSqlite];
        _sqlite = nil;
    });
}

- (void)inSqliteSync:(SGSqliteBlock)block {
    dispatch_sync(_safetyQueue, ^{
        block(self.sqlite);
    });
}

- (void)inSqliteAsync:(SGSqliteBlock)block {
    dispatch_async(_safetyQueue, ^{
         block(self.sqlite);
    });
}

- (void)inTransactionSync:(SGTransactionBlock)block {
    dispatch_sync(_safetyQueue, ^{
        SGSqlite *sqlite = [self sqlite];
        [sqlite beginTransaction];
        BOOL rollBack = NO;
        block(sqlite,&rollBack);
        if (rollBack) {
            [sqlite rollback];
        }
        [sqlite commit];
    });
}

- (void)inTransactionAsync:(SGTransactionBlock)block {
    dispatch_async(_safetyQueue, ^{
        SGSqlite *sqlite = [self sqlite];
        [sqlite beginTransaction];
        BOOL rollBack = NO;
        block(sqlite,&rollBack);
        if (rollBack) {
            [sqlite rollback];
        }
        [sqlite commit];
    });
}

- (void)inDeferredTransactionSync:(SGTransactionBlock)block {
    dispatch_sync(_safetyQueue, ^{
        SGSqlite *sqlite = [self sqlite];
        [sqlite beginDeferredTransaction];
        BOOL rollBack = NO;
        block(sqlite,&rollBack);
        if (rollBack) {
            [sqlite rollback];
        }
        [sqlite commit];
        
    });
}

- (void)inDeferredTransactionAsync:(SGTransactionBlock)block {
    dispatch_async(_safetyQueue, ^{
        SGSqlite *sqlite = [self sqlite];
        [sqlite beginDeferredTransaction];
        BOOL rollBack = NO;
        block(sqlite,&rollBack);
        if (rollBack) {
            [sqlite rollback];
        }
        [sqlite commit];
    });
}
@end
