//
//  LYSafetySqlite.m
//  LYSqlite
//
//  Created by Shangen Zhang on 2018/1/5.
//  Copyright © 2018年 Shangen Zhang. All rights reserved.
//

#import "SGSafetySqlite.h"


@interface SGSafetySqlite ()
{
    LYSqlite * _sqlite;
}
/** sqlite */
@property (nonatomic,strong,readonly)LYSqlite * sqlite;
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
        _sqlitePath = sqlitePath;
        _safetyQueue = dispatch_queue_create("ly_safety_sqlite_squeue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (LYSqlite *)sqlite {
    if (!_sqlite) {
        _sqlite = [LYSqlite slqiteWithPath:self.sqlitePath];
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

- (void)inSqliteSync:(LYSqliteBlock)block {
    dispatch_sync(_safetyQueue, ^{
        block(self.sqlite);
    });
}

- (void)inSqliteAsync:(LYSqliteBlock)block {
    dispatch_async(_safetyQueue, ^{
         block(self.sqlite);
    });
}

- (void)inTransactionSync:(LYTransactionBlock)block {
    dispatch_sync(_safetyQueue, ^{
        LYSqlite *sqlite = [self sqlite];
        [sqlite beginTransaction];
        BOOL rollBack = NO;
        block(sqlite,&rollBack);
        if (rollBack) {
            [sqlite rollback];
        }
        [sqlite commit];
    });
}

- (void)inTransactionAsync:(LYTransactionBlock)block {
    dispatch_async(_safetyQueue, ^{
        LYSqlite *sqlite = [self sqlite];
        [sqlite beginTransaction];
        BOOL rollBack = NO;
        block(sqlite,&rollBack);
        if (rollBack) {
            [sqlite rollback];
        }
        [sqlite commit];
    });
}

- (void)inDeferredTransactionSync:(LYTransactionBlock)block {
    dispatch_sync(_safetyQueue, ^{
        LYSqlite *sqlite = [self sqlite];
        [sqlite beginDeferredTransaction];
        BOOL rollBack = NO;
        block(sqlite,&rollBack);
        if (rollBack) {
            [sqlite rollback];
        }
        [sqlite commit];
        
    });
}

- (void)inDeferredTransactionAsync:(LYTransactionBlock)block {
    dispatch_async(_safetyQueue, ^{
        LYSqlite *sqlite = [self sqlite];
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
