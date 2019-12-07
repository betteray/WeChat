//
//  SyncCmdHandler.m
//  WeChat
//
//  Created by ysh on 2019/1/2.
//  Copyright © 2019 ray. All rights reserved.
//

#import "SyncCmdHandler.h"
#import "WCContact.h"
#import "WCMessage.h"
#import "WCSafeSDK.h"

@implementation SyncCmdHandler

+ (void)parseCmdList:(NSArray<CmdItem *> *)cmdList
{
    for (int i = 0; i < cmdList.count; i++)
    {
        CmdItem *cmdItem = [cmdList objectAtIndex:i];
        if (5 == cmdItem.cmdId)
        {
            AddMsg *msg = [[AddMsg alloc] initWithData:cmdItem.cmdBuf.buffer error:nil];
            BOOL isSystemMsg = 10002 == msg.msgType || 9999 == msg.msgType;
            NSString *logPrefix = isSystemMsg ? @"[系统消息]:" : @"[普通消息]:";
            LogVerbose(@"%@ msgId: %d, createTime: %d, fromUserName: %@, toUserName: %@, msgType: %d, content: %@",
                       logPrefix,
                       msg.msgId,
                       msg.createTime,
                       msg.fromUserName.string,
                       msg.toUserName.string,
                       msg.msgType,
                       msg.content.string);
            
            
            //msg content : <sysmsg type="ClientCheckGetExtInfo"><ClientCheckGetExtInfo><ReportContext>539033600</ReportContext><Basic>0</Basic></ClientCheckGetExtInfo></sysmsg>
            // basic != 0时，上报的消息不一样，比较简单
//            if (str != null && str.equals("ClientCheckGetExtInfo")) {
//                final Map<String, String> map2 = map;
//                com.tencent.mm.sdk.g.d.g(new Runnable() {
//                    public final void run() {
//                        AppMethodBeat.i(16264);
//                        int i = bo.getInt((String) map2.get(".sysmsg.ClientCheckGetExtInfo.ReportContext"), 0);
//                        if (bo.getInt((String) map2.get(".sysmsg.ClientCheckGetExtInfo.Basic"), 0) != 0) {
//                            com.tencent.mm.plugin.secinforeport.a.d.roA.fI(i, 0);
//                            AppMethodBeat.o(16264);
//                            return;
//                        }
//                        com.tencent.mm.plugin.secinforeport.a.d.roA.fI(i, 15);
//                        AppMethodBeat.o(16264);
//                    }
//                }, "syscmd_rpt_cc");
//            }
            NSString *xmlMsg = msg.content.string;
            if (isSystemMsg && [xmlMsg containsString:@"ClientCheckGetExtInfo"]) {
                NSRange range1 = [xmlMsg rangeOfString:@"<ReportContext>"];
                NSString *reportContent = [xmlMsg substringFromIndex:( range1.location + range1.length )];
                NSRange range2 = [reportContent rangeOfString:@"</ReportContext>"];
                reportContent = [reportContent substringToIndex:range2.location];
                
                uint32_t rptContext = (uint32_t) [reportContent integerValue];
                [WCSafeSDK reportClientCheckWithContext:rptContext basic:YES];
            }
            
            WCContact *fromUser = [[WCContact objectsWhere:@"userName = %@", msg.fromUserName.string] firstObject];
            WCContact *toUser = [[WCContact objectsWhere:@"userName = %@", msg.toUserName.string] firstObject];

            if (fromUser && toUser) {
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                [WCMessage createOrUpdateInDefaultRealmWithValue:@[@(msg.newMsgId),
                                                                   fromUser,
                                                                   toUser,
                                                                   @(msg.msgType),
                                                                   msg.content.string,
                                                                   @(msg.createTime)]];
                [realm commitWriteTransaction];
            }
            else
            {
                LogError(@"Can not find contact with username: %@", msg.fromUserName.string);
                LogError(@"But the content is: %@", msg.content.string);
            }
            
        }
        else if (2 == cmdItem.cmdId) //好友列表 ModContact
        {
            ModContact *modContact = [[ModContact alloc] initWithData:cmdItem.cmdBuf.buffer error:nil];
            LogVerbose(@"Mod Contact: %@", modContact);

            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            [WCContact createOrUpdateInDefaultRealmWithValue:@[modContact.userName.string,
                                                               modContact.nickName.string,
                                                               modContact.province,
                                                               modContact.city,
                                                               modContact.signature,
                                                               modContact.alias,
                                                               modContact.bigHeadImgURL,
                                                               modContact.smallHeadImgURL]];
            [realm commitWriteTransaction];
        }
        
        //4 DelContact
        
        //53 NewDelMsg
        //33 ModBottleContact
        //35 ModUserImg
        //15 ModChatRoomMember
        //16 20 21 deprecated cmd
        //17 18 19 22
        //23 FunctionSwitch
        
    }
}

@end
