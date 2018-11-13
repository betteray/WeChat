//
//  ViewController.m
//  WXDemo
//
//  Created by ray on 2018/9/13.
//  Copyright © 2018 ray. All rights reserved.
//

#import "ViewController.h"
#import "WeChatClient.h"
#import "Mm.pbobjc.h"
#import "Constants.h"
#import "NSData+Util.h"
#import "FSOpenSSL.h"
#import "CgiWrap.h"
#import "NSData+PackUtil.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ECDH.h"
#import "MarsOpenSSL.h"
#import "NSData+AES.h"
#import <Protobuf/GPBCodedOutputStream.h>
#import "NSData+Util.h"

#import "WX_AesGcm128.h"
#import "WX_SHA256.h"
#import "WX_HKDF.h"

#define TICK_INTERVAL 1

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *qrcodeTimerLabel;
@property (nonatomic, strong) NSTimer *qrcodeCheckTimer;

@property (nonatomic, strong) NSData *nofityKey;
@property (nonatomic, assign) NSInteger clientMsgId;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _clientMsgId = 1;
    
    [self test2];
    [self test3];
}

- (void)test2 {
    time_t t = time(NULL);
    srand((unsigned int)t);
    unsigned long long r = rand();
//    printf("/mmtls/%08llx", r);
}

