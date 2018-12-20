

//
//  DBManager.m
//  WXDemo
//
//  Created by ray on 2018/12/14.
//  Copyright © 2018 ray. All rights reserved.
//

#import "DBManager.h"
#import <FMDB.h>

#define CHECKFMDBERROR                         \
    do                                         \
    {                                          \
        NSError *lastError = [db lastError];   \
        if (lastError)                         \
        {                                      \
            LogError(@"Error: %@", lastError); \
        }                                      \
    } while (0)

@interface DBManager ()

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

@end

@implementation DBManager

+ (instancetype)sharedManager
{
    static DBManager *mgr = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc] init];
    });

    return mgr;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSURL *dbPath = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"WeChat.db"];
        _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:[dbPath path]];

        if (!_databaseQueue)
        {
            LogError(@"Could not open db.");
            return nil;
        }

        LogInfo(@"Create DB File at: %@", [dbPath path]);

        [self createTables];
    }

    return self;
}

- (BOOL)createTables
{
    NSString *sql = @"CREATE TABLE IF NOT EXISTS account_info (id INTEGER PRIMARY KEY AUTOINCREMENT, wxid TEXT, nick_name TEXT NULL, alias TEXT NULL);"
                        "CREATE TABLE IF NOT EXISTS client_check_data (id INTEGER PRIMARY KEY AUTOINCREMENT, data BLOB);"
                        "CREATE TABLE IF NOT EXISTS session_key (id INTEGER PRIMARY KEY AUTOINCREMENT, data BLOB);"
                        "CREATE TABLE IF NOT EXISTS cookie (id INTEGER PRIMARY KEY AUTOINCREMENT, data BLOB);"
                        "CREATE TABLE IF NOT EXISTS long_ip (id INTEGER PRIMARY KEY AUTOINCREMENT, ip text UNIQUE);"
                        "CREATE TABLE IF NOT EXISTS short_ip (id INTEGER PRIMARY KEY AUTOINCREMENT, ip text UNIQUE);";

    [_databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeStatements:sql];
        CHECKFMDBERROR;
    }];
    
    return YES;
}

- (BOOL)saveProfile:(ManualAuthResponse_AccountInfo *)accountInfo
{
    [_databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT wxid FROM account_info WHERE wxid = ?", accountInfo.wxId];
        
        BOOL has = NO;
        if ([resultSet next])
        {
            has = YES;
        }
        
        if (!has)
        {
            [db executeUpdate:@"INSERT INTO account_info (wxid, nick_name, alias) VALUES (?, ?, ?, ?)", accountInfo.wxId, accountInfo.nickName, accountInfo.alias];
        }
        else
        {
            [db executeUpdate:@"UPDATE account_info SET nick_name = ?, alias = ? where user_name = ?", accountInfo.nickName, accountInfo.alias, accountInfo.wxId];
        }
        
        CHECKFMDBERROR;
    }];
    
    return YES;
}

// Client Check Data
- (BOOL)saveClientCheckData:(NSData *)clientCheckData
{
    [_databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT id FROM client_check_data"];
        
        BOOL has = NO;
        if ([resultSet next])
        {
            has = YES;
        }
        
        if (!has)
        {
            [db executeUpdate:@"INSERT INTO client_check_data (data) VALUES (?)", clientCheckData];
        }
        else
        {
            [db executeUpdate:@"UPDATE client_check_data SET data = ? where id = 0", clientCheckData];
        }
        
        CHECKFMDBERROR;
    }];
    
    return YES;
}

- (NSData *)getClientCheckData
{
    __block NSData *result;
    [_databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT data FROM client_check_data"];
        if ([resultSet next])
        {
            result = [resultSet dataForColumn:@"data"];
        }
    }];
    
    return result;
}

