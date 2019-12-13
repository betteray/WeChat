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
#import <Ono.h>
#import "GetMsgImgService.h"
#import "DownloadVoiceService.h"
#import "DownloadVideoService.h"

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
            
            [DBManager saveWCMessage:msg];

            switch (msg.msgType) {
                case 10002:
                case 9999:
                {
                    // msg content : <sysmsg type="ClientCheckGetExtInfo"><ClientCheckGetExtInfo><ReportContext>539033600</ReportContext><Basic>0</Basic></ClientCheckGetExtInfo></sysmsg>
                    // basic != 0时，上报的消息不一样，比较简单
                    NSString *xmlMsg = msg.content.string;
                    if (isSystemMsg && [xmlMsg containsString:@"ClientCheckGetExtInfo"]) {
                        ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithString:msg.content.string encoding:NSUTF8StringEncoding error:nil];
                        uint32_t rptContext = [[[document.rootElement firstChildWithTag:@"ReportContext"] numberValue] intValue];
                        [WCSafeSDK reportClientCheckWithContext:rptContext basic:YES];
                    }
                }
                    break;
                case 3: // 图片消息
                {
                    // <?xml version="1.0"?>
                    // <msg>
                    //     <img aeskey="455ef37de7239ca561a3ce12783a5d2b" encryver="1" cdnthumbaeskey="455ef37de7239ca561a3ce12783a5d2b" cdnthumburl="304f02010004483046020100020474e9584d02033d0af802045830feb602045df2f8330421777869645f3330756864736b6b6c79636932323135325f313537363230343333390204010400020201000400" cdnthumblength="2738" cdnthumbheight="39" cdnthumbwidth="69" cdnmidheight="0" cdnmidwidth="0" cdnhdheight="0" cdnhdwidth="0" cdnmidimgurl="304f02010004483046020100020474e9584d02033d0af802045830feb602045df2f8330421777869645f3330756864736b6b6c79636932323135325f313537363230343333390204010400020201000400" length="6825" md5="30e013e2e1aacc5fe0487a92c747c650" />
                    // </msg>
                    NSString *from = msg.fromUserName.string;
                    NSString *to = msg.toUserName.string;
                    ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithString:msg.content.string encoding:NSUTF8StringEncoding error:nil];
                    NSDictionary *attrs = [[document.rootElement firstChildWithTag:@"img"] attributes];
                    [GetMsgImgService getMsgImg:msg.msgId from:from to:to dataTotalLen:[attrs[@"length"] intValue]];
                }
                    break;
                case 34: { //语音
                    // <msg><voicemsg endflag="1" length="8198" voicelength="4740" clientmsgid="49815b6f8cf628b6cc64119a643bb6aawxid_30uhdskklyci22179_1576211669" fromusername="rowhongwei" downcount="0" cancelflag="0" voiceformat="4" forwardflag="0" bufid="650040178152112560" /></msg>
                    ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithString:msg.content.string encoding:NSUTF8StringEncoding error:nil];
                    NSDictionary *attrs = [[document.rootElement firstChildWithTag:@"voicemsg"] attributes];
                    [DownloadVoiceService getMsgVoice:msg.msgId clientMsgID:attrs[@"clientmsgid"] length:[attrs[@"length"] intValue]];
                }
                    break;
                case 43:
                {
                    // <?xml version="1.0"?>
                    // <msg>
                    //     <videomsg aeskey="c406a849ca3a9a9e7d97de1fb64eb19d" cdnthumbaeskey="c406a849ca3a9a9e7d97de1fb64eb19d" cdnvideourl="30580201000451304f020100020474e9584d02033d0af802045930feb602045df33bbd042a777875706c6f61645f777869645f3330756864736b6b6c79636932323138375f313537363232313632390204010400040201000400" cdnthumburl="30580201000451304f020100020474e9584d02033d0af802045930feb602045df33bbd042a777875706c6f61645f777869645f3330756864736b6b6c79636932323138375f313537363232313632390204010400040201000400" length="368458" playlength="2" cdnthumblength="2683" cdnthumbwidth="224" cdnthumbheight="398" fromusername="rowhongwei" md5="7a337de317de79ead61ec60bb537ec2a" newmd5="f21d3734f3fa58625d9784217f8a506e" isad="0" />
                    // </msg>
                    ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithString:msg.content.string encoding:NSUTF8StringEncoding error:nil];
                    NSDictionary *attrs = [[document.rootElement firstChildWithTag:@"videomsg"] attributes];
                    [DownloadVideoService downloadVideo:msg.msgId startPos:0 dataTotalLen:[attrs[@"length"] intValue]];
                }
                default:
                    break;
            }
            
        }
        else if (2 == cmdItem.cmdId) //好友列表 ModContact
        {
            ModContact *modContact = [[ModContact alloc] initWithData:cmdItem.cmdBuf.buffer error:nil];
            LogVerbose(@"Mod Contact: %@", modContact);
            [DBManager saveWCContact:modContact];
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
