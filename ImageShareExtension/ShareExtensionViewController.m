//
//  ShareExtensionViewController.m
//  ImageShareExtension
//
//  Created by hzy on 2024-03-18.
//

#import "ShareExtensionViewController.h"

@interface ShareExtensionViewController ()

@end

@implementation ShareExtensionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //https://blog.csdn.net/wujakf/article/details/120672102
    
    typeof(self) __weak weakSelf = self;
    void(^jump2ContainerApp)(void) = ^{
        NSURL *destinationURL = [NSURL URLWithString:@"convertpdf://"];
        // Get "UIApplication" class name through ASCII Character codes.
        NSString *className = [[NSString alloc] initWithData:[NSData dataWithBytes:(unsigned char []){0x55, 0x49, 0x41, 0x70, 0x70, 0x6C, 0x69, 0x63, 0x61, 0x74, 0x69, 0x6F, 0x6E} length:13] encoding:NSASCIIStringEncoding];
        if (NSClassFromString(className))
        {
            id object = [NSClassFromString(className) performSelector:@selector(sharedApplication)];
            [object performSelector:@selector(openURL:) withObject:destinationURL];
        }
        [weakSelf.extensionContext completeRequestReturningItems:nil completionHandler:nil];
    };
    
    {
        BOOL pdfFound = NO;
        NSString *uti = @"public.image";
//        NSString *appGroupIdentifier = @"group.com.hithink.scannerhd.ImportPDFAction";
//        NSString *pdfComponent = @"externalPDF.PDF";
        for (NSExtensionItem *item in self.extensionContext.inputItems) {
            for (NSItemProvider *itemProvider in item.attachments) {
                if ([itemProvider hasItemConformingToTypeIdentifier:uti]) {
                    // This is an image. We'll load it, then place it in our image view.
                    [itemProvider loadItemForTypeIdentifier:uti options:nil completionHandler:^(NSURL *item, NSError *error) {
                        if(item) {
//                            NSData *pdfData = [NSData dataWithContentsOfURL:item];
//                            NSURL * storeUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:appGroupIdentifier];
//                            NSURL * fileUrl = [storeUrl URLByAppendingPathComponent:pdfComponent];
//                            if (pdfData) {
//                                BOOL success = [pdfData writeToURL:fileUrl atomically:YES];
//                                if (success) {
//                                    
//                                }
//                            }
                        }
                        jump2ContainerApp();
                    }];

                    pdfFound = YES;
                    break;
                }
            }

            if (pdfFound) {
                // We only handle one image, so stop looking for more.
                break;
            }
        }
    }
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
