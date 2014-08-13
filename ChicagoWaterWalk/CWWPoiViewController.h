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

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CWWPoiViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *gridView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) NSArray *routeList;
@property int routeIdx;
@property NSInteger selectedSegmentControl;

- (IBAction)segmentValueChanged:(id)sender;
- (IBAction)findMe:(id)sender;
- (IBAction)restoreMap:(id)sender;
- (IBAction)gotoPrevRoute:(id)sender;
- (IBAction)gotoNextRoute:(id)sender;

@end