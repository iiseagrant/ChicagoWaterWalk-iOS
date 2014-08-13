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

#import "CWWSidebarViewController.h"
#import "SWRevealViewController.h"
#import "CWWMainTopicViewController.h"
#import "CWWAppDelegate.h"
#import "CWWDataManager.h"
#import "CWWRoute.h"
#import "CWWPoi.h"
#import "CWWSectionInfo.h"
#import "CWWSectionHeaderView.h"

static NSString *SectionHeaderViewIdentifier = @"SectionHeaderViewIdentifier";

@interface CWWSidebarViewController () {
    NSArray *routeList;
    NSArray *sectionInfoList;
    NSInteger openSectionIndex;
}

@end

#define DEFAULT_ROW_HEIGHT 88

@implementation CWWSidebarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    CWWAppDelegate *appDelegate = (CWWAppDelegate *)[[UIApplication sharedApplication] delegate];
    routeList = appDelegate.dataManager.routes;
    
    NSMutableArray *infoArray = [[NSMutableArray alloc] initWithCapacity:routeList.count];
    for (CWWRoute *route in routeList) {
        
        CWWSectionInfo *sectionInfo = [[CWWSectionInfo alloc] init];
        sectionInfo.route = route;
        sectionInfo.open = NO;
        
        [infoArray addObject:sectionInfo];
    }
    sectionInfoList = infoArray;
    
    openSectionIndex = NSNotFound;
    
    // Set an empty footer view to suppress the empty cells at bottom
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Register SectionHeaderView xib file
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"SectionHeaderView" bundle:nil];
    [self.tableView registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
    
    self.tableView.shouldGroupAccessibilityChildren = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
	[super viewWillAppear:animated];
    
    // Hide accessibility items on front view controller
    self.revealViewController.frontViewController.view.accessibilityElementsHidden = YES;
    
    /*
     Check whether the section info array has been created, and if so whether the section count still matches the current section count. In general, you need to keep the section info synchronized with the rows and section. If you support editing in the table view, you need to appropriately update the section info during editing operations.
     */
	if ((sectionInfoList == nil) ||
        ([sectionInfoList count] != [self numberOfSectionsInTableView:self.tableView])) {
        
        // For each route, set up a corresponding SectionInfo object to contain the default height for each row.
		NSMutableArray *infoArray = [[NSMutableArray alloc] init];
        
		for (CWWRoute *route in routeList) {
            
			CWWSectionInfo *sectionInfo = [[CWWSectionInfo alloc] init];
			sectionInfo.route = route;
			sectionInfo.open = NO;
            
            NSNumber *defaultRowHeight = @(DEFAULT_ROW_HEIGHT);
			NSInteger countOfPois = [[sectionInfo.route pois] count];
			for (NSInteger i = 0; i < countOfPois; i++) {
				[sectionInfo insertObject:defaultRowHeight inRowHeightsAtIndex:i];
			}
            
			[infoArray addObject:sectionInfo];
		}
        
		sectionInfoList = infoArray;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return routeList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CWWSectionInfo *sectionInfo = sectionInfoList[section];
	NSInteger rowsInSection = sectionInfo.route.pois.count;
    
    return sectionInfo.open ? rowsInSection : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PoiCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    CWWRoute *route = routeList[indexPath.section];
    CWWPoi *poi = route.pois[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"        %@", NSLocalizedString(poi.name, poi.name)];

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CWWSectionHeaderView *sectionHeaderView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:SectionHeaderViewIdentifier];
    
    CWWSectionInfo *sectionInfo = sectionInfoList[section];
    sectionInfo.headerView = sectionHeaderView;
    
    sectionHeaderView.routeLabel.text = NSLocalizedString(sectionInfo.route.name, sectionInfo.route.name);
    [sectionHeaderView.routeLabel sizeToFit];
    
    sectionHeaderView.routeIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_ICON", sectionInfo.route.name]];
    
    sectionHeaderView.section = section;
    sectionHeaderView.delegate = self;
    sectionHeaderView.isAccessibilityElement = YES;
    sectionHeaderView.accessibilityTraits = UIAccessibilityTraitButton;
    sectionHeaderView.accessibilityLabel = NSLocalizedString(sectionInfo.route.name, sectionInfo.route.name);
    NSString *hintText = @"Double-tap to toggle list of point of interests";
    sectionHeaderView.accessibilityHint = NSLocalizedString(hintText, hintText);
    
    return sectionHeaderView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showPoi" sender:self];
}

#pragma mark - SectionHeaderViewDelegate

- (void)sectionHeaderView:(CWWSectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
    
	CWWSectionInfo *sectionInfo = sectionInfoList[sectionOpened];
    
	sectionInfo.open = YES;
    
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each poi in the current section.
     */
    NSInteger countOfRowsToInsert = [sectionInfo.route.pois count];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }
    
    /*
     Create an array containing the index paths of the rows to delete: These correspond to the rows for each poi in the previously-open section, if there was one.
     */
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    
    NSInteger previousOpenSectionIndex = openSectionIndex;
    if (previousOpenSectionIndex != NSNotFound) {
        
		CWWSectionInfo *previousOpenSection = sectionInfoList[previousOpenSectionIndex];
        previousOpenSection.open = NO;
        [previousOpenSection.headerView toggleOpenWithUserAction:NO];
        NSInteger countOfRowsToDelete = [previousOpenSection.route.pois count];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        }
    }
    
    // style the animation so that there's a smooth flow in either direction
    UITableViewRowAnimation insertAnimation;
    UITableViewRowAnimation deleteAnimation;
    if (previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex) {
        insertAnimation = UITableViewRowAnimationTop;
        deleteAnimation = UITableViewRowAnimationBottom;
    }
    else {
        insertAnimation = UITableViewRowAnimationBottom;
        deleteAnimation = UITableViewRowAnimationTop;
    }
    
    // apply the updates
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
    [self.tableView endUpdates];
    
    openSectionIndex = sectionOpened;
    
    // Force focus to go to section header.
    // Otherwise it may go to a point of interest that is not first in the list.
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, sectionHeaderView);
}

- (void)sectionHeaderView:(CWWSectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
	CWWSectionInfo *sectionInfo = sectionInfoList[sectionClosed];
    
    sectionInfo.open = NO;
    NSInteger countOfRowsToDelete = [self.tableView numberOfRowsInSection:sectionClosed];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationNone];
    }
    openSectionIndex = NSNotFound;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Show accessibility items on front view controller
    self.revealViewController.frontViewController.view.accessibilityElementsHidden = NO;
    
    if ([segue.identifier isEqualToString:@"showPoi"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CWWRoute *route = routeList[indexPath.section];
        CWWPoi *poi = route.pois[indexPath.row];
        [[segue destinationViewController] setCurrentPoi:poi];
        [[segue destinationViewController] setZoom:route.zoom];
        [[segue destinationViewController] setShowListButton:YES];
    }
    
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] )
    {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc)
        {
            UINavigationController* nc = (UINavigationController*)self.revealViewController.frontViewController;
            [nc setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
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
