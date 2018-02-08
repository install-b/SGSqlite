//
//  LYSqlite.m
//  LYSqlite
//
//  Created by Shangen Zhang on 2018/1/4.
//  Copyright © 2018年 Shangen Zhang. All rights reserved.
//

#import "SGSqlite.h"
#import <sqlite3.h>


// 拼接参数 函数
static int sqlite_bindObject(id obj,int idx,sqlite3_stmt * pStmt) {
    
    // 插入空值
    if ((!obj) || ((NSNull *)obj == [NSNull null])) {
        return sqlite3_bind_null(pStmt, idx);
    }
    
    // 插入二进制
    if ([obj isKindOfClass:[NSData class]]) {
        const void *bytes = [obj bytes];
        if (!bytes) {
            // it's an empty NSData object, aka [NSData data].
            // Don't pass a NULL pointer, or sqlite will bind a SQL null instead of a blob.
            bytes = "";
        }
        return sqlite3_bind_blob(pStmt, idx, bytes, (int)[obj length], SQLITE_STATIC);
    }
    
    // 插入时间
    if ([obj isKindOfClass:[NSDate class]]) {
        return sqlite3_bind_double(pStmt, idx, [obj timeIntervalSince1970]);
    }
    
    
    // 插入数字类型
    if ([obj isKindOfClass:[NSNumber class]]) {
        
        if (strcmp([obj objCType], @encode(char)) == 0) {
            return sqlite3_bind_int(pStmt, idx, [obj charValue]);
        }
        
        if (strcmp([obj objCType], @encode(unsigned char)) == 0) {
            return sqlite3_bind_int(pStmt, idx, [obj unsignedCharValue]);
        }
        
        if (strcmp([obj objCType], @encode(short)) == 0) {
            return sqlite3_bind_int(pStmt, idx, [obj shortValue]);
        }
        
        if (strcmp([obj objCType], @encode(unsigned short)) == 0) {
            return sqlite3_bind_int(pStmt, idx, [obj unsignedShortValue]);
        }
        
        if (strcmp([obj objCType], @encode(int)) == 0) {
            return sqlite3_bind_int(pStmt, idx, [obj intValue]);
        }
        
        if (strcmp([obj objCType], @encode(unsigned int)) == 0) {
            return sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedIntValue]);
        }
        
        if (strcmp([obj objCType], @encode(long)) == 0) {
            return sqlite3_bind_int64(pStmt, idx, [obj longValue]);
        }
        
        if (strcmp([obj objCType], @encode(unsigned long)) == 0) {
            return sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedLongValue]);
        }
        
        if (strcmp([obj objCType], @encode(long long)) == 0) {
            return sqlite3_bind_int64(pStmt, idx, [obj longLongValue]);
        }
       
        if (strcmp([obj objCType], @encode(unsigned long long)) == 0) {
            return sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedLongLongValue]);
        }
        
        if (strcmp([obj objCType], @encode(float)) == 0) {
            return sqlite3_bind_double(pStmt, idx, [obj floatValue]);
        }
        
        if (strcmp([obj objCType], @encode(double)) == 0) {
            return sqlite3_bind_double(pStmt, idx, [obj doubleValue]);
        }
        
        if (strcmp([obj objCType], @encode(BOOL)) == 0) {
            return sqlite3_bind_int(pStmt, idx, ([obj boolValue] ? 1 : 0));
        }
        
        // 都不满足 插入文本
        return sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
    }
    
    // 插入文本
    return sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
    
}





@interface SGSqlite ()
{
    void * _sqliteDB;
    BOOL  _isInTransaction;
}

@end


@implementation SGSqlite
#pragma mark -
+ (instancetype)slqiteWithPath:(NSString *)sqlitePath {
    return [[self alloc] initWithSqlitePath:sqlitePath];
}

- (instancetype)initWithSqlitePath:(NSString *)sqlitePath {
    if (self = [super init]) {
        _sqliteDB = 0x00;
        _sqlitePath = sqlitePath;
    }
    return self;
}

#pragma mark - create and close
- (BOOL)openSqlite {
    if (_sqliteDB) {
        return YES;
    }
    int err = sqlite3_open([self p_csqlitePath], (sqlite3**)&_sqliteDB);
    if(err != SQLITE_OK) {
        NSLog(@"error opening!: %d", err);
        return NO;
    }
    return YES;
}

