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

#import "CWWAboutDetailViewController.h"
#import "NSString+ConvertingHTML.h"

@interface CWWAboutDetailViewController () {
    NSDictionary *voiceOverDict;
}

@end

@implementation CWWAboutDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Define VoiceOver dictionary so that VoiceOver can read keys character by character
    voiceOverDict = @{@"NA12NOS4190105": @"NA12N-OS4190105", @"ICHi-": @"I-CH-i"};
	
    [self setTitle:NSLocalizedString(self.topic, self.topic)];
    
    NSString *webFilePath = [[NSBundle mainBundle]
                                     pathForResource:self.topic
                                     ofType:@"html"];
    NSString *webContents = [NSString stringWithContentsOfFile:webFilePath
                                                              encoding:NSUTF8StringEncoding
                                                                 error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [self.webView loadHTMLString:webContents baseURL:baseURL];
    
    [self.webView setIsAccessibilityElement:YES];
    
    // Add accessibility label with corrected VoiceOver pronunciations
    NSString *accessibilityContents = [webContents convertHTMLBodyToText];
    for (NSString *word in voiceOverDict) {
        accessibilityContents = [accessibilityContents stringByReplacingOccurrencesOfString:word withString:voiceOverDict[word]];
    }
    self.webView.accessibilityLabel = accessibilityContents;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
