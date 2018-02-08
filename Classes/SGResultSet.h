//
//  SGResultSet.h
//  SGSqlite
//
//  Created by Shangen Zhang on 2018/1/4.
//  Copyright © 2018年 Shangen Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGSqlite.h"

@interface SGResultSet : NSObject <SGResultSetProtocol>

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)resultSetWithStatement:(void *)statement;

@end
