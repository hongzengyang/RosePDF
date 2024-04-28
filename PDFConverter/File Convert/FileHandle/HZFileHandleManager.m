//
//  HZFileHandleManager.m
//  PDFConverter
//
//  Created by THS on 2024/4/28.
//

#import "HZFileHandleManager.h"
#import "HZFileHandleUnit.h"
#import "HZCommonHeader.h"
#import "HZPDFConvertingView.h"
#import <WebKit/WebKit.h>


@interface HZFileHandleManager()<WKNavigationDelegate>

@property (nonatomic, strong) HZPDFConvertingView *convertingView;
@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, copy) void(^completeBlock)(HZProjectModel *project);


@end

@implementation HZFileHandleManager
+ (HZFileHandleManager *)manager {
    static dispatch_once_t pred;
    static HZFileHandleManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[HZFileHandleManager alloc] init];
    });
    return sharedInstance;
}

- (void)convertPdfUrl:(NSURL *)pdfUrl completeBlock:(void (^)(HZProjectModel *))completeBlock {
    self.completeBlock = completeBlock;
    [self showConvertingLoading];
    [self configWebView];
    [self startLoadWithPdfUrl:pdfUrl];
}

- (void)showConvertingLoading {
    UIViewController *topController = [UIView hz_viewController];
    if (!self.convertingView) {
        self.convertingView = [[HZPDFConvertingView alloc] initWithFrame:topController.view.bounds];
        [topController.view addSubview:self.convertingView];
    }
    [topController.view bringSubviewToFront:self.convertingView];
    
    [self.convertingView startConverting];
}

#pragma mark - Webview
- (void)configWebView {
    if (!self.webView) {
        UIViewController *topController = [UIView hz_viewController];
        self.webView = [[WKWebView alloc] initWithFrame:topController.view.bounds];
        self.webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        self.webView.navigationDelegate = self;
        self.webView.hidden = YES;
        [topController.view addSubview:self.webView];
    }
}

- (void)startLoadWithPdfUrl:(NSURL *)pdfUrl {
    NSString *originPath = [pdfUrl absoluteString];
    //只能打开doc
    NSString *tmpWordPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"sb.%@",[originPath hz_pathExtension]]];
    NSURL *copyUrl = [NSURL fileURLWithPath:tmpWordPath];
    [[NSFileManager defaultManager] removeItemAtURL:copyUrl error:nil];
    
    [[NSFileManager defaultManager] copyItemAtURL:pdfUrl toURL:copyUrl error:nil];

    [self.webView loadFileURL:copyUrl allowingReadAccessToURL:copyUrl];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 替换为你希望保存 PDF 的路径
    NSString *pdfFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp_converter.pdf"];
    [[NSFileManager defaultManager] removeItemAtPath:pdfFilePath error:nil];
    
    NSData *pdf = [self PDFData];
    [pdf writeToFile:pdfFilePath atomically:YES];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pdfFilePath]) {
        [self convertPdf2Images:pdfFilePath];
        NSLog(@"保存至：%@", pdfFilePath);
    }else {
        if (self.completeBlock) {
            self.completeBlock(nil);
        }
    }

}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (self.completeBlock) {
        self.completeBlock(nil);
    }
    NSLog(@"加载失败：%@", error.localizedDescription);
}

- (NSData *)PDFData {
    UIViewPrintFormatter *fmt = [self.webView viewPrintFormatter];
    UIPrintPageRenderer *render = [[UIPrintPageRenderer alloc] init];
    [render addPrintFormatter:fmt startingAtPageAtIndex:0];
    CGRect page;
    page.origin.x = 0;
    page.origin.y = 0;
    page.size.width = 600;
    page.size.height = 768;
    
    CGRect printable=CGRectInset( page, 50, 50 );
    [render setValue:[NSValue valueWithCGRect:page] forKey:@"paperRect"];
    [render setValue:[NSValue valueWithCGRect:printable] forKey:@"printableRect"];
    
    NSMutableData * pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData( pdfData, CGRectZero, nil );
    
    for (NSInteger i=0; i < [render numberOfPages]; i++)
    {
        UIGraphicsBeginPDFPage();
        CGRect bounds = UIGraphicsGetPDFContextBounds();
        [render drawPageAtIndex:i inRect:bounds];
        
    }
    UIGraphicsEndPDFContext();
    return pdfData;
}

- (void)convertPdf2Images:(NSString *)pdfPath {
    
}



@end
