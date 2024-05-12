//
//  HZFileConvertView.m
//  PDFConverter
//
//  Created by THS on 2024/4/28.
//

#import "HZFileConvertView.h"
#import "HZFileHandleManager.h"
#import "HZFileHandleUnit.h"
#import "HZCommonHeader.h"
#import "HZPDFConvertingView.h"
#import <WebKit/WebKit.h>
#import <PDFKit/PDFKit.h>
#import "HZProjectManager.h"
#import "HZPageModel.h"
#import "HZPDFMaker.h"

//https://github.com/liuchuan-alex/PPTToImage   ppt 2 image

@interface HZFileConvertView()<WKNavigationDelegate>

@property (nonatomic, strong) HZPDFConvertingView *convertingView;
@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, copy) void(^completeBlock)(HZProjectModel *project);
@end

@implementation HZFileConvertView

- (void)convertWord:(NSURL *)wordUrl completeBlock:(void (^)(HZProjectModel *))completeBlock {
    self.completeBlock = completeBlock;
    
    CGFloat width = self.width;
    CGFloat height = width / (210.0 / 297.0);
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, hz_safeTop, width, height)];
//    self.webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.webView.navigationDelegate = self;
    self.webView.hidden = NO;
    [self addSubview:self.webView];

    self.convertingView = [[HZPDFConvertingView alloc] initWithFrame:self.bounds];
    [self addSubview:self.convertingView];
    [self.convertingView startConverting];
    
    [self.webView loadFileURL:wordUrl allowingReadAccessToURL:wordUrl];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self createPDFfromWKWebView:webView];
//        [self test];
    });
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (self.completeBlock) {
        self.completeBlock(nil);
    }
    NSLog(@"加载失败：%@", error.localizedDescription);
}

- (void)createPDFfromWKWebView:(WKWebView *)webView {
    // 获取WKWebView的内容尺寸
    CGSize contentSize = webView.scrollView.contentSize;
    CGFloat pageHeight = webView.bounds.size.height;
    // 计算需要绘制的页数
    NSInteger totalPages = ceil(contentSize.height / pageHeight);
    // 创建PDF文件路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:@"webViewContent.pdf"];
    // 等待内容加载完成
    dispatch_async(dispatch_get_main_queue(), ^{
        // 开始绘制PDF
        UIGraphicsBeginPDFContextToFile(pdfPath, CGRectZero, nil);
        // 获取PDF绘制上下文
        CGContextRef pdfContext = UIGraphicsGetCurrentContext();
        // 绘制内容的起始位置
        __block CGFloat offsetY = 0;
        // 递归绘制每一页的内容
        void (^__block drawPDFPage)(NSInteger) = ^(NSInteger page) {
            if (page < totalPages) {
                // 设置PDF页面尺寸
//                CGFloat width = contentSize.width;
//                CGFloat height = pageHeight;
//                CGFloat sc = 0.1;
//                UIGraphicsBeginPDFPageWithInfo(CGRectMake(sc * width, sc * height, sc * 2 * width, sc * 2 * height), nil);
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, contentSize.width, pageHeight), nil);
                // 设置绘制的偏移量
                CGContextTranslateCTM(pdfContext, 0, -offsetY);
                // 绘制当前页的内容
                [webView.scrollView.layer renderInContext:pdfContext];
                // 更新偏移量
                offsetY += pageHeight;
                // 滚动到下一页
                [webView.scrollView setContentOffset:CGPointMake(0, offsetY) animated:NO];
                // 等待滚动完成
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    drawPDFPage(page + 1); // 绘制下一页
                });
            } else {
                // 所有页面绘制完成后结束PDF绘制
                UIGraphicsEndPDFContext();
                [self makeProjectWithPdfPath:pdfPath];
            }
        };
        // 开始绘制第一页
        drawPDFPage(0);
    });
}

