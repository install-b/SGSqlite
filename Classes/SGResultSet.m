//
//  LYResultSet.m
//  LYSqlite
//
//  Created by Shangen Zhang on 2018/1/4.
//  Copyright © 2018年 Shangen Zhang. All rights reserved.
//

#import "SGResultSet.h"
#import <sqlite3.h>


@interface SGResultSet()
{
    // sql 结果集
    void *_pStmt;
   
}
/** 索引值 与 列行 映射 */
@property (nonatomic,strong)  NSDictionary *colunNameAndIndexMap;

@end

@implementation SGResultSet
+ (instancetype)resultSetWithStatement:(void *)statement {
    return [[self alloc] initWithStatement:statement];
}

- (instancetype)initWithStatement:(void *)statement {
    if (statement == 0x00) {
        return nil;
    }
    if (self = [super init]) {
        self->_pStmt = statement;
    }
    return self;
}

- (BOOL)next {
    if (_pStmt) {
        int rc = sqlite3_step(_pStmt);
        
        if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc) {
            
            NSLog(@"Database busy");
            
        }
        else if (SQLITE_DONE == rc || SQLITE_ROW == rc) {
            // all is well, let's return.
        }
        else if (SQLITE_ERROR == rc) {
            NSLog(@"Error calling sqlite3_step (%d) rs", rc);
            
        }
        else if (SQLITE_MISUSE == rc) {
            // uh oh.
            NSLog(@"Error calling sqlite3_step (%d) rs", rc);
        }
        else {
            // wtf?
            NSLog(@"Unknown error calling sqlite3_step (%d) rs",rc);
        }
        
        if (rc != SQLITE_ROW) {
            [self close];
        }
        
        return (rc == SQLITE_ROW);
    }
    
    return NO;
}

- (void)close {
    if (_pStmt) {
        sqlite3_reset(_pStmt);
        sqlite3_finalize(_pStmt);
        _pStmt = 0x00;
    }
}

- (void)reset {
    if (_pStmt) {
        sqlite3_reset(_pStmt);
    }
}

- (NSDictionary *)colunNameAndIndexMap {
    if (!_colunNameAndIndexMap) {
        int columnCount = sqlite3_column_count(_pStmt);
        
        if (columnCount < 1) {
            return nil;
        }
        
        NSMutableDictionary *tempDictM = [[NSMutableDictionary alloc] initWithCapacity:(NSUInteger)columnCount];
        
        for (int columnIdx = 0; columnIdx < columnCount; columnIdx++) {
            [tempDictM setObject:[NSNumber numberWithInt:columnIdx]
                          forKey:[[NSString stringWithUTF8String:sqlite3_column_name(_pStmt, columnIdx)] lowercaseString]];
        }
        _colunNameAndIndexMap = [NSDictionary dictionaryWithDictionary:tempDictM];
    }
    return _colunNameAndIndexMap;
}
- (int)columnIndexForName:(NSString*)columnName {
    columnName = [columnName lowercaseString];
    
    NSNumber *n = [[self colunNameAndIndexMap] objectForKey:columnName];
    
    if (n != nil) {
        return [n intValue];
    }
    
    NSLog(@"Warning: I could not find the column named '%@'.", columnName);
    
    return -1;
}

#pragma mark -
- (int)intForColumn:(NSString*)columnName {
    return [self intForColumnIndex:[self columnIndexForName:columnName]];
}

- (int)intForColumnIndex:(int)columnIdx {
    return sqlite3_column_int(_pStmt, columnIdx);
}

- (long)longForColumn:(NSString*)columnName {
    return [self longForColumnIndex:[self columnIndexForName:columnName]];
}

- (long)longForColumnIndex:(int)columnIdx {
    return (long)sqlite3_column_int64(_pStmt, columnIdx);
}

- (long long int)longLongIntForColumn:(NSString*)columnName {
    return [self longLongIntForColumnIndex:[self columnIndexForName:columnName]];
}

- (long long int)longLongIntForColumnIndex:(int)columnIdx {
    return sqlite3_column_int64(_pStmt, columnIdx);
}

- (unsigned long long int)unsignedLongLongIntForColumn:(NSString*)columnName {
    return [self unsignedLongLongIntForColumnIndex:[self columnIndexForName:columnName]];
}

