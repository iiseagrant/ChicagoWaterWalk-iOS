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

#import "CWWDataManager.h"
#import "CWWPoi.h"
#import "CWWRoute.h"

@interface CWWDataManager ()
- (void)initializeDataFromPlist;
@end

@implementation CWWDataManager

- (void)initializeDataFromPlist {

    NSString *appDataFile = [[NSBundle mainBundle]
                        pathForResource:@"AppData" ofType:@"plist"];
    NSDictionary *appData = [[NSDictionary alloc] initWithContentsOfFile:appDataFile];
    
    // Set no. of rows for the About screen
    self.aboutCount = [[appData objectForKey:@"About Count"] integerValue];
    
    // Set zoom
    self.zoom = [[appData objectForKey:@"Zoom"] unsignedIntegerValue];
    // NSLog(@"Zoom => %u", self.zoom);

    // Set coordinates
    NSDictionary *rawCoord = [appData objectForKey:@"Coordinates"];
    self.coordinates = CLLocationCoordinate2DMake(
        [[rawCoord objectForKey:@"Latitude"] doubleValue], [[rawCoord objectForKey:@"Longitude"] doubleValue]);
    // NSLog(@"Latitude => %e", self.coordinates.latitude);
    // NSLog(@"Longitude => %e", self.coordinates.longitude);
        
    // Set routes
    NSMutableArray *routeList = [[NSMutableArray alloc] init];
    NSArray *rawRouteList = [appData objectForKey:@"Routes"];
    for (NSDictionary *rawRoute in rawRouteList) {
        CWWRoute *route = [[CWWRoute alloc] initWithName:[rawRoute objectForKey:@"Name"]];
        route.zoom = [[rawRoute objectForKey:@"Zoom"] unsignedIntegerValue];
        NSDictionary *rawRouteCoord = [rawRoute objectForKey:@"Coordinates"];
        route.coordinates = CLLocationCoordinate2DMake(
            [[rawRouteCoord objectForKey:@"Latitude"] doubleValue], [[rawRouteCoord objectForKey:@"Longitude"] doubleValue]);
        
        // Set pois withing each route
        NSMutableArray *poiList = [[NSMutableArray alloc] init];
        NSArray *rawPoiList = [rawRoute objectForKey:@"POIs"];
        for (NSDictionary *rawPoi in rawPoiList) {
            CWWPoi *poi = [[CWWPoi alloc] initWithName:[rawPoi objectForKey:@"Name"]];
            NSDictionary *rawPoiCoord = [rawPoi objectForKey:@"Coordinates"];
            poi.coordinates = CLLocationCoordinate2DMake(
                [[rawPoiCoord objectForKey:@"Latitude"] doubleValue], [[rawPoiCoord objectForKey:@"Longitude"] doubleValue]);
            poi.subTopicCount = [[rawPoi objectForKey:@"Sub Topic Count"] integerValue];
            [poiList addObject:poi];
        }
        route.pois = [NSArray arrayWithArray:poiList];
        
        [routeList addObject:route];
    }
    self.routes = [NSArray arrayWithArray:routeList];
}

- (id)init {
    if (self = [super init]) {
        [self initializeDataFromPlist];
        return self;
    }
    return nil;
}

@end
