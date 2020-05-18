//
//  AuthHandler.m
//  WeChat
//
//  Created by ray on 2019/12/21.
//  Copyright © 2019 ray. All rights reserved.
//

#import "AuthHandler.h"
#import <Ono.h>
#import "AppDelegate.h"
#import "WCECDH.h"
#import "SyncService.h"
#import "MMWebViewController.h"
#import "FSOpenSSL.h"

@implementation AuthHandler

#pragma mark - AuthResponse

+ (void)onLoginResponse:(UnifyAuthResponse *)resp from:(nullable UIViewController *)fromController {
    switch (resp.baseResponse.ret) {
        case -106: {
            [DBManager clearCookie];
            ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithString:resp.baseResponse.errMsg.string encoding:NSUTF8StringEncoding error:nil];
            NSString *errMsgContent = [[document.rootElement firstChildWithTag:@"Content"] stringValue];
            LogError(@"登录错误: (-106) errMsg: %@", errMsgContent);
            
            NSString *url = [[document.rootElement firstChildWithTag:@"Url"] stringValue];
            [self startNaviUrl:url from:fromController];
        }
            break;
        case -301: { //需要重定向

            LogError(@"登录 -301， 重定向IP。。。");
            [DBManager saveBuiltinIP:resp.networkSectResp.builtinIplist];
            [DBManager clearCookie];
            [[WeChatClient sharedClient] restart]; // restart

            [fromController performSelector:@selector(ManualAuth)]; // 重新登录
        }
            break;
        case 0: {
            int32_t uin = resp.authSectResp.uin;
            [WeChatClient sharedClient].uin = uin;

            int32_t nid = resp.authSectResp.svrPubEcdhkey.nid;
            int32_t ecdhKeyLen = resp.authSectResp.svrPubEcdhkey.key.iLen;
            NSData *ecdhKey = resp.authSectResp.svrPubEcdhkey.key.buffer;

            unsigned char szSharedKey[2048];
            int szSharedKeyLen = 0;

            BOOL ret = [WCECDH DoEcdh:nid
                       szServerPubKey:(unsigned char *) [ecdhKey bytes]
                        nLenServerPub:ecdhKeyLen
                        szLocalPriKey:(unsigned char *) [ [WeChatClient sharedClient].priKeyData bytes]
                         nLenLocalPri:(int) [ [WeChatClient sharedClient].priKeyData length]
                           szShareKey:szSharedKey
                         pLenShareKey:&szSharedKeyLen];

            if (ret) {
                NSData *checkEcdhKey = [NSData dataWithBytes:szSharedKey length:szSharedKeyLen];
                NSData *sessionKey = [FSOpenSSL aesDecryptData:resp.authSectResp.sessionKey.buffer key:checkEcdhKey];
                [WeChatClient sharedClient].sessionKey = sessionKey;
                [WeChatClient sharedClient].checkEcdhKey = checkEcdhKey;

                LogVerbose(@"登陆成功: SessionKey: %@, uin: %d, wxid: %@, NickName: %@, alias: %@",
                        sessionKey,
                        uin,
                        resp.acctSectResp.userName,
                        resp.acctSectResp.nickName,
                        resp.acctSectResp.alias);

                [DBManager saveAutoAuthKey:resp.authSectResp.autoAuthKey.buffer];
                [DBManager saveAccountInfo:uin
                                  userName:resp.acctSectResp.userName
                                  nickName:resp.acctSectResp.nickName
                                     alias:resp.acctSectResp.alias];

                [DBManager saveSessionKey:sessionKey];
                [DBManager saveSelfAsWCContact:resp.acctSectResp.userName
                                      nickName:resp.acctSectResp.nickName];

                [self enterWeChat];
            }
        }
            break;
        default: {
            ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithString:resp.baseResponse.errMsg.string encoding:NSUTF8StringEncoding error:nil];
            NSString *errorMsg = [[document.rootElement firstChildWithTag:@"Content"] stringValue];
            [self alartLoginError:resp.baseResponse.ret msg:errorMsg from:fromController];
        }
            break;
    }
}

+ (void)enterWeChat {
    UIStoryboard *WeChatSB = [UIStoryboard storyboardWithName:@"WeChat" bundle:nil];
    UINavigationController *nav = [WeChatSB instantiateViewControllerWithIdentifier:@"WeChatTabBarController"];

    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    delegate.window.rootViewController = nav;

    [self startSync];
}

+ (void)alartLoginError:(int32_t)code msg:(NSString *)errMsg from:(UIViewController *)fromController {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"重新登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self clearData];
        [fromController performSelector:@selector(ManualAuth)]; // 重新登录
    }];
    
    NSString *title = [NSString stringWithFormat:@"登录错误(%d)", code];
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:errMsg preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:action];
    [fromController presentViewController:controller animated:YES completion:nil];
}

+ (void)clearData {
    [DBManager clearCookie];
    [DBManager clearAutoAuthKey];
    [DBManager clearSyncKey];
}

+ (void)startSync {
    if ([[WeChatClient sharedClient].sync_key_cur length] == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SyncService newInitWithSyncKeyCur:[WeChatClient sharedClient].sync_key_cur syncKeyMax:[WeChatClient sharedClient].sync_key_max];
        });
    } else {
        [SyncService newSync];
    }
}

+ (void)startNaviUrl:(NSString *)url from:(UIViewController *)fromController {
    UIStoryboard *WeChatSB = [UIStoryboard storyboardWithName:@"WeChat" bundle:nil];
    MMWebViewController *webViewController = [WeChatSB instantiateViewControllerWithIdentifier:@"MMWebViewController"];
    webViewController.url = [NSURL URLWithString:url];
    [fromController.navigationController pushViewController:webViewController animated:YES];
}

@end
