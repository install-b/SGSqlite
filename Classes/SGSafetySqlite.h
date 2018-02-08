//
//  LYSafetySqlite.h
//  LYSqlite
//
//  Created by Shangen Zhang on 2018/1/5.
//  Copyright © 2018年 Shangen Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGSqlite.h"



typedef void(^LYSqliteBlock)(LYSqlite *sqlite);
typedef void(^LYTransactionBlock)(LYSqlite *sqlite, BOOL *rollback);

@interface SGSafetySqlite : NSObject
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)safetySlqiteWithPath:(NSString *)sqlitePath;
- (instancetype)initWithSqlitePath:(NSString *)sqlitePath;

/** sqlitePath */
@property (nonatomic,readonly)NSString * sqlitePath;


- (void)close;


- (void)inSqliteSync:(LYSqliteBlock)block;

- (void)inTransactionSync:(LYTransactionBlock)block;

- (void)inDeferredTransactionSync:(LYTransactionBlock)block;

- (void)inSqliteAsync:(LYSqliteBlock)block;

- (void)inTransactionAsync:(LYTransactionBlock)block;

- (void)inDeferredTransactionAsync:(LYTransactionBlock)block;

@end
