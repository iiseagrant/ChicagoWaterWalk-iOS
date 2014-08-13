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

#import "CWWPoiViewController.h"
#import "CWWRoute.h"
#import "CWWPoi.h"
#import "CWWPoiCell.h"
#import "CWWAnnotation.h"
#import "CWWAnnotationView.h"
#import "CWWMainTopicViewController.h"
#import "MKMapView+ZoomLevel.h"


@interface CWWPoiViewController () {
    CWWRoute *currentRoute;
    CWWPoi *selectedPoi;
}

@end

@implementation CWWPoiViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    currentRoute = (CWWRoute *)self.routeList[self.routeIdx];
    [self setTitle:NSLocalizedString(currentRoute.name, currentRoute.name)];
    
    if (self.selectedSegmentControl) {
        self.segmentedControl.selectedSegmentIndex = self.selectedSegmentControl;
    }
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            // grid
            self.gridView.hidden = NO;
            self.mapView.hidden = YES;
            break;
        case 1:
            // map
            self.gridView.hidden = YES;
            self.mapView.hidden = NO;
            break;
        default:
            break;
    }

    [self updateMap];
}

-(void)viewWillAppear:(BOOL)animated {
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
    return [currentRoute.pois count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CWWPoiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"poiCell" forIndexPath:indexPath];
    
    CWWPoi *poi = currentRoute.pois[indexPath.row];
    cell.accessibilityTraits = UIAccessibilityTraitButton |
                               UIAccessibilityTraitImage;
    cell.accessibilityLabel = NSLocalizedString(poi.name, poi.name);
    
    UIImage *poiImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", poi.name]];
    cell.poiImage.image = poiImage;
    // Added left-padding to the label
    cell.poiTitle.text = [NSString stringWithFormat:@" %@", NSLocalizedString(poi.name, poi.name)];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    selectedPoi = currentRoute.pois[indexPath.row];
    [self performSegueWithIdentifier:@"showMainTopic" sender:self];
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
        [self centerMap:[userLocation coordinate] andZoom:currentRoute.zoom];
    }
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    // annotation
    CWWAnnotation *ann = (CWWAnnotation *)view.annotation;
    
    // poi
    selectedPoi = (CWWPoi *)ann.location;
    
    // deselect
    [mapView deselectAnnotation:ann animated:YES];
    
    // trigger segue
    [self performSegueWithIdentifier:@"showMainTopic" sender:self];
}

#pragma mark - Other

- (void)updateMap
{
    currentRoute = (CWWRoute *)self.routeList[self.routeIdx];
    
    [self setTitle:NSLocalizedString(currentRoute.name, currentRoute.name)];
    
    [self centerMap];
    
    // Display pois
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    CWWAnnotation *ann;
    for (CWWPoi *poi in currentRoute.pois) {
        ann = [[CWWAnnotation alloc] initWithName:NSLocalizedString(poi.name, poi.name)
                                         Position:poi.coordinates];
        ann.location = poi;
        [annotations addObject:ann];
    }
    [self.mapView addAnnotations:annotations];
}

- (void)centerMap
{
    [self centerMap:currentRoute.coordinates andZoom:currentRoute.zoom];
}

- (void)centerMap: (CLLocationCoordinate2D) centerPoint
          andZoom:(NSUInteger) toLevel
{
    [self.mapView setCenterCoordinate:centerPoint
                            zoomLevel:toLevel
                             animated:NO];
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

- (IBAction)findMe:(id)sender {
    [self.mapView setShowsUserLocation:YES];
}

- (IBAction)restoreMap:(id)sender {
    [self.mapView setShowsUserLocation:NO];
    [self centerMap];
}

- (IBAction)gotoPrevRoute:(id)sender {
    // If first route, go to last route. Otherwise, go to previous route.
    if (self.routeIdx == 0) {
        self.routeIdx = (int)self.routeList.count - 1;
    } else {
        self.routeIdx--;
    }
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self updateMap];
    [self.gridView reloadData];
}

- (IBAction)gotoNextRoute:(id)sender {
    // If last route, go to first route. Otherwise, go to next route.
    if (self.routeIdx == self.routeList.count - 1) {
        self.routeIdx = 0;
    } else {
        self.routeIdx++;
    }
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self updateMap];
    [self.gridView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMainTopic"]) {
        [[segue destinationViewController] setCurrentPoi:selectedPoi];
        [[segue destinationViewController] setZoom:currentRoute.zoom];
        [[segue destinationViewController] setShowListButton:NO];
        
        // Deselect the selected item in grid view
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            NSIndexPath *indexPath = [self.gridView indexPathsForSelectedItems][0];
            [self.gridView deselectItemAtIndexPath:indexPath animated:NO];
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