- (void)test3 {
    NSData *key = [NSData dataWithHexString:@"6233A9D0EFA790A578CB7A81B809AA07B3"];
    NSData *aad = [NSData dataWithHexString:@"000000000000000217F1030020"];
    NSData *iv = [NSData dataWithHexString:@"32F36D6B78FA6BE0ADCA4C4B"];
    NSData *plainText = [NSData dataWithHexString:@"000000100010000100000006FFFFFFFF"];
    
    NSData *cipherText = nil;
    NSData *tag = nil;
//    BOOL success = [WX_AesGcm128 aes128gcmEncrypt:plainText ciphertext:&cipherText aad:aad key:key ivec:iv tag:&tag];//!OK
//    BOOL success  = [AesGcm128 aes128gcmDecrypt:cipherText plaintext:&plainText aad:aad key:key ivec:iv];
//    unsigned char buf[16];
//    success = [AesGcm128 aes256gcmDecrypt:cipherText plaintext:&plainText aad:aad key:[key bytes] ivec:[iv bytes] tag:buf];
//    if (success) {
//        NSLog(@"result: %@", cipherText);
//    }
    
    
    NSData *data = [WX_SHA256 sha256:[NSData dataWithHexString:@"000000D00103F101C02BBFBB3304CE294BF241A754996B85D0D91DB37F4D9B0656AA3AB635C48545B72A5BE14AFB000000A2010000009D00100200000047000000010041040683FFB4280A0061018227C215501363CBE26E99A1222C56A43C5337C4F625CAA3A9102F969235B1775EB948D47A84C56AD3E109C1AE2F748B72E885A9E41A4100000047000000020041042BFC62671C1C977B3C51678D386FEC388C14A2EEE439062106B6603C305F2C9AC07147D33790658F06876BB158D95531FD3210784E2CDF41707846907A03A17C00000001000000770203F1C02B5ED80DEE3A787A133FCE64B082A677BCFF38649FA719A3740E0625E7EF55C1820000004E010000004900110000000100410458687A537C48C52423C5B45F413E0591C1C618AE2EDFCDEF4AF469E8D89E66DA53CE028B801A6DEC1420DBDC5587761B6336EF921B28D91E7B49FB4C395CE10B"]];
    
    data = [WX_SHA256 sha256:[NSData dataWithHexString:@"000001110402000000630100093A80000000000023000C9E2AE56305B387C3726D1F4800488FC602890551EE782A1C3A210CB714DEFEE04EFC5BE2D42BC0DCA13EB06FA87B442EF1F2DDE3B01504A0909D54E39F502F2F6C3719E68F80AD86A06DE8386EC2BDB1EA7363F97C90000000A40200278D00002017A8737913FCD1D0E7C9F54DACE04620AA841C7F1C0D3CA0628D002E58E3EE4500000023000CAD10FA19A37B4AE6A25BA0030069E6FC7BB4B871BA4BEB10DC2623BA1891D481C2093A0A1734BCBD73A9AE86FC067381D2E270960AABCC10D9C825488A6FD348582BEDE6BE32C326D33DB3896A2CBEC4D5A9F37972A19E8A536D3C648453845C2002A40602A19545CE3273FDDCAD0AC86BE0BFF9D1DEB5"]];
    
    data = [WX_SHA256 sha256:[NSData dataWithHexString:@"000001110402000000630100093A80000000000021000CBE8A865E08F0615D55AE3D6600481B4EBDD4C7B378D39822A6D4003D7C8FAF91AE541673A21BD93AFDA66CBDFE764C51B0ADA33B176E08BEB0650E4017216C5E41AE74E363275441D805A80FAA3F655B377BD4E0F612000000A40200278D00002053BE227FC238B71CC12D8283CCF14F723C56EF789291C8661241C29DD15C8BAC00000021000C94B8E4EA482E2741A76F547D0069E2A978901BFC986BFDE102BDF4559411618760BA3035DF842E10285DA3B0F64BB5F8ACDB7B68A3571369AB01D3627EFA2C69ECFFA2C1E0A1CFD136FFD1CD5936CB4789C00D00FA2D949A1ED5DF8AF155C23C509DEDA9063B06198BBFEB3F4F68807BD22BBFE8E58DF0"]];
    
    NSLog(@"%@", data);//OKÅ
    
    NSData *priKeyData = nil;
    NSData *pubKeyData = nil;
    BOOL ret = [ECDH GenEcdhWithNid:415 priKey:&priKeyData pubKeyData:&pubKeyData];//OK
    if (ret) {
//          NSLog(@"+[ECDH GenEcdhWithNid:415] %@, PubKey: %@.", priKeyData, pubKeyData);
    }

    priKeyData = [NSData dataWithHexString:@"307702010104204B5DF336CEEAAECD52F44983D05ECB16E063134B48214A30279ABC0DE6D1F4ACA00A06082A8648CE3D030107A144034200040683FFB4280A0061018227C215501363CBE26E99A1222C56A43C5337C4F625CAA3A9102F969235B1775EB948D47A84C56AD3E109C1AE2F748B72E885A9E41A41"];
    pubKeyData = [NSData dataWithHexString:@"0458687A537C48C52423C5B45F413E0591C1C618AE2EDFCDEF4AF469E8D89E66DA53CE028B801A6DEC1420DBDC5587761B6336EF921B28D91E7B49FB4C395CE10B"];
    
    unsigned char szSharedKey[2048];
    int szSharedKeyLen = 0;
    ret = [ECDH DoEcdh2:415 szServerPubKey:[pubKeyData bytes] nLenServerPub:[pubKeyData length] szLocalPriKey:[priKeyData bytes] nLenLocalPri:[priKeyData length] szShareKey:szSharedKey pLenShareKey:&szSharedKeyLen]; //OK
    
    if (ret) {
        NSData *key = [NSData dataWithBytes:szSharedKey length:szSharedKeyLen];
//        NSLog(@"%@", key);
    }
    
    NSData *prk = [NSData dataWithHexString:@"752F71EB03175732B7519D84A93EE816003623C0CC0DC7B04A856723CAF36239"];
    NSData *info = [NSData dataWithHexString:@"657870616E646564207365637265743FF0186737665A4FDD7689F4598126D8B2715C710865FDA9871161B27F27771E"];
    NSData *outOkm = nil;
    
    [WX_HKDF HKDF_Expand_Prk2:prk Info:info outOkm:&outOkm]; //OK
    
//    NSLog(@"%@", outOkm);//OK 0x20 字节的
    
    NSData *hmacKey = [NSData dataWithHexString:@"BC2C06D9B467AB59C496CEF2DE2A20230AA2DF645ADDE11D0D89D85121BF69B2"];
    NSData *hmacData = [NSData dataWithHexString:@"3B4B3DD60FD02538216D2019DFD3219224B965E9506889090C3F82ECBC41DF14"];
    
    NSData *hmacResult = nil;
    
    [WX_HmacSha256 HmacSha256WithKey:hmacKey data:hmacData result:&hmacResult];//OK
    
//    NSLog(@"%@", hmacResult);
}