- (unsigned long long int)unsignedLongLongIntForColumnIndex:(int)columnIdx {
    return (unsigned long long int)[self longLongIntForColumnIndex:columnIdx];
}

- (BOOL)boolForColumn:(NSString*)columnName {
    return [self boolForColumnIndex:[self columnIndexForName:columnName]];
}

- (BOOL)boolForColumnIndex:(int)columnIdx {
    return ([self intForColumnIndex:columnIdx] != 0);
}

- (double)doubleForColumn:(NSString*)columnName {
    return [self doubleForColumnIndex:[self columnIndexForName:columnName]];
}

- (double)doubleForColumnIndex:(int)columnIdx {
    return sqlite3_column_double(_pStmt, columnIdx);
}

- (NSString *)stringForColumnIndex:(int)columnIdx {
    
    if (sqlite3_column_type(_pStmt, columnIdx) == SQLITE_NULL || (columnIdx < 0) || columnIdx >= sqlite3_column_count(_pStmt)) {
        return nil;
    }
    
    const char *c = (const char *)sqlite3_column_text(_pStmt, columnIdx);
    
    if (!c) {
        // null row.
        return nil;
    }
    
    return [NSString stringWithUTF8String:c];
}

- (NSString*)stringForColumn:(NSString*)columnName {
    return [self stringForColumnIndex:[self columnIndexForName:columnName]];
}

- (NSDate*)dateForColumn:(NSString*)columnName {
    return [self dateForColumnIndex:[self columnIndexForName:columnName]];
}

- (NSDate*)dateForColumnIndex:(int)columnIdx {
    
    if (sqlite3_column_type(_pStmt, columnIdx) == SQLITE_NULL || (columnIdx < 0) || columnIdx >= sqlite3_column_count(_pStmt)) {
        return nil;
    }
    
    return [NSDate dateWithTimeIntervalSince1970:[self doubleForColumnIndex:columnIdx]];
}


- (NSData*)dataForColumn:(NSString*)columnName {
    return [self dataForColumnIndex:[self columnIndexForName:columnName]];
}

- (NSData*)dataForColumnIndex:(int)columnIdx {
    
    if (sqlite3_column_type(_pStmt, columnIdx) == SQLITE_NULL || (columnIdx < 0) || columnIdx >= sqlite3_column_count(_pStmt)) {
        return nil;
    }
    
    const char *dataBuffer = sqlite3_column_blob(_pStmt, columnIdx);
    int dataSize = sqlite3_column_bytes(_pStmt, columnIdx);
    
    if (dataBuffer == NULL) {
        return nil;
    }
    
    return [NSData dataWithBytes:(const void *)dataBuffer length:(NSUInteger)dataSize];
}


- (NSData*)dataNoCopyForColumn:(NSString*)columnName {
    return [self dataNoCopyForColumnIndex:[self columnIndexForName:columnName]];
}

- (NSData*)dataNoCopyForColumnIndex:(int)columnIdx {
    
    if (sqlite3_column_type(_pStmt, columnIdx) == SQLITE_NULL || (columnIdx < 0) || columnIdx >= sqlite3_column_count(_pStmt)) {
        return nil;
    }
    
    const char *dataBuffer = sqlite3_column_blob(_pStmt, columnIdx);
    int dataSize = sqlite3_column_bytes(_pStmt, columnIdx);
    
    NSData *data = [NSData dataWithBytesNoCopy:(void *)dataBuffer length:(NSUInteger)dataSize freeWhenDone:NO];
    
    return data;
}


- (BOOL)columnIndexIsNull:(int)columnIdx {
    return sqlite3_column_type(_pStmt, columnIdx) == SQLITE_NULL;
}

- (BOOL)columnIsNull:(NSString*)columnName {
    return [self columnIndexIsNull:[self columnIndexForName:columnName]];
}

- (const unsigned char *)UTF8StringForColumnIndex:(int)columnIdx {
    
    if (sqlite3_column_type(_pStmt, columnIdx) == SQLITE_NULL || (columnIdx < 0) || columnIdx >= sqlite3_column_count(_pStmt)) {
        return nil;
    }
    
    return sqlite3_column_text(_pStmt, columnIdx);
}

@end
