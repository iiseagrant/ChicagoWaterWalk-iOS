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

@protocol CWWSecionHeaderViewDelegate;

@interface CWWSectionHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UILabel *routeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *routeIcon;
@property (nonatomic, weak) IBOutlet UIButton *disclosureButton;
@property (nonatomic, weak) IBOutlet id <CWWSecionHeaderViewDelegate> delegate;
@property (nonatomic) NSInteger section;

- (void)toggleOpenWithUserAction:(BOOL)userAction;

@end

/*
 Protocol to be adopted by the section header's delegate; the section header tells its delegate when the section should be opened and closed.
 */
@protocol CWWSecionHeaderViewDelegate <NSObject>

@optional
- (void)sectionHeaderView:(CWWSectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section;
- (void)sectionHeaderView:(CWWSectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section;

@end