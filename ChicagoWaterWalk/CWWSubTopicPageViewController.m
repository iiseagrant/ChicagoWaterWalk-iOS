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

#import "CWWSubTopicPageViewController.h"
#import "CWWSubTopicViewController.h"

@interface CWWSubTopicPageViewController ()

@end

@implementation CWWSubTopicPageViewController

- (id<UIPageViewControllerDataSource>) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        self.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set background color. This is the color showen if you swipe past the first/last page.
    self.view.backgroundColor = [UIColor whiteColor];

    // Prevent subtopic view from extending under nav bar
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController.navigationBar setTranslucent:NO];
    
    CWWSubTopicViewController *currentViewController = [self viewControllerAtIndex:self.currentPageIndex];
    [self setViewControllers:@[currentViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CWWSubTopicViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if ((self.currentPoi.subTopicCount == 0) || (index >= self.currentPoi.subTopicCount)) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    CWWSubTopicViewController *subtopicViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SubTopicViewController"];
    NSString *selectedSubTopic = [NSString stringWithFormat:@"%@_SUBTOPIC_%d",
                                  self.currentPoi.name,
                                  (int)index + 1];
    subtopicViewController.currentSubTopic = selectedSubTopic;
    subtopicViewController.pageIndex = index;
    
    return subtopicViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((CWWSubTopicViewController *) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((CWWSubTopicViewController *) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == self.currentPoi.subTopicCount) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
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
