//
//  HZPDFWebViewController.m
//  RosePDF
//
//  Created by THS on 2024/3/28.
//

#import "HZPDFWebViewController.h"
#import "HZCommonHeader.h"
#import <WebKit/WebKit.h>
#import "HZBaseNavigationBar.h"

@interface HZPDFWebViewController ()
@property (nonatomic, strong) HZBaseNavigationBar *navBar;
@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *titleText;


@end

@implementation HZPDFWebViewController
- (instancetype)initWithUrl:(NSString *)urlString title:(NSString *)title {
    if (self = [super init]) {
        self.url = urlString;
        self.titleText = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navBar = [[HZBaseNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, hz_safeTop + navigationHeight)];
    [self.view addSubview:self.navBar];
    [self.navBar configTitle:self.titleText];
    [self.navBar configRightTitle:nil];
    [self.navBar configBackImage:[UIImage imageNamed:@"rose_back"]];
    @weakify(self);
    [self.navBar setClickBackBlock:^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    // 创建 WKWebView 实例
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, self.navBar.bottom, self.view.width, self.view.height - self.navBar.bottom)];
    [self.view addSubview:self.webView];
    
    // 加载本地 PDF 文件
    NSURL *pdfURL = [NSURL fileURLWithPath:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:pdfURL];
    [self.webView loadRequest:request];
}

@end
