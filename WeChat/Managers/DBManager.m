

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
        NSError *lastError = [_db lastError];  \
        if (lastError)                         \
        {                                      \
            LogError(@"Error: %@", lastError); \
            return NO;                         \
        }                                      \
        else                                   \
        {                                      \
            return YES;                        \
        }                                      \
    } while (0)

@interface DBManager ()

@property (nonatomic, strong, readonly) FMDatabase *db;

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
        _db = [FMDatabase databaseWithPath:[dbPath path]];

        if (![_db open])
        {
            LogError(@"WXHooks: Could not open db.");
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
                        "CREATE TABLE IF NOT EXISTS long_ip (id INTEGER PRIMARY KEY AUTOINCREMENT, ip text UNIQUE);"
                        "CREATE TABLE IF NOT EXISTS short_ip (id INTEGER PRIMARY KEY AUTOINCREMENT, ip text UNIQUE);";

    [_db executeStatements:sql];
    
    CHECKFMDBERROR;
}

- (BOOL)saveProfile:(ManualAuthResponse_AccountInfo *)accountInfo
{
    FMResultSet *resultSet = [_db executeQuery:@"SELECT wxid FROM account_info WHERE wxid = ?", accountInfo.wxId];

    BOOL has = NO;
    if ([resultSet next])
    {
        has = YES;
    }

    if (!has)
    {
        [_db executeUpdate:@"INSERT INTO account_info (wxid, nick_name, alias) VALUES (?, ?, ?, ?)", accountInfo.wxId, accountInfo.nickName, accountInfo.alias];
    }
    else
    {
        [_db executeUpdate:@"UPDATE account_info SET nick_name = ?, alias = ? where user_name = ?", accountInfo.nickName, accountInfo.alias, accountInfo.wxId];
    }

    CHECKFMDBERROR;
}

// Client Check Data
- (BOOL)saveClientCheckData:(NSData *)clientCheckData
{
    FMResultSet *resultSet = [_db executeQuery:@"SELECT id FROM client_check_data"];

    BOOL has = NO;
    if ([resultSet next])
    {
        has = YES;
    }

    if (!has)
    {
        [_db executeUpdate:@"INSERT INTO client_check_data (data) VALUES (?)", clientCheckData];
    }
    else
    {
        [_db executeUpdate:@"UPDATE client_check_data SET data = ? where id = 0", clientCheckData];
    }

    CHECKFMDBERROR;
}

- (NSData *)getClientCheckData
{
    FMResultSet *resultSet = [_db executeQuery:@"SELECT data FROM client_check_data"];
    if ([resultSet next])
    {
        return [resultSet dataForColumn:@"data"];
    }
    else
    {
        return nil;
    }
}

// Session Key
- (BOOL)saveSessionKey:(NSData *)sessionKey
{
    FMResultSet *resultSet = [_db executeQuery:@"SELECT id FROM session_key"];
    
    BOOL has = NO;
    if ([resultSet next])
    {
        has = YES;
    }
    
    if (!has)
    {
        [_db executeUpdate:@"INSERT INTO session_key (data) VALUES (?)", sessionKey];
    }
    else
    {
        [_db executeUpdate:@"UPDATE session_key SET data = ? where id = 0", sessionKey];
    }
    
    CHECKFMDBERROR;
}

- (NSData *)getSessionKey
{
    FMResultSet *resultSet = [_db executeQuery:@"SELECT data FROM session_key"];
    if ([resultSet next])
    {
        return [resultSet dataForColumn:@"data"];
    }
    else
    {
        return nil;
    }
}

// Short Ip
- (BOOL)saveShortIpList:(NSArray *)ipList
{
    for (NSString *ip in ipList) {
        FMResultSet *resultSet = [_db executeQuery:@"SELECT ip FROM short_ip where ip = ?", ip];
        
        BOOL has = NO;
        if ([resultSet next])
        {
            has = YES;
        }
        
        if (!has) {
            [_db executeUpdate:@"INSERT INTO short_ip (ip) VALUES (?)", ip];
        }
    }
    
    CHECKFMDBERROR;
}

- (NSArray *)getShortIpList
{
    NSMutableArray *ipList = [NSMutableArray array];
    FMResultSet *resultSet = [_db executeQuery:@"SELECT ip FROM short_ip"];
    while ([resultSet next])
    {
        [ipList addObject:[resultSet stringForColumn:@"ip"]];
    }
    
    return [ipList copy];
}

// Long Ip
- (BOOL)saveLongIpList:(NSArray *)ipList
{
    for (NSString *ip in ipList) {
        FMResultSet *resultSet = [_db executeQuery:@"SELECT ip FROM long_ip where ip = ?", ip];
        
        BOOL has = NO;
        if ([resultSet next])
        {
            has = YES;
        }
        
        if (!has) {
            [_db executeUpdate:@"INSERT INTO long_ip (ip) VALUES (?)", ip];
        }
    }
    
    CHECKFMDBERROR;
}

- (NSArray *)getLongIpList
{
    NSMutableArray *ipList = [NSMutableArray array];
    FMResultSet *resultSet = [_db executeQuery:@"SELECT ip FROM long_ip"];
    while ([resultSet next])
    {
        [ipList addObject:[resultSet stringForColumn:@"ip"]];
    }
    
    return [ipList copy];
}

@end
