//
//  ViewController.m
//  SGSqliteDemo
//
//  Created by Shangen Zhang on 2018/2/8.
//  Copyright © 2018年 Shangen Zhang. All rights reserved.
//

#import "ViewController.h"
#import "SGSafetySqlite.h"

#define documentPath NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject
@interface ViewController ()
/** <#des#> */
@property (nonatomic,strong) SGSafetySqlite * sqlite;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.sqlite inSqliteSync:^(SGSqlite *sqlite) {
       BOOL result = [sqlite executeUpdate:@"create table if not exists sg_test_table(sex intger,age intger,height real,name text)"];
        NSLog(@"create table result = %d",result);
        
        [[self dataSource] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [sqlite executeUpdate:@"insert or replace into sg_test_table(sex,age,height,name) values(?,?,?,?)",obj[@"sex"],obj[@"age"],obj[@"height"],obj[@"name"]];
            
        }];
    }];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.sqlite inSqliteAsync:^(SGSqlite *sqlite) {
        id <SGResultSetProtocol> rezultSet = [sqlite executeQuery:@"select * from sg_test_table where age > ?",@15];
        
        while ([rezultSet next]) {
            NSString *name = [rezultSet stringForColumn:@"name"];
            NSLog(@"AGE > 15 name = %@",name);
        }
        
        [rezultSet close];
    }];
}
- (NSArray <NSDictionary *>*)dataSource {
    
    return @[
             @{
                 @"sex"     : @0,
                 @"age"     : @12,
                 @"height"  : @168.9,
                 @"name"    : @"jack",
                 },
             @{
                 @"sex"     : @1,
                 @"age"     : @15,
                 @"height"  : @158.9,
                 @"name"    : @"rose",
                 },
             @{
                 @"sex"     : @0,
                 @"age"     : @20,
                 @"height"  : @178.9,
                 @"name"    : @"Bom",
                 },
             @{
                 @"sex"     : @1,
                 @"age"     : @19,
                 @"height"  : @166.2,
                 @"name"    : @"Alice",
                 },
             @{
                 @"sex"     : @1,
                 @"age"     : @10,
                 @"height"  : @170.9,
                 @"name"    : @"Jun",
                 },
             ];
}



- (SGSafetySqlite *)sqlite {
    if (!_sqlite) {
        NSString *dbPath = [documentPath stringByAppendingPathComponent:@"SGSqliteDemo/test.db"];
        ;
        _sqlite = [SGSafetySqlite safetySlqiteWithPath:dbPath];
    }
    return _sqlite;
}

@end
