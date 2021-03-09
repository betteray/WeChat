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
#import "OplogService.h"
#import "FSOpenSSL.h"
#import "ReportClientCheckService.h"
#import "MessageHooks.h"
#import "CdnLogic.h"
#import "AES_EVP.h"

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
           
            [MessageHooks handleMsg:msg.content.string];
            
            [DBManager saveWCMessage:msg];

            switch (msg.msgType) {
                case 10002:
                case 9999:
                {
                    ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithString:msg.content.string encoding:NSUTF8StringEncoding error:nil];
                    NSDictionary *attrs = [document.rootElement attributes];
                    NSString *type = [attrs objectForKey:@"type"];
                    if ([type isEqualToString:@"ClientCheckGetExtInfo"]) {
                        // <sysmsg type="ClientCheckGetExtInfo"><ClientCheckGetExtInfo><ReportContext>539033600</ReportContext><Basic>0</Basic></ClientCheckGetExtInfo></sysmsg>
                        // basic != 0时，获取st的时候是传 0，这时候应该和登录的时候差不多。否则，传15，可以参考现在抓的数据，是15.
                        uint32_t reportContext = [[[document.rootElement firstChildWithXPath:@"//ReportContext"] numberValue] intValue];
                        [ReportClientCheckService reportClientCheckWithContext:reportContext basic:YES];
                    }
                    else if ([type isEqualToString:@"ClientCheckConsistency"])
                    {
                        // <sysmsg type="ClientCheckConsistency"><ClientCheckConsistency><clientcheck><fullpathfilename>@classes.dex</fullpathfilename><fileoffset>0</fileoffset><checkbuffersize>9999999</checkbuffersize><seq>536870912</seq></clientcheck></ClientCheckConsistency></sysmsg>
                        OpLogClientCheckConsistency *clientCheckConsistency = [OpLogClientCheckConsistency new];
                        NSString *fullpathfilename = [[document.rootElement firstChildWithXPath:@"//fullpathfilename"] stringValue];
                        uint32_t fileoffset = [[[document.rootElement firstChildWithXPath:@"//fileoffset"] numberValue] intValue];
                        uint32_t checkbuffersize = [[[document.rootElement firstChildWithXPath:@"//checkbuffersize"] numberValue] intValue];
                        uint32_t seq = [[[document.rootElement firstChildWithXPath:@"//seq"] numberValue] intValue];

                        NSString *dexPath = [[NSBundle mainBundle] pathForResource:@"classes_706" ofType:@"dex"];
                        NSData *dexData = [NSData dataWithContentsOfFile:dexPath];
                        NSString *dexMd5String = [FSOpenSSL md5StringFromData:dexData];
                        
                        [clientCheckConsistency setSeq:seq];
                        [clientCheckConsistency setCheckBufferSize:checkbuffersize];
                        [clientCheckConsistency setFileName:fullpathfilename];
                        [clientCheckConsistency setFileOffset:fileoffset];
                        
                        [clientCheckConsistency setCheckBufferHash:dexMd5String]; //所检测dex部分的md5，从抓到的数据看offset为0，检测总大小小等于9999999的话为整个dex文件的md5。
                        [clientCheckConsistency setFileSize:(uint32_t) [dexData length]];
                        [clientCheckConsistency setIsRoot:0]; //是否设备root
                        [clientCheckConsistency setNetType:4];
                        [clientCheckConsistency setCheckSum:@"1962359c264a15f2edf38ae300e7ec0c"]; // 计算方法见 ClientCheckConsistencyUtil.m 中的java实现，java计算结果正确。 正常情况下是这个值，如果offset和checkbuffersize小于dex文件则md5会变，相应这个值计算结果也要跟着变。
                        
                        [OplogService oplogRequestWithCmdId:61 message:clientCheckConsistency];
                    }
                    else if ([type isEqualToString:@"ClientCheckHook"]) //目前还没看到收到类似检测。
                    {
                        OpLogClientCheckHook *clientCheckHook = [OpLogClientCheckHook new];
                        [OplogService oplogRequestWithCmdId:62 message:clientCheckHook];
                    }
                    else if ([type isEqualToString:@"ClientCheckGetAppList"]) //目前也没收到类似的检测。
                    {
                        OpLogClientCheckGetAppList *checkGetAppList = [OpLogClientCheckGetAppList new];
                        [OplogService oplogRequestWithCmdId:63 message:checkGetAppList];
                    }
                }
                    break;
                case 3: // 图片消息
                {
                    // <?xml version="1.0"?>
                    // <msg>
                    //     <img aeskey="455ef37de7239ca561a3ce12783a5d2b" encryver="1" cdnthumbaeskey="455ef37de7239ca561a3ce12783a5d2b" cdnthumburl="304f02010004483046020100020474e9584d02033d0af802045830feb602045df2f8330421777869645f3330756864736b6b6c79636932323135325f313537363230343333390204010400020201000400" cdnthumblength="2738" cdnthumbheight="39" cdnthumbwidth="69" cdnmidheight="0" cdnmidwidth="0" cdnhdheight="0" cdnhdwidth="0" cdnmidimgurl="304f02010004483046020100020474e9584d02033d0af802045830feb602045df2f8330421777869645f3330756864736b6b6c79636932323135325f313537363230343333390204010400020201000400" length="6825" md5="30e013e2e1aacc5fe0487a92c747c650" />
                    // </msg>
                    
                    // <msg>
                    //     <img aeskey="b57168182ec2a5593635e41954a16701" encryver="0" cdnthumbaeskey="b57168182ec2a5593635e41954a16701" cdnthumburl="30580201000451304f020100020474e9584d02033d0af802047034feb602045df497b3042a777875706c6f61645f777869645f3330756864736b6b6c79636932323230305f313537363331303730340204010438010201000400" cdnthumblength="2874" cdnthumbheight="67" cdnthumbwidth="120" cdnmidheight="0" cdnmidwidth="0" cdnhdheight="0" cdnhdwidth="0" cdnmidimgurl="30580201000451304f020100020474e9584d02033d0af802047034feb602045df497b3042a777875706c6f61645f777869645f3330756864736b6b6c79636932323230305f313537363331303730340204010438010201000400" length="97574" cdnbigimgurl="30580201000451304f020100020474e9584d02033d0af802047034feb602045df497b3042a777875706c6f61645f777869645f3330756864736b6b6c79636932323230305f313537363331303730340204010438010201000400" hdlength="270545" md5="cc1e5bf7e089075b824a3ef5372ae10b" />
                    // </msg>
                    { // 原先的短链接下载cdn图片方法。
//                        NSString *from = msg.fromUserName.string;
//                        NSString *to = msg.toUserName.string;
//                        ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithString:msg.content.string encoding:NSUTF8StringEncoding error:nil];
//                        NSDictionary *attrs = [[document.rootElement firstChildWithTag:@"img"] attributes];
//                        NSNumber *thumbLength = [attrs objectForKey:@"length"];
//                        if (thumbLength) { // 缩略图应该都有吧。 控制位在请求上设置。
//                            [GetMsgImgService getMsgImg:msg.msgId startPos:0 from:from to:to dataTotalLen:[thumbLength intValue] original:NO];
//                        }
//                        NSNumber *hdLength = [attrs objectForKey:@"hdlength"];
//                        if (hdLength) { //需要判断有没有高清图，再获取高清图。
//                            [GetMsgImgService getMsgImg:msg.msgId startPos:0 from:from to:to dataTotalLen:[hdLength intValue] original:YES];
//                        }
                    }
                    
                    {
                        ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithString:msg.content.string encoding:NSUTF8StringEncoding error:nil];
                        NSDictionary *attrs = [[document.rootElement firstChildWithTag:@"img"] attributes];
                        NSString *cdnthumburl = [attrs objectForKey:@"cdnbigimgurl"];
                        NSString *cdnthumbaeskey = [attrs objectForKey:@"cdnthumbaeskey"];
                        [[CdnLogic sharedInstance] startC2CDownload:cdnthumbaeskey fileid:cdnthumburl success:^(NSDictionary* _Nullable response) {
                            LogVerbose(@"CDN Download msg pic suc: %@", response);
                            NSString *filedatahex = [response objectForKey:@"filedata"];
                            NSData *filedata = [NSData dataWithHexString:filedatahex];
                            NSData *aeskey = [NSData dataWithHexString:cdnthumbaeskey];
                            NSData *imgData = [AES_EVP AES_ECB_128_Decrypt:filedata key:aeskey];
                            LogVerbose(@"Img Data: %@", imgData);
                        } failure:^(NSError * _Nonnull error) {
                            LogError(@"CDN Download msg pic fail: %@", error);
                        }];
                    }
                    
                }
                    break;
                case 34: { //收 语音 x
                    // <msg><voicemsg endflag="1" length="8198" voicelength="4740" clientmsgid="49815b6f8cf628b6cc64119a643bb6aawxid_30uhdskklyci22179_1576211669" fromusername="rowhongwei" downcount="0" cancelflag="0" voiceformat="4" forwardflag="0" bufid="650040178152112560" /></msg>
                    
//                    [普通消息]: msgId: 1106281102, createTime: 1576487825, fromUserName: rowhongwei, toUserName: wxid_30uhdskklyci22, msgType: 34, content: <msg><voicemsg endflag="1" length="6350" voicelength="4120" clientmsgid="49815b6f8cf628b6cc64119a643bb6aawxid_30uhdskklyci22215_1576487819" fromusername="rowhongwei" downcount="0" cancelflag="0" voiceformat="4" forwardflag="0" bufid="507242312405090687" /></msg>
                    
                    ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithString:msg.content.string encoding:NSUTF8StringEncoding error:nil];
                    NSDictionary *attrs = [[document.rootElement firstChildWithTag:@"voicemsg"] attributes];
                    [DownloadVoiceService getMsgVoice:msg.newMsgId clientMsgID:attrs[@"clientmsgid"] bufid:[attrs[@"bufid"] longLongValue] length:[attrs[@"length"] intValue]];
                }
                    break;
                case 43: // 收视频 ok
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