- (IBAction)getQRCode {
    NSLog(@"扫描成功");
    [self.qrcodeCheckTimer invalidate];
    self.qrcodeCheckTimer = nil;
    
    GetLoginQRCodeRequest *request = [GetLoginQRCodeRequest new];

    SKBuiltinBuffer *buffer = [SKBuiltinBuffer new];
    [buffer setILen:(int32_t)[[WeChatClient sharedClient].sessionKey length]];
    [buffer setBuffer:[WeChatClient sharedClient].sessionKey];
    [request setRandomEncryKey:buffer];

    [request setDeviceName:DEVICEN_NAME];
    [request setExtDevLoginType:0];
    [request setOpcode:0];
    [request setHardwareExtra:0];
    [request setUserName:nil];
    [request setSoftType:nil];
    SKBuiltinBuffer * pubKey = [SKBuiltinBuffer new];
    pubKey.buffer = [WeChatClient sharedClient].pubKey;
    [pubKey setILen:(int32_t)[[WeChatClient sharedClient].pubKey length]];
    [request setMsgContextPubKey:pubKey];

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 502;
    cgiWrap.cmdId = 232;
    cgiWrap.request = request;
    cgiWrap.responseClass = [GetLoginQRCodeResponse class];
    
    [WeChatClient startRequest:cgiWrap success:^(GPBMessage * _Nullable response) {
        NSLog(@"%@", response);
        GetLoginQRCodeResponse *resp = (GetLoginQRCodeResponse *)response;
        
        if (resp) {
            self.nofityKey = resp.notifyKey.buffer;
            self.qrcodeImageView.image = [UIImage imageWithData:[[resp qrcode] buffer]];
            self.qrcodeTimerLabel.text = [NSString stringWithFormat:@"%d", resp.expiredTime];
            self.qrcodeCheckTimer = [NSTimer scheduledTimerWithTimeInterval:TICK_INTERVAL target:self selector:@selector(tick:) userInfo:resp repeats:YES];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)tick:(NSTimer *)timer {
    [self updateUI];
    
    CheckLoginQRCodeRequest *request = [CheckLoginQRCodeRequest new];
    
    SKBuiltinBuffer *buffer = [SKBuiltinBuffer new];
    [buffer setILen:16];
    [buffer setBuffer:[WeChatClient sharedClient].sessionKey];
    [request setRandomEncryKey:buffer];

    request.uuid = ((GetLoginQRCodeResponse *)[timer userInfo]).uuid;
    request.timeStamp = [[NSDate date] timeIntervalSince1970];
    request.opcode = 0;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 503;
    cgiWrap.cmdId = 233;
    cgiWrap.request = request;
    cgiWrap.responseClass = [CheckLoginQRCodeResponse class];
    
    [WeChatClient startRequest:cgiWrap success:^(GPBMessage * _Nullable response) {
        CheckLoginQRCodeResponse *resp = (CheckLoginQRCodeResponse *)response;
        if (resp.baseResponse.ret == 0) {
            NSData *notifyProtobufData = [[resp.notifyPkg.notifyData buffer] aesDecryptWithKey:self.nofityKey];
            NotifyMsg *msg = [NotifyMsg parseFromData:notifyProtobufData error:nil];
            if (![msg.avatar isEqualToString:@""]) {
                NSLog(@"扫描成功: %@", msg);
                self.qrcodeTimerLabel.text = msg.nickName;
                [self.qrcodeImageView sd_setImageWithURL:[NSURL URLWithString:msg.avatar]];
            }
            
            if (![msg.wxnewpass isEqualToString:@""]) {//ManualAuth
                
                [self mannualAtuhLoginWithWxid:msg.wxid newPassword:msg.wxnewpass];
            }
            
            if (msg.state == 0 || msg.state == 1) {
                NSLog(@"继续检查确认登陆。");
            }
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)updateUI {
    NSInteger remainTime = [_qrcodeTimerLabel.text integerValue] - TICK_INTERVAL;
    if (remainTime <= 0) {
        self.qrcodeTimerLabel.text = @"二维码已过期";
    } else {
        self.qrcodeTimerLabel.text = [NSString stringWithFormat:@"%d", (int)remainTime];
    }
}

- (IBAction)test {    
    SKBuiltinString_t *toUserName = [SKBuiltinString_t new];
    toUserName.string = @"rowhongwei";

    MicroMsgRequestNew *mmRequestNew = [MicroMsgRequestNew new];
    mmRequestNew.toUserName = toUserName;
    mmRequestNew.content = @"Hello There.";
    mmRequestNew.type = 1;
    mmRequestNew.createTime = [[NSDate date] timeIntervalSince1970];
    mmRequestNew.clientMsgId = _clientMsgId++; //[[NSDate date] timeIntervalSince1970] + arc4random();
    mmRequestNew.msgSource = @"<msgsource></msgsource>";

    SendMsgRequestNew *request = [SendMsgRequestNew new];

    [request setListArray:[NSMutableArray arrayWithObject:mmRequestNew]];
    request.count = (int32_t)[[NSMutableArray arrayWithObject:mmRequestNew] count];

    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cmdId = 237;
    cgiWrap.cgi = 522;
    cgiWrap.request = request;
    cgiWrap.responseClass = [MicroMsgResponseNew class];

    [[WeChatClient sharedClient] sendMsg:cgiWrap success:^(GPBMessage * _Nullable response) {
        NSLog(@"%@", response);
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)mannualAtuhLoginWithWxid:(NSString *)wxid newPassword:(NSString *)password {
    NSData *priKeyData = nil;
    NSData *pubKeyData = nil;
    BOOL ret = [ECDH GenEcdhWithNid:713 priKey:&priKeyData pubKeyData:&pubKeyData];
    if (ret) {
//        NSLog(@"+[ECDH GenEcdh:pubKeyData:] %@, PubKey: %@.", priKeyData, pubKeyData);
    }
    
    ManualAuthAccountRequest_AesKey *aesKey = [ManualAuthAccountRequest_AesKey new];
    aesKey.len = (int32_t)[[WeChatClient sharedClient].sessionKey length];
    aesKey.key = [WeChatClient sharedClient].sessionKey;

    ManualAuthAccountRequest_Ecdh_EcdhKey *ecdhKey = [ManualAuthAccountRequest_Ecdh_EcdhKey new];
    ecdhKey.len = (int32_t)[pubKeyData length];
    ecdhKey.key = pubKeyData;

    ManualAuthAccountRequest_Ecdh *ecdh = [ManualAuthAccountRequest_Ecdh new];
    ecdh.nid = 713;
    ecdh.ecdhKey = ecdhKey;

    ManualAuthAccountRequest *accountReqeust = [ManualAuthAccountRequest new];
    accountReqeust.aes = aesKey;
    accountReqeust.ecdh = ecdh;
    accountReqeust.pwd = password;
    accountReqeust.userName = wxid;

    ManualAuthDeviceRequest_BaseAuthReqInfo *baseReqInfo = [ManualAuthDeviceRequest_BaseAuthReqInfo new];
     //TODO: ?第一次登陆没有数据，后续登陆会取一个数据。
//    baseReqInfo.cliDbencryptInfo = [NSData data];
//    baseReqInfo.authReqFlag = @"";
    
    
    ManualAuthDeviceRequest *deviceRequest = [ManualAuthDeviceRequest new];
    deviceRequest.baseReqInfo = baseReqInfo;
    deviceRequest.imei = @"dd09ae95fe48164451be954cd1871cb7";
//    deviceRequest.softType = @"<softtype><k3>11.4.1</k3><k9>iPad</k9><k10>2</k10><k19>68ADE338-AA19-433E-BA2A-3D6DF3C787D5</k19><k20>AAA7AE28-7620-431D-8B4C-7FB4F67AA45E</k20><k22>(null)</k22><k33>微信</k33><k47>1</k47><k50>0</k50><k51>com.tencent.xin</k51><k54>iPad4,4</k54><k61>2</k61></softtype>";
    deviceRequest.builtinIpseq = 0;
    deviceRequest.clientSeqId = @""; //[NSString stringWithFormat:@"%@-%d", @"dd09ae95fe48164451be954cd1871cb7", (int)[[NSDate date] timeIntervalSince1970]];
    deviceRequest.deviceName = DEVICEN_NAME;
    deviceRequest.deviceType = @"iMac18,2";
    deviceRequest.language = @"zh_CN";
    deviceRequest.timeZone = @"8.00";
    deviceRequest.channel = 0; 
    deviceRequest.timeStamp = [[NSDate date] timeIntervalSince1970];
    deviceRequest.deviceBrand = @"Apple";
    deviceRequest.realCountry = @"CN";
    deviceRequest.bundleId = @"com.tencent.xinWeChat";
//    deviceRequest.adSource = @""; //iMac 不需要
    deviceRequest.iphoneVer = @"iMac18,2";
    deviceRequest.inputType = 2;
    deviceRequest.ostype = @"Version 10.13.6 (Build 17G65)";

        //iMac 暂时不需要
//    SKBuiltinBuffer *clientCheckData = [SKBuiltinBuffer new];
//    clientCheckData.iLen = 0;
//    clientCheckData.buffer = [NSData data];
//    deviceRequest.clientCheckData = clientCheckData;
    
    ManualAuthRequest *authRequest = [ManualAuthRequest new];
    authRequest.aesReqData = deviceRequest;
    authRequest.rsaReqData = accountReqeust;
    
    CgiWrap *cgiWrap = [CgiWrap new];
    cgiWrap.cgi = 701;
    cgiWrap.cmdId = 253;
    cgiWrap.request = authRequest;
    cgiWrap.responseClass = [ManualAuthResponse class];
    
    [[WeChatClient sharedClient] manualAuth:cgiWrap success:^(GPBMessage * _Nullable response) {
        ManualAuthResponse *resp = (ManualAuthResponse *)response;
        
        NSLog(@"登陆响应 Code: %d, msg: %@", resp.result.code, resp.result.errMsg.msg);
        switch (resp.result.code) {
            case -301: {    //需要重定向
                if (resp.dns.ip.longlinkIpCnt > 0) {
                    NSString *longlinkIp = [[resp.dns.ip.longlinkArray firstObject].ip stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                    [[WeChatClient sharedClient] restartUsingIpAddress:longlinkIp];
                }
            }
                break;
            case 0: {       //成功，停止检查二维码
                [self.qrcodeCheckTimer invalidate];
                self.qrcodeCheckTimer = nil;
                self.qrcodeTimerLabel.text = @"登陆成功";
                
                int32_t uin = resp.authParam.uin;
                [WeChatClient sharedClient].uin = uin;

                int32_t nid = resp.authParam.ecdh.nid;
                int32_t ecdhKeyLen = resp.authParam.ecdh.ecdhKey.len;
                NSData *ecdhKey = resp.authParam.ecdh.ecdhKey.key;
                
                unsigned char szSharedKey[2048];
                int szSharedKeyLen = 0;
                
                BOOL ret = [ECDH DoEcdh:nid szServerPubKey:(unsigned char *)[ecdhKey bytes]
                          nLenServerPub:ecdhKeyLen
                          szLocalPriKey:(unsigned char *)[priKeyData bytes]
                           nLenLocalPri:(int)[priKeyData length]
                             szShareKey:szSharedKey
                           pLenShareKey:&szSharedKeyLen];
                
                if (ret) {
                    NSData *checkEcdhKey = [NSData dataWithBytes:szSharedKey length:szSharedKeyLen];
                    [WeChatClient sharedClient].sessionKey = [FSOpenSSL aesDecryptData:resp.authParam.session.key key:checkEcdhKey];
                    [WeChatClient sharedClient].checkEcdhKey = checkEcdhKey;
                    
                    NSLog(@"登陆成功: SessionKey: %@, uin: %d, wxid: %@, NickName: %@, alias: %@",
                          [WeChatClient sharedClient].sessionKey,
                          uin, resp.accountInfo.wxId,
                          resp.accountInfo.nickName,
                          resp.accountInfo.alias);
                    
                    [WeChatClient sharedClient].shortLinkUrl = [[resp.dns.ip.shortlinkArray firstObject].ip stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                }
            }
                break;
            default:
                break;
        }
    } failure:^(NSError *error) {
        
    }];
}

@end
