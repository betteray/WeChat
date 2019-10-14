//
//  PersonalInfoService.m
//  WeChat
//
//  Created by ray on 2019/10/14.
//  Copyright © 2019 ray. All rights reserved.
//

#import "PersonalInfoService.h"
#import "Mm.pbobjc.h"
#import "FSOpenSSL.h"

@implementation PersonalInfoService

- (void)uploadHeadImg {
    
//    Request: <UploadHDHeadImgRequest: 0x282b130c0>,
//    Path: /cgi-bin/micromsg-bin/uploadhdheadimg
//    Cgi: 157
    
    UploadHDHeadImgRequest *reqeust = [UploadHDHeadImgRequest new];
    
    NSData *headImageData = [NSData dataWithContentsOfFile:@""];
    NSMutableData *headImageDataHash = [[FSOpenSSL md5FromData:headImageData] mutableCopy];
    
    NSString *ts = [NSString stringWithFormat:@"%lu", time(0)];
    [headImageDataHash appendData:[ts dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *imgHash = [FSOpenSSL md5FromData:headImageDataHash];
    reqeust.imgHash = [[NSString alloc] initWithData:imgHash encoding:NSUTF8StringEncoding];
}

+ (void)updateProfile {
//    昵称：
//     cmdID: 64, ModSingleField(opType=1:value=蓝柿子哈哈)
//
//    签名
//    cmdID: 64, ModSingleField(opType=2:value=签名发自内心深处。)
//
//    地区:
//    性别:
//    cmdID: 1, <ModUserInfo 0x7ff0d5412850>: {
//        bitFlag: 2178
//        userName {
//          string: "wxid_30uhdskklyci22"
//        }
//        nickName {
//          string: "蓝柿子哈哈"
//        }
//        bindUin: 0
//        bindEmail {
//          string: ""
//        }
//        bindMobile {
//          string: ""
//        }
//        status: 233505
//        imgLen: 0
//        sex: 1
//        province: ""
//        city: ""
//        signature: "签名发自内心深处。"
//        personalCard: 1
//        pluginFlag: 161953
//        country: "AF"
//    }
    
    //OplogRequest请求，下方的数据可以由此构造。
//    Json: {"oplog":{"count":1,"list":[{"cmdId":1,"cmdBuf":{"iLen":153,"buffer":"<08821112 150a1377 7869645f 33307568 64736b6b 6c796369 32321a11 0a0fe893 9de69fbf e5ad90e5 9388e593 8820002a 020a0032 020a0038 a1a00e40 0050015a 0062006a 48e4baba e7949fe9 8193e8b7 afe4b88a e79a84e6 af8fe4b8 80e4b8aa e9878ce7 a88be7a2 91efbc8c e983bde5 88bbe79d 80e4b8a4 e4b8aae5 ad97e280 9ce8b5b7 e782b9e2 809de380 82700180 01a1f109 b2020243 4e>"}}]}}
//    SerializedData: <0aa90108 0112a401 0801129f 01089901 12990108 82111215 0a137778 69645f33 30756864 736b6b6c 79636932 321a110a 0fe8939d e69fbfe5 ad90e593 88e59388 20002a02 0a003202 0a0038a1 a00e4000 50015a00 62006a48 e4babae7 949fe981 93e8b7af e4b88ae7 9a84e6af 8fe4b880 e4b8aae9 878ce7a8 8be7a291 efbc8ce9 83bde588 bbe79d80 e4b8a4e4 b8aae5ad 97e2809c e8b5b7e7 82b9e280 9de38082 70018001 a1f109b2 0202434e>

//    NSData* data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"gender" ofType:@"bin"]];
//    OplogRequest *request = [[OplogRequest alloc] initWithData:data error:nil];
//    CmdList *cmdList = request.oplog;
//    CmdItem *cmdItem = cmdList.listArray[0];
//    ModUserInfo *modSingleField = [[ModUserInfo alloc] initWithData:cmdItem.cmdBuf.buffer error:nil];
//
//    LogVerbose(@"cmdID: %d, %@", cmdItem.cmdId, modSingleField);
}

@end
