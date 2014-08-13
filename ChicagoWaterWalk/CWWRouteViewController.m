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

#import "CWWRouteViewController.h"
#import "CWWRouteCell.h"
#import "CWWAppDelegate.h"
#import "CWWDataManager.h"
#import "CWWRoute.h"
#import "CWWAnnotation.h"
#import "CWWAnnotationView.h"
#import "CWWPoiViewController.h"
#import "MKMapView+ZoomLevel.h"
#import "SWRevealViewController.h"

@interface CWWRouteViewController () {
    CWWDataManager *dataManager;
    NSArray *routeList;
    CWWRoute *selectedRoute;
    int selectedRouteIdx;
}
@end

@implementation CWWRouteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Load routes
    CWWAppDelegate *appDelegate = (CWWAppDelegate *)[[UIApplication sharedApplication] delegate];
    dataManager = appDelegate.dataManager;
    routeList = dataManager.routes;
    
    // Set list button action
    self.listButton.target = self.revealViewController;
    self.listButton.action = @selector(revealToggle:);
    self.listButton.accessibilityHint = @"Double-tap to open sidebar menu";
    
    // Display grid view initially
    self.gridView.hidden = NO;
    self.mapView.hidden = YES;
    
    // Center map
    [self centerMap];
    
    // Display routes
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    CWWAnnotation *ann;
    for (CWWRoute *route in routeList) {
        ann = [[CWWAnnotation alloc] initWithName:NSLocalizedString(route.name, route.name)
                                         Position:route.coordinates];
        ann.location = route;
        [annotations addObject:ann];
    }
    [self.mapView addAnnotations:annotations];
}

-(void)viewWillAppear:(BOOL)animated {
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];

    // Show/hide toolbar
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            // grid
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

#pragma mark - Collection view data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [routeList count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CWWRouteCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"routeCell" forIndexPath:indexPath];

    CWWRoute *route = routeList[indexPath.row];
    cell.accessibilityTraits = UIAccessibilityTraitButton |
                               UIAccessibilityTraitImage;
    cell.accessibilityLabel = NSLocalizedString(route.name, route.name);
    
    UIImage *routeImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", route.name]];
    cell.routeImage.image = routeImage;
    // Added left-padding to the label
    cell.routeTitle.text = [NSString stringWithFormat:@" %@", NSLocalizedString(route.name, route.name)];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    selectedRoute = routeList[indexPath.row];
    [self performSegueWithIdentifier:@"showPoiView" sender:self];
}

#pragma mark - Map view delegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *identifier = @"mapPin";
    
    // if the placemark is the user's location, we just let the system handle that
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    CWWAnnotationView *view = (CWWAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (view == nil) {
        view = [[CWWAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    return view;
}

- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation: (MKUserLocation *)userLocation {
    
    if( userLocation.location.horizontalAccuracy <= 0 ) {
        return;
    } else {
        [self centerMap:[userLocation coordinate] andZoom:dataManager.zoom];
    }
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    // annotation
    CWWAnnotation *ann = (CWWAnnotation *)view.annotation;
    
    // route
    selectedRoute = (CWWRoute *)ann.location;
    
    // deselect
    [mapView deselectAnnotation:ann animated:YES];
    
    // trigger segue
    [self performSegueWithIdentifier:@"showPoiView" sender:self];
}

#pragma mark - Other

- (void)centerMap
{
    [self centerMap:dataManager.coordinates andZoom:dataManager.zoom];
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
            self.gridView.hidden = NO;
            self.mapView.hidden = YES;
            [self.navigationController setToolbarHidden:YES];
            break;
        case 1:
            // map
            self.gridView.hidden = YES;
            self.mapView.hidden = NO;
            [self.navigationController setToolbarHidden:NO];
            break;
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showPoiView"]) {
        selectedRouteIdx = 0;
        for (CWWRoute *route in routeList) {
            if ([route isEqual:selectedRoute]) {
                break;
            }
            selectedRouteIdx++;
        }
        [[segue destinationViewController] setRouteList:routeList];
        [[segue destinationViewController] setRouteIdx:selectedRouteIdx];
        [[segue destinationViewController] setSelectedSegmentControl:self.segmentedControl.selectedSegmentIndex];
        
        // Deselect the selected item in grid view
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            NSIndexPath *indexPath = [self.gridView indexPathsForSelectedItems][0];
            [self.gridView deselectItemAtIndexPath:indexPath animated:NO];
        }
    } else if ([[segue identifier] isEqualToString:@"showAboutList"]) {
        [[segue destinationViewController] setAboutCount:dataManager.aboutCount];
        [self.navigationController setToolbarHidden:YES];
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
