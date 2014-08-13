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

#import "CWWAnnotationView.h"
#import "CWWAnnotation.h"

@implementation CWWAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        
    self.enabled = YES;
    self.animatesDrop = NO;
    self.canShowCallout = YES;
    [self setAccessibilityTraits:UIAccessibilityTraitButton];
    UIButton* disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [disclosureButton setAccessibilityLabel:@"More Info"];
    [disclosureButton setAccessibilityTraits:UIAccessibilityTraitButton];
    self.rightCalloutAccessoryView = disclosureButton;
    
    return self;
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

@end
