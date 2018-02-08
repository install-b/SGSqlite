//
//  SGSafetySqlite.h
//  SGSqlite
//
//  Created by Shangen Zhang on 2018/1/5.
//  Copyright © 2018年 Shangen Zhang. All rights reserved.
//


#import "SGSqlite.h"

// 安全操作的block 回调 define
typedef void(^SGSqliteBlock)(SGSqlite *sqlite);
typedef void(^SGTransactionBlock)(SGSqlite *sqlite, BOOL *rollback);

/**
 线程安全的数据库对象
 */
@interface SGSafetySqlite : NSObject
/**
 构造方法
 */
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)safetySlqiteWithPath:(NSString *)sqlitePath;
- (instancetype)initWithSqlitePath:(NSString *)sqlitePath;

/** sqlitePath */
@property (nonatomic,readonly)NSString * sqlitePath;

// 关闭数据库
- (void)close;

/**
 同步操作
 */
- (void)inSqliteSync:(SGSqliteBlock)block;
- (void)inTransactionSync:(SGTransactionBlock)block;
- (void)inDeferredTransactionSync:(SGTransactionBlock)block;

/**
 异步操作
 */
- (void)inSqliteAsync:(SGSqliteBlock)block;
- (void)inTransactionAsync:(SGTransactionBlock)block;
- (void)inDeferredTransactionAsync:(SGTransactionBlock)block;

@end
