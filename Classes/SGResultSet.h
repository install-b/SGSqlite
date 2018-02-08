//
//  SGResultSet.h
//  SGSqlite
//
//  Created by Shangen Zhang on 2018/1/4.
//  Copyright © 2018年 Shangen Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 查询结果集对象 协议
 */
@protocol SGResultSetProtocol <NSObject>
// 查询游标
- (BOOL)next;

// 关闭结果集 结束查询的时候一定要关闭结果集
- (void)close;

// 结果集 重置
- (void)reset;

/**
 查询相对应的类型结果  必须先调用 <- next> 方法
 */
- (int)intForColumn:(NSString*)columnName;
- (long)longForColumn:(NSString*)columnName;
- (long long int)longLongIntForColumn:(NSString*)columnName;
- (unsigned long long int)unsignedLongLongIntForColumn:(NSString*)columnName;
- (BOOL)boolForColumn:(NSString*)columnName;
- (double)doubleForColumn:(NSString*)columnName;
- (NSString*)stringForColumn:(NSString*)columnName;
- (NSDate*)dateForColumn:(NSString*)columnName;
- (NSData*)dataForColumn:(NSString*)columnName;

@end


@interface SGResultSet : NSObject <SGResultSetProtocol>

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)resultSetWithStatement:(void *)statement;

@end