- (NSArray <UIImage *>*)convertPdf2Images:(NSString *)pdfPath {
    NSMutableArray<UIImage *> *imageArray = [NSMutableArray array];
    
    PDFDocument *pdfDocument = [[PDFDocument alloc] initWithURL:[NSURL fileURLWithPath:pdfPath]];
    if (pdfDocument) {
        // PDF文档加载成功
        for (NSUInteger pageIndex = 0; pageIndex < pdfDocument.pageCount; pageIndex++) {
            PDFPage *pdfPage = [pdfDocument pageAtIndex:pageIndex];
            // 获取PDF页面的矩形区域
            CGRect pageRect = [pdfPage boundsForBox:kPDFDisplayBoxMediaBox];
            
            {
                CGFloat max = MAX(pageRect.size.width, pageRect.size.height);
                if (max < 2000) {
                    if (pageRect.size.width > pageRect.size.height) {
                        CGFloat width = 2000.0;
                        CGFloat height = width / (pageRect.size.width / pageRect.size.height);
                        pageRect.size = CGSizeMake(width, height);
                    }else {
                        CGFloat height = 2000.0;
                        CGFloat width = height * (pageRect.size.width / pageRect.size.height);
                        pageRect.size = CGSizeMake(width, height);
                    }
                }
            }
            
            // 使用PDF页面创建一个CGImageRef
            UIImage *pageImage = ([pdfPage thumbnailOfSize:pageRect.size forBox:kPDFDisplayBoxMediaBox]);
            
            CGFloat width = 595;
            CGFloat height = 841;
            CGFloat sc = 0.02;
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0.0);
            [pageImage drawInRect:CGRectMake(sc*width, sc*height, (1 - sc*2) * width, (1 - sc*2) * height)];
            pageImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            if (pageImage) {
                [imageArray addObject:pageImage];
            }
        }
    }
    
    return imageArray;
}

- (void)convertImages2Project:(NSArray <UIImage *>*)imageArray {
    @weakify(self);
    HZProjectModel *project = [HZProjectManager createProjectWithFolderId:Default_folderId isTmp:YES];
    project.title = [[[self.webView.URL.absoluteString hz_fileName] stringByRemovingPercentEncoding] stringByRemovingPercentEncoding];
    [HZProjectManager addPagesWithImages:imageArray inProject:project completeBlock:^(NSArray<HZPageModel *> *pages) {
        [HZPDFMaker generatePDFWithProject:project completeBlock:^(NSString *pdfPath) {
            @strongify(self);
            [HZProjectManager migratePagesFromProject:project toProject:nil keepOrigin:NO completeBlock:^(HZProjectModel *project) {
                @strongify(self);
                [self.convertingView completeConvertingWithBlock:^{
                    @strongify(self);
                    if (self.completeBlock) {
                        self.completeBlock(project);
                    }
                }];
            }];
        }];
        
    }];
}

- (void)makeProjectWithPdfPath:(NSString *)pdfFilePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:pdfFilePath]) {
        NSArray *arr = [self convertPdf2Images:pdfFilePath];
        if (arr.count == 0) {
            if (self.completeBlock) {
                self.completeBlock(nil);
            }
        }else {
            [self convertImages2Project:arr];
        }
    }else {
        if (self.completeBlock) {
            self.completeBlock(nil);
        }
    }
}

- (void)test {
    UIPrintPageRenderer *render = [[UIPrintPageRenderer alloc] init];
    [render addPrintFormatter:self.webView.viewPrintFormatter startingAtPageAtIndex:0];//关联对象
    NSUInteger contentHeight = self.webView.scrollView.contentSize.height;
    NSUInteger contentWidth = self.webView.scrollView.contentSize.width;
    CGSize contentSize = CGSizeMake(contentWidth, contentHeight);
    //  需要打印的frame
    CGRect printableRect = CGRectMake(0,
                                      0,
                                      contentSize.width,
                                      contentSize.height);
    // 纸张的规格
    CGRect paperRect = CGRectMake(0, 0, contentSize.width, contentSize.height);
    [render setValue:[NSValue valueWithCGRect:paperRect] forKey:@"paperRect"]; //因为是readonly属性，所以我们只能用KVC 进行赋值
    [render setValue:[NSValue valueWithCGRect:printableRect] forKey:@"printableRect"];
    NSData *pdfData = [self test_printToPDF:render];
    NSString *fileUrl = [NSString stringWithFormat:@"%@testtemp.pdf",NSTemporaryDirectory()];
    [pdfData writeToFile:fileUrl atomically: YES];
}

- (NSData*) test_printToPDF:(UIPrintPageRenderer *)render {
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData( pdfData, render.paperRect, nil );
    [render prepareForDrawingPages: NSMakeRange(0, render.numberOfPages)];
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    for ( int i = 0 ; i < render.numberOfPages ; i++ ) {
        UIGraphicsBeginPDFPage();
        [render drawPageAtIndex: i inRect: bounds];
    }
    UIGraphicsEndPDFContext();
    return pdfData;
}

@end
