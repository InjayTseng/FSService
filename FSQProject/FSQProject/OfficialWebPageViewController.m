//
//  OfficialWebPageViewController.m
//  FSQProject
//
//  Created by David Tseng on 2/12/14.
//  Copyright (c) 2014 David Tseng. All rights reserved.
//

#import "OfficialWebPageViewController.h"
#import "SVProgressHUD.h"

@interface OfficialWebPageViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *wbView;

@end

@implementation OfficialWebPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.wbView.delegate = self;
    [self.wbView loadRequest:request];
    
	// Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated{

    [SVProgressHUD dismiss];
}
- (void)webViewDidStartLoad:(UIWebView *)webViewP{

    [SVProgressHUD showWithStatus:@"讀取中"];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{

    
    [SVProgressHUD showSuccessWithStatus:@"完成"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
