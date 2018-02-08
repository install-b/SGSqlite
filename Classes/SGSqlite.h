//
//  LYSqlite.h
//  LYSqlite
//
//  Created by Shangen Zhang on 2018/1/4.
//  Copyright © 2018年 Shangen Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGResultSet.h"

@interface SGSqlite : NSObject
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)slqiteWithPath:(NSString *)sqlitePath;
- (instancetype)initWithSqlitePath:(NSString *)sqlitePath;

/** sqlitePath */
@property (nonatomic,copy,readonly)NSString * sqlitePath;



- (BOOL)openSqlite;
- (BOOL)closeSqlite;


- (BOOL)executeUpdate:(NSString*)sql, ...;

- (SGResultSet *)executeQuery:(NSString*)sql, ...;

@end



#pragma mark - 事务处理
@interface SGSqlite (Transaction)

- (BOOL)beginTransaction;

- (BOOL)beginDeferredTransaction;

- (BOOL)commit;

- (BOOL)rollback;

@property (nonatomic, readonly) BOOL isInTransaction;

@end
