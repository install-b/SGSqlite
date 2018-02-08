//
//  LYResultSet.h
//  LYSqlite
//
//  Created by Shangen Zhang on 2018/1/4.
//  Copyright © 2018年 Shangen Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGResultSet : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)resultSetWithStatement:(void *)statement;

- (BOOL)next;

- (void)close;

- (void)reset;


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
