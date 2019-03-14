//
//  MMWKWebViewController.m
//  WeChat
//
//  Created by ysh on 2019/2/12.
//  Copyright © 2019 ray. All rights reserved.
//

#import "MMWKWebViewController.h"
#import <WebKit/WebKit.h>

@interface MMWKWebViewController () <WKScriptMessageHandler, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webview;

@end

@implementation MMWKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userController = [[WKUserContentController alloc] init];
    configuration.userContentController = userController;
    
    WKUserScript *userScript1 = [[WKUserScript alloc] initWithSource:@"var weixinPerformance = {}; weixinPerformance.documentStart = Date.now();" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    WKUserScript *userScript2 = [[WKUserScript alloc] initWithSource:@"window.__wxjs_is_wkwebview = true; window.__wxjs_environment = 'browser';if (typeof window.weixinPostMessageHandlers === 'undefined') { window.weixinPostMessageHandlers = window.webkit.messageHandlers; try { Object.defineProperty(window, 'weixinPostMessageHandlers', { value: window.weixinPostMessageHandlers,writable:false }) } catch (e) {} };if (typeof window.weixinJSONParse === 'undefined'){try{Object.defineProperty(window, 'weixinJSONParse', {value: window.JSON.parse,writable:false,configurable:false})}catch(e){}}" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    NSString *userScriptString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserScript3" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *userScript3 = [[WKUserScript alloc] initWithSource:userScriptString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    
    WKUserScript *userScript4 = [[WKUserScript alloc] initWithSource:@"weixinPerformance.documentEnd = Date.now(); setTimeout(function(){weixinPerformance.documentRenderDone = Date.now()}, 0);" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];

    [userController addUserScript:userScript1];
    [userController addUserScript:userScript2];
    [userController addUserScript:userScript3];
    [userController addUserScript:userScript4];

    [userController addScriptMessageHandler:self name:@"weixinDispatchMessage"];
    [userController addScriptMessageHandler:self name:@"monitorHandler"];

    
    _webview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    
    _webview.navigationDelegate = self;
    _webview.customUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 11_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E302 MicroMessenger/7.0.2(0x17000222) NetType/WIFI Language/en";
    
    [self.view addSubview:_webview];
    
    [_webview loadRequest:[NSURLRequest requestWithURL:_url]];
    
}

- (void)notifyToJSBridgeVisibilityChanged
{
    
    [_webview evaluateJavaScript:@"JSON.stringify({document : (window.weixinPerformance ? window.weixinPerformance : null), timing : ((window.performance && window.performance.timing) ? window.performance.timing : null)});" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        LogVerbose(@"%@-%@", result, error);
    }];
    
    [_webview evaluateJavaScript:@"window.__usewepkg__ = false;" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        LogVerbose(@"%@-%@", result, error);
    }];
    
    [_webview evaluateJavaScript:@"document.__wxjsjs__isLoaded;" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        LogVerbose(@"%@-%@", result, error);
    }];
    
    
    NSString *js = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"big.js" ofType:nil] encoding:NSUTF8StringEncoding error:nil];
    [_webview evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        LogVerbose(@"%@-%@", result, error);
    }];
    
    [_webview evaluateJavaScript:@"document.__wxjsjs__sysInit;" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        LogVerbose(@"%@-%@", result, error);
    }];
    
    [_webview evaluateJavaScript:@"if (window.WeixinJSBridge){WeixinJSBridge._handleMessageFromWeixin({\"__sha_key\":\"3fb51516cca715be656e2be34c0931f3e9dcd990\",\"__json_message\":\"{\\\"__msg_type\\\":\\\"event\\\",\\\"__context_key\\\":\\\"64FBFC67-7E83-4A6B-ADC6-4FB8F29C928B\\\",\\\"__event_id\\\":\\\"onPageStateChange\\\",\\\"__runOn3rd_apis\\\":[\\\"onPageStateChange\\\"],\\\"__params\\\":{\\\"active\\\":true}}\"});}" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        LogVerbose(@"%@-%@", result, error);
    }];
    
    
    
    [_webview evaluateJavaScript:@"window.__wxjs_is_injected_success;" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        LogVerbose(@"%@-%@", result, error);
    }];
}

- (void)sysinit {
    [_webview evaluateJavaScript:@"document.__wxjsjs__sysInit = 'yes'" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        LogVerbose(@"%@-%@", result, error);
    }];
    
//    f (window.WeixinJSBridge){WeixinJSBridge._handleMessageFromWeixin({"__sha_key":"bb1955d0071acd7a8822d7a56dde1ddbfad1bf72","__json_message":"{\"__msg_type\":\"event\",\"__context_key\":\"0C7AE494-22AB-4009-B349-A5A9E4A0181A\",\"__event_id\":\"sys:init\",\"__runOn3rd_apis\":[\"sys:init\"],\"__params\":{\"system\":\"iOS 12.1.2\",\"init_font_size\":\"0\",\"model\":\"iPhone 6s Plus<iPhone8,2>\",\"timezone\":\"8.00\",\"language\":\"zh_CN\",\"version\":\"385876519\",\"init_url\":\"https://weixin110.qq.com/security/readtemplate?t=signup_verify/w_intro&regcc=86&regmobile=18810254324&regid=3_25391484302914798985&scene=get_reg_verify_code&wechat_real_lang=zh_CN\"}}"});}
}

//JS调用的OC回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    id msgBody = [message body];
    LogVerbose(@"%@", msgBody);
    if ([msgBody isKindOfClass:[NSString class]] && [((NSString *)msgBody) containsString:@"__domReadyNotify"]) {
        [self sysinit];
    }
}



- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self notifyToJSBridgeVisibilityChanged];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
