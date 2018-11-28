@import UIKit;

#import "FlutterFullPdfViewerPlugin.h"

@interface FlutterFullPdfViewerPlugin ()
@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;
@end

@implementation FlutterFullPdfViewerPlugin{
    FlutterResult _result;
    UIViewController <UIDocumentInteractionControllerDelegate> *_viewController;
    UIWebView *_webView;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_full_pdf_viewer"
                                     binaryMessenger:[registrar messenger]];
    
    UIViewController *viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    FlutterFullPdfViewerPlugin *instance = [[FlutterFullPdfViewerPlugin alloc] initWithViewController:viewController];
    
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return _viewController;
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
    }
    return self;
}

- (CGRect)parseRect:(NSDictionary *)rect {
    return CGRectMake([[rect valueForKey:@"left"] doubleValue],
                      [[rect valueForKey:@"top"] doubleValue],
                      [[rect valueForKey:@"width"] doubleValue],
                      [[rect valueForKey:@"height"] doubleValue]);
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (_result) {
        _result([FlutterError errorWithCode:@"multiple_request"
                                    message:@"Cancelled by a second request"
                                    details:nil]);
        _result = nil;
    }
    
    
    if ([@"launch" isEqualToString:call.method]) {
        NSDictionary *rect = call.arguments[@"rect"];
        NSString *path = call.arguments[@"path"];
        CGRect rc = [self parseRect:rect];
        if (_webView == nil){
            _webView = [[UIWebView alloc] initWithFrame:rc];
            NSURL *targetURL = [NSURL fileURLWithPath:path];
            NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
            [_webView loadRequest:request];
            _webView.scalesPageToFit = YES;
            _webView.backgroundColor = [UIColor whiteColor];
            [_webView setOpaque:NO];
            [_viewController.view addSubview:_webView];
        }
        
    }else if ([@"preview" isEqualToString:call.method]) {
        NSString *path = call.arguments[@"path"];
        NSURL *targetURL = [NSURL fileURLWithPath:path];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:targetURL];
        [self.documentInteractionController setDelegate:self];
        [self.documentInteractionController presentPreviewAnimated:YES];
        
    } else if ([@"resize" isEqualToString:call.method]) {
        if (_webView != nil) {
            NSDictionary *rect = call.arguments[@"rect"];
            CGRect rc = [self parseRect:rect];
            _webView.frame = rc;
        }
    } else if ([@"close" isEqualToString:call.method]) {
        [self closeWebView];
        result(nil);
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)closeWebView {
    if (_webView != nil) {
        [_webView stopLoading];
        [_webView removeFromSuperview];
        _webView = nil;
    }
}


@end