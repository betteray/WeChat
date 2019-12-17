//
//  NewSyncService.m
//  WeChat
//
//  Created by ray on 2019/10/23.
//  Copyright © 2019 ray. All rights reserved.
//

#import "NewSyncService.h"

@implementation NewSyncService

+ (void)testOplog {
    
   // 删除好友
//    [2019-10-23 14:52:19]:[I] CLASS-ProtobufEvent METHOD-getPackData: Line-39
//    Request: <OplogRequest: 0x2820d5fb0>,
//    Path: /cgi-bin/micromsg-bin/oplog
//    Cgi: 681
//    Json: {"oplog":{"count":1,"list":[{"cmdId":2,"cmdBuf":{"iLen":85,"buffer":"<0a0c0a0a 726f7768 6f6e6777 65691205 0a037261 791a020a 0022050a 03726179 28013204 08001200 38ffffff ff0f4002 48005206 0a045261 79615a06 0a045241 59416206 0a045261 79616800 88010190 01008804 00>"}}]}}
//    SerializedData: <0a610801 125d0802 12590855 12550a0c 0a0a726f 77686f6e 67776569 12050a03 7261791a 020a0022 050a0372 61792801 32040800 120038ff ffffff0f 40024800 52060a04 52617961 5a060a04 52415941 62060a04 52617961 68008801 01900100 880400>
//
//    [2019-10-23 14:52:20]:[I] CLASS-ProtobufEvent METHOD-UnPack:SvrID:headExtFlags: Line-78
//    Response: <OplogResponse: 0x2820d5950>,
//    Path: /cgi-bin/micromsg-bin/oplog
//    Cgi: 681
//    Json: {"oplogRet":{"count":1,"ret":[0],"errMsg":[{"title":"","content":""}]},"ret":0}
//    SerializedData: <08001207 08011201 001a00>
//
//    [2019-10-23 14:52:20]:[I] CLASS-NewSyncService METHOD-InsertOplog:Oplog:Sync: Line-137 NewSyncService-InsertOplog: oplog:7, OplogData: <0a0c0a0a 726f7768 6f6e6777 6569>, Sync=true
//
//    [2019-10-23 14:52:20]:[I] CLASS-ProtobufEvent METHOD-getPackData: Line-39
//    Request: <OplogRequest: 0x2820d5890>,
//    Path: /cgi-bin/micromsg-bin/oplog
//    Cgi: 681
//    Json: {"oplog":{"count":1,"list":[{"cmdId":7,"cmdBuf":{"iLen":14,"buffer":"\n\f\n\nrowhongwei"}}]}}
//    SerializedData: <0a1a0801 12160807 1212080e 120e0a0c 0a0a726f 77686f6e 67776569>
//
//    [2019-10-23 14:52:21]:[I] CLASS-ProtobufEvent METHOD-UnPack:SvrID:headExtFlags: Line-78
//    Response: <OplogResponse: 0x2820c2a60>,
//    Path: /cgi-bin/micromsg-bin/oplog
//    Cgi: 681
//    Json: {"oplogRet":{"count":1,"ret":[0],"errMsg":[{"title":"","content":""}]},"ret":0}
//    SerializedData: <08001207 08011201 001a00>
//
    // 删除好友
//    <ModContact 0x7ffe2853d240>: {
//        userName {
//          string: "rowhongwei"
//        }
//        nickName {
//          string: "ray"
//        }
//        pyinitial {
//          string: ""
//        }
//        quanPin {
//          string: "ray"
//        }
//        sex: 1
//        imgBuf {
//          iLen: 0
//          buffer: ""
//        }
//        bitMask: 4294967295
//        bitVal: 2
//        imgFlag: 0
//        remark {
//          string: "Raya"
//        }
//        remarkPyinitial {
//          string: "RAYA"
//        }
//        remarkQuanPin {
//          string: "Raya"
//        }
//        contactType: 0
//        chatRoomNotify: 1 // 标记
//        addContactScene: 0
//        deleteContactScene: 0
//    }
//    NSData* data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DeleteContactOpLogReqest" ofType:@"bin"]];
//    OplogRequest *request = [[OplogRequest alloc] initWithData:data error:nil];
//    CmdList *cmdList = request.oplog;
//    CmdItem *cmdItem = cmdList.listArray[0];
//    ModContact *modSingleField = [[ModContact alloc] initWithData:cmdItem.cmdBuf.buffer error:nil];
//
//    LogVerbose(@"cmdID: %d, %@", cmdItem.cmdId, modSingleField);
    
    // safe
    
//    NSData* data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"oplog" ofType:@"bin"]];
//    OplogRequest *request = [[OplogRequest alloc] initWithData:data error:nil];
//    CmdList *cmdList = request.oplog;
//    CmdItem *cmdItem = cmdList.listArray[0];
//    SmcSelfMonitor *smcSelfMonitor = [[SmcSelfMonitor alloc] initWithData:cmdItem.cmdBuf.buffer error:nil];
//
//    LogVerbose(@"cmdID: %d, %@", cmdItem.cmdId, smcSelfMonitor);
    
    NSData* data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"oplog_con" ofType:@"bin"]];
    OplogRequest *request = [[OplogRequest alloc] initWithData:data error:nil];
    CmdList *cmdList = request.oplog;
    CmdItem *cmdItem = cmdList.listArray[0];
    OpLogClientCheckConsistency *ppLogClientCheckConsistency = [[OpLogClientCheckConsistency alloc] initWithData:cmdItem.cmdBuf.buffer error:nil];

    LogVerbose(@"cmdID: %d, %@", cmdItem.cmdId, ppLogClientCheckConsistency);
    
}

@end
