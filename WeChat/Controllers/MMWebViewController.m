//
//  MMWebViewController.m
//  WeChat
//
//  Created by ysh on 2019/1/24.
//  Copyright © 2019 ray. All rights reserved.
//

#import "MMWebViewController.h"

@interface MMWebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation MMWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:_url]];
}

#pragma mark -- UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    LogVerbose(@"%@", request);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    LogVerbose(@"WebViewDidStartLoad.");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    LogVerbose(@"WebViewDidFinishLoad.");
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
