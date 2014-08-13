/*
 * Copyright (C) 2014 The Illinois-Indiana Sea Grant
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "CWWSubTopicViewController.h"
#import "CWWImageViewController.h"
#import "SVModalWebViewController.h"

@interface CWWSubTopicViewController () {
    CGFloat imageViewHeight;
    NSString *linkName;
}

@end

@implementation CWWSubTopicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIScrollView *scrollView = self.subTopicView;
    [scrollView setFrame:[[UIScreen mainScreen] bounds]];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    scrollView.contentSize = CGSizeMake(screenSize.width, screenSize.height);
    
    // Create image view
    UIImage *subTopicImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", self.currentSubTopic]];
    UIImageView *subTopicImageView = [[UIImageView alloc] initWithImage:subTopicImage];
    subTopicImageView.isAccessibilityElement = YES;
    subTopicImageView.accessibilityTraits = UIAccessibilityTraitImage;
    NSString *imageName = [NSString stringWithFormat:@"%@_IMAGE", self.currentSubTopic];
    subTopicImageView.accessibilityLabel = NSLocalizedString(imageName, nil);
    imageViewHeight = subTopicImageView.frame.size.height;
    
    // Create Web view
    UIWebView *subTopicWebView = [[UIWebView alloc] init];
    subTopicWebView.delegate = self;
    [subTopicWebView.scrollView setScrollEnabled:NO];
    [subTopicWebView.scrollView setBounces:NO];
    [subTopicWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:self.currentSubTopic ofType:@"html"]]]];
    
    // Set initial frame of webview
    [subTopicWebView setFrame:CGRectMake(0, imageViewHeight, screenSize.width, screenSize.height)];
    
    // Add both image and web view to UIScrollView
    [self.subTopicView addSubview:subTopicImageView];
    [self.subTopicView addSubview:subTopicWebView];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Navigation bar belongs to the page view controller
    [self.parentViewController.navigationItem setTitle:NSLocalizedString(self.currentSubTopic, nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // Determine the height of UIWebView after it finishes loading
    CGRect webFrame = webView.frame;
    CGFloat webViewheight = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollHeight"] floatValue];
    webFrame.size.height = webViewheight;
    webView.frame = webFrame;
    
    // Adjust contentSize of UIScrollView
    CGSize scrollContenSize = self.subTopicView.contentSize;
    scrollContenSize.height = imageViewHeight + webViewheight;
    self.subTopicView.contentSize = scrollContenSize;
}

- (BOOL)                webView: (UIWebView*) aWebView
     shouldStartLoadWithRequest: (NSURLRequest*) request
                 navigationType: (UIWebViewNavigationType) navigationType
{
    NSURL *url = [request URL];
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        
        if ([[url scheme] isEqualToString:@"http"]) {
            [self gotoHttp:url];
        }  else {
            linkName = [[request URL] lastPathComponent];
            [self performSegueWithIdentifier:@"showLink" sender:self];
        }
        return NO;
    } else {
        return YES;
    }
}

- (void) gotoHttp: (NSURL *) url
{
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:url];
	[self presentViewController:webViewController animated:YES completion:nil];
}

- (void)imageViewControllerDidFinish:(CWWImageViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showLink"]) {
        [[segue destinationViewController] setImageName:linkName];
        [[segue destinationViewController] setDelegate:self];
    }
}

#pragma mark - Orientation

-(BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
