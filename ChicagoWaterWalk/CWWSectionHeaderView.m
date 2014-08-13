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

#import "CWWSectionHeaderView.h"

@implementation CWWSectionHeaderView

- (void)awakeFromNib
{
    // set the selected image for the disclosure button
    [self.disclosureButton setImage:[UIImage imageNamed:@"carat-open.png"] forState:UIControlStateSelected];
    
    // set up the tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(toggleOpen:)];
    [self addGestureRecognizer:tapGesture];
}

- (IBAction)toggleOpen:(id)sender {
    
    [self toggleOpenWithUserAction:YES];
}

- (void)toggleOpenWithUserAction:(BOOL)userAction {
    
    // toggle the disclosure button state
    self.disclosureButton.selected = !self.disclosureButton.selected;
    
    // if this was a user action, send the delegate the appropriate message
    if (userAction) {
        if (self.disclosureButton.selected) {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
                [self.delegate sectionHeaderView:self sectionOpened:self.section];
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
                [self.delegate sectionHeaderView:self sectionClosed:self.section];
            }
        }
    }
}

@end
