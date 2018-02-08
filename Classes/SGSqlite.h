//
//  LYSqlite.h
//  LYSqlite
//
//  Created by Shangen Zhang on 2018/1/4.
//  Copyright © 2018年 Shangen Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGResultSet.h"

/**
 sqlite 基本类
 */
@interface SGSqlite : NSObject
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)slqiteWithPath:(NSString *)sqlitePath;
- (instancetype)initWithSqlitePath:(NSString *)sqlitePath;

/** sqlitePath */
@property (nonatomic,copy,readonly)NSString * sqlitePath;


// 打开或关闭 sqlite
- (BOOL)openSqlite;
- (BOOL)closeSqlite;


/**
 执行sql语句

 @param sql sql语句
 @return 是否执行成功
 */
- (BOOL)executeUpdate:(NSString*)sql, ...;


/**
 查询的方法

 @param sql 查询的sql语句
 @return 查询的结果集
 */
- (SGResultSet *)executeQuery:(NSString*)sql,...;

@end



#pragma mark - 事务处理

/**
 事务处理分类
 */
@interface SGSqlite (Transaction)
// 开启事物处理
- (BOOL)beginTransaction;
- (BOOL)beginDeferredTransaction;

// 提交事物
- (BOOL)commit;

// 回滚事物
- (BOOL)rollback;

// 当前是否在处理事物
@property (nonatomic, readonly) BOOL isInTransaction;

@end