//// Session Key
//- (BOOL)saveSessionKey:(NSData *)sessionKey
//{
//    [_databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
//        FMResultSet *resultSet = [db executeQuery:@"SELECT id FROM session_key"];
//        
//        BOOL has = NO;
//        if ([resultSet next])
//        {
//            has = YES;
//        }
//        
//        if (!has)
//        {
//            [db executeUpdate:@"INSERT INTO session_key (data) VALUES (?)", sessionKey];
//        }
//        else
//        {
//            [db executeUpdate:@"UPDATE session_key SET data = ? where id = 0", sessionKey];
//        }
//        
//        CHECKFMDBERROR;
//    }];
//    
//    return YES;
//}

//- (NSData *)getSessionKey
//{
//    __block NSData *result = nil;
//    [_databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
//        FMResultSet *resultSet = [db executeQuery:@"SELECT data FROM session_key"];
//        if ([resultSet next])
//        {
//            result = [resultSet dataForColumn:@"data"];
//            LogInfo(@"get session key: %@", result);
//        }
//    }];
//
//    return result;
//}

//// cookie
//- (BOOL)saveCookie:(NSData *)cookie
//{
//    [_databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
//        FMResultSet *resultSet = [db executeQuery:@"SELECT id FROM cookie"];
//
//        BOOL has = NO;
//        if ([resultSet next])
//        {
//            has = YES;
//        }
//
//        if (!has)
//        {
//            [db executeUpdate:@"INSERT INTO cookie (data) VALUES (?)", cookie];
//        }
//        else
//        {
//            [db executeUpdate:@"UPDATE cookie SET data = ? where id = 0", cookie];
//        }
//
//        CHECKFMDBERROR;
//    }];
//
//    return YES;
//}
//
//- (NSData *)getCookie
//{
//    __block NSData *result = nil;
//    [_databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
//        FMResultSet *resultSet = [db executeQuery:@"SELECT data FROM cookie"];
//        if ([resultSet next])
//        {
//            result = [resultSet dataForColumn:@"data"];
//        }
//    }];
//
//    return result;
//}

// Short Ip
- (BOOL)saveShortIpList:(NSArray *)ipList
{
    [_databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        for (NSString *ip in ipList) {
            FMResultSet *resultSet = [db executeQuery:@"SELECT ip FROM short_ip where ip = ?", ip];
            
            BOOL has = NO;
            if ([resultSet next])
            {
                has = YES;
            }
            
            if (!has) {
                [db executeUpdate:@"INSERT INTO short_ip (ip) VALUES (?)", ip];
            }
        }
        
        CHECKFMDBERROR;
    }];
    
    return YES;
}

- (NSArray *)getShortIpList
{
    __block NSArray *result = nil;
    [_databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSMutableArray *ipList = [NSMutableArray array];
        FMResultSet *resultSet = [db executeQuery:@"SELECT ip FROM short_ip"];
        while ([resultSet next])
        {
            [ipList addObject:[resultSet stringForColumn:@"ip"]];
        }
        
        result = [ipList copy];
    }];
    
    
    return result;
}

// Long Ip
- (BOOL)saveLongIpList:(NSArray *)ipList
{
    [_databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        for (NSString *ip in ipList) {
            FMResultSet *resultSet = [db executeQuery:@"SELECT ip FROM long_ip where ip = ?", ip];
            
            BOOL has = NO;
            if ([resultSet next])
            {
                has = YES;
            }
            
            if (!has) {
                [db executeUpdate:@"INSERT INTO long_ip (ip) VALUES (?)", ip];
            }
        }
        
        CHECKFMDBERROR;
    }];
    
    return YES;
}

- (NSArray *)getLongIpList
{
    __block NSArray *result = nil;
    [_databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSMutableArray *ipList = [NSMutableArray array];
        FMResultSet *resultSet = [db executeQuery:@"SELECT ip FROM long_ip"];
        while ([resultSet next])
        {
            [ipList addObject:[resultSet stringForColumn:@"ip"]];
        }
        
        result = [ipList copy];
    }];
    
    
    return result;
}

@end
