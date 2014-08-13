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

#import "CWWImageViewController.h"

@implementation CWWImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navItem setTitle:NSLocalizedString(self.imageName, self.imageName)];

    self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", self.imageName]];
    self.imageView.isAccessibilityElement = YES;
    self.imageView.accessibilityTraits = UIAccessibilityTraitImage;
    self.imageView.accessibilityLabel = NSLocalizedString(self.imageName, self.imageName);
        
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavbar:)];
    [self.view addGestureRecognizer:tapGesture];
}

-(void) showHideNavbar:(id) sender
{
    if (self.navBar.hidden == NO) {
        self.navBar.hidden = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:NO];
        self.view.backgroundColor = [UIColor blackColor];
    } else {
        self.navBar.hidden = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:NO];
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    [self.delegate imageViewControllerDidFinish:self];
}

#pragma mark - Orientation

-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
