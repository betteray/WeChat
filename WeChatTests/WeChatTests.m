//
//  WeChatTests.m
//  WeChatTests
//
//  Created by ysh on 2019/1/24.
//  Copyright © 2019 ray. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Mm.pbobjc.h"
#import "NSData+Util.h"
#include <sys/time.h>

#define _BYTE  uint8
#define _WORD  uint16
#define _DWORD uint32_t
#define _QWORD uint64

#define LOBYTE(x)   (*((_BYTE*)&(x)))   // low byte
#define LOWORD(x)   (*((_WORD*)&(x)))   // low word
#define LODWORD(x)  (*((_DWORD*)&(x)))  // low dword

@interface WeChatTests : XCTestCase

@end

@implementation WeChatTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
//    NSData *data = [NSData dataWithHexString:@"10021A040800120022020A002A020A0032020A003A92010A8F0168747470733A2F2F737570706F72742E77656978696E2E71712E636F6D2F6367692D62696E2F6D6D737570706F72742D62696E2F61646463686174726F6F6D6279696E766974653F7469636B65743D4133595A44797A7A3852577931387A7667636E6A4F772533442533442666726F6D3D73696E676C656D657373616765266973617070696E7374616C6C65643D3050015A13777869645F70793270737532716C797666323262006A00700078648A010457494649A00194DDB2F307AA0100B00100"];
//    NSError *error = nil;
//    GetA8KeyReq *req = [[GetA8KeyReq alloc] initWithData:data error:&error];
//    NSLog(@"%@", req);
    
    struct timeval tv;
    gettimeofday(&tv, NULL);
    NSInteger reqeustID = ((274877907LL * tv.tv_usec >> 38) + ((274877907LL * tv.tv_usec) >> 63) + 1000 * LODWORD(tv.tv_sec));
    
    NSLog(@"%ld", reqeustID);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