- (BOOL)closeSqlite {
    if (!_sqliteDB) {
        return YES;
    }
    
    int  rc;
    BOOL retry;
    BOOL triedFinalizingOpenStatements = NO;
    
    do {
        retry   = NO;
        rc      = sqlite3_close(_sqliteDB);
        if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc) {
            if (!triedFinalizingOpenStatements) {
                triedFinalizingOpenStatements = YES;
                sqlite3_stmt *pStmt;
                while ((pStmt = sqlite3_next_stmt(_sqliteDB, nil)) != 0) {
                    NSLog(@"Closing leaked statement");
                    sqlite3_finalize(pStmt);
                    retry = YES;
                }
            }
        }
        else if (SQLITE_OK != rc) {
            NSLog(@"error closing!: %d", rc);
        }
    }
    while (retry);
    
    _sqliteDB = nil;
    return YES;
}

- (const char *)p_csqlitePath {
    if (!_sqlitePath) {
        return ":memory:";
    }
    
    if ([_sqlitePath length] == 0) {
        return "";
    }
    
    return [_sqlitePath fileSystemRepresentation];
}

#pragma mark - update
- (BOOL)executeUpdate:(NSString *)sql, ... {
    if (!_sqliteDB) {
        NSLog(@"executeUpdate- _sqliteDB = nil");
        return NO;
    }
    
    int rc                   = 0x00;
    sqlite3_stmt *pStmt      = 0x00;
    
    rc = sqlite3_prepare_v2(_sqliteDB, [sql UTF8String], -1, &pStmt, 0);
    
    if (SQLITE_OK != rc) {
        sqlite3_finalize(pStmt);
        NSLog(@"executeUpdate- sqlite3_prepare_v2 ERROR:RC=%d \nsql:%@",rc,sql);
        return NO;
    }
    
    
    int queryCount = sqlite3_bind_parameter_count(pStmt);
    
    id obj;
    int idx = 0;
    
    va_list args;
    va_start(args, sql);
    while (idx < queryCount) {
        obj = va_arg(args, id);
        // 拼接 参数
        sqlite_bindObject(obj, idx, pStmt);
        
        idx++;
    }
    va_end(args);


    if (idx != queryCount) {
        // 参数错误
        NSLog(@"executeUpdate- Error: the bind count (%d) is not correct for the # of variables in the query (%d) (%@) (executeUpdate)", idx, queryCount, sql);
        
        sqlite3_finalize(pStmt);
       
        return NO;
    }

    rc      = sqlite3_step(pStmt);
    
    if (rc != SQLITE_DONE && rc != SQLITE_OK) {
        NSLog(@"executeUpdate- SQL error:%@\nrc:%d",sql,rc);
        return NO;
    }
    return YES;
}


#pragma mark - queury
- (id)executeQuery:(NSString *)sql, ... {
    
    if (!_sqliteDB) {
        return 0x00;
    }
   
    int rc                  = 0x00;
    sqlite3_stmt *pStmt     = 0x00;
    
    
    rc = sqlite3_prepare_v2(_sqliteDB, [sql UTF8String], -1, &pStmt, 0);
    
    if (SQLITE_OK != rc) {
        NSLog(@"ERROR CODE:%i  sql:%@",rc,sql);
        sqlite3_finalize(pStmt);
        
        return nil;
    }
    
    
    id obj;
    int idx = 0;
    int queryCount = sqlite3_bind_parameter_count(pStmt);
    
  
    va_list args;
    va_start(args, sql);
    while (idx < queryCount) {
        // 取值
        obj = va_arg(args, id);
        // 拼接 参数
        sqlite_bindObject(obj, idx, pStmt);
        // 索引值+1
        idx++;
    }
    va_end(args);
    
    if (idx != queryCount) {
        NSLog(@"Error: the bind count is not correct for the # of variables (executeQuery)");
        sqlite3_finalize(pStmt);
        return nil;
    }
    
    return [SGResultSet resultSetWithStatement:pStmt];
}
@end




@implementation SGSqlite (Transaction)
#pragma mark Transactions

- (BOOL)rollback {
    BOOL b = [self executeUpdate:@"rollback transaction"];
    
    if (b) {
        _isInTransaction = NO;
    }
    
    return b;
}

- (BOOL)commit {
    BOOL b =  [self executeUpdate:@"commit transaction"];
    
    if (b) {
        _isInTransaction = NO;
    }
    
    return b;
}

- (BOOL)beginDeferredTransaction {
    
    BOOL b = [self executeUpdate:@"begin deferred transaction"];
    if (b) {
        _isInTransaction = YES;
    }
    
    return b;
}

- (BOOL)beginTransaction {
    
    BOOL b = [self executeUpdate:@"begin exclusive transaction"];
    if (b) {
        _isInTransaction = YES;
    }
    
    return b;
}

- (BOOL)isInTransaction {
    return _isInTransaction;
}

@end;

