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

#import "CWWMainTopicViewController.h"
#import "CWWPoi.h"
#import "CWWAnnotation.h"
#import "CWWAnnotationView.h"
#import "CWWSubTopicPageViewController.h"
#import "MKMapView+ZoomLevel.h"
#import "SWRevealViewController.h"
#import "NSString+ConvertingHTML.h"

@interface CWWMainTopicViewController () {
    NSMutableArray *subtopicWebViewList;
}

@end

#define PREVIEW_TEXT_LENGTH 100

@implementation CWWMainTopicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Show or hide List button depending on where it is transitioned from
    if (self.showListButton) {
        [self.navigationItem setLeftBarButtonItem:self.listButton animated:NO];
    } else {
        [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    }
    
    // Set list button action.
    self.listButton.target = self.revealViewController;
    self.listButton.action = @selector(revealToggle:);
    self.listButton.accessibilityHint = @"Double-tap to open sidebar menu";
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
	
    [self setTitle:NSLocalizedString(self.currentPoi.name, self.currentPoi.name)];
    
    // Hide map view initially
    self.mapView.hidden = YES;
        
    // Load image view in table header view
    UIImage *poiImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_SUBTOPIC_1.jpg", self.currentPoi.name]];
    UIImageView *poiImageView = [[UIImageView alloc] initWithImage:poiImage];
    poiImageView.isAccessibilityElement = YES;
    poiImageView.accessibilityTraits = UIAccessibilityTraitImage;
    poiImageView.accessibilityLabel = NSLocalizedString(self.currentPoi.name, self.currentPoi.name);
    self.listView.tableHeaderView = poiImageView;
    
    // Set an empty footer view to suppress the empty cells at bottom
    self.listView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Configure map view
    [self centerMap];
    CWWAnnotation *ann = [[CWWAnnotation alloc] initWithName:NSLocalizedString(self.currentPoi.name, self.currentPoi.name) Position:self.currentPoi.coordinates];
    ann.location = self.currentPoi;
    [self.mapView addAnnotation:ann];
}

-(void)viewWillAppear:(BOOL)animated {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            // list
            [self.navigationController setToolbarHidden:YES];
            break;
        case 1:
            // map
            [self.navigationController setToolbarHidden:NO];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentPoi.subTopicCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SubTopicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Determine current poi sub topic
    NSString *currentPoiSubTopic = [NSString stringWithFormat:@"%@_SUBTOPIC_%d",
                                    self.currentPoi.name,
                                    (int)indexPath.row + 1];
    
    // Set the main label of the cell
    cell.textLabel.text = NSLocalizedString(currentPoiSubTopic, poiSubTopic);
    
    // Set the detail label of the cell
    NSString *subTopicWebFilePath = [[NSBundle mainBundle]
                                     pathForResource:currentPoiSubTopic
                                     ofType:@"html"];
    NSString *subTopicWebContents = [NSString stringWithContentsOfFile:subTopicWebFilePath
                                                              encoding:NSUTF8StringEncoding
                                                                 error:nil];
    cell.detailTextLabel.text = [[subTopicWebContents convertHTMLBodyToText] substringToIndex:PREVIEW_TEXT_LENGTH];
    
    return cell;
}

#pragma mark - Map view delegate

- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation: (MKUserLocation *)userLocation {
    
    if( userLocation.location.horizontalAccuracy <= 0 ) {
        return;
    } else {
        [self centerMap:[userLocation coordinate] andZoom:self.zoom];
    }
}

#pragma mark - Other

- (void)centerMap
{
    [self centerMap:self.currentPoi.coordinates andZoom:self.zoom];
}

- (void)centerMap: (CLLocationCoordinate2D) centerPoint
          andZoom:(NSUInteger) toLevel
{
    [self.mapView setCenterCoordinate:centerPoint
                            zoomLevel:toLevel
                             animated:NO];
}

- (IBAction)findMe:(id)sender {
    [self.mapView setShowsUserLocation:YES];
}

- (IBAction)restoreMap:(id)sender {
    [self.mapView setShowsUserLocation:NO];
    [self centerMap];
}

- (IBAction)segmentValueChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            // grid
            self.listView.hidden = NO;
            self.mapView.hidden = YES;
            [self.navigationController setToolbarHidden:YES];
            break;
        case 1:
            // map
            self.listView.hidden = YES;
            self.mapView.hidden = NO;
            [self.navigationController setToolbarHidden:NO];
            break;
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSubTopic"]) {
        NSIndexPath *indexPath = [self.listView indexPathForSelectedRow];
        [[segue destinationViewController] setCurrentPageIndex:indexPath.row];
        [[segue destinationViewController] setCurrentPoi:self.currentPoi];
        
        // Deselect the selected item in list view
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            [self.listView deselectRowAtIndexPath:indexPath animated:NO];
        }
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
