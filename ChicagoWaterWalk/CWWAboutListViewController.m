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

#import "CWWAboutListViewController.h"
#import "CWWAboutDetailViewController.h"
#import "SVModalWebViewController.h"

@implementation CWWAboutListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    // Set an empty footer view to suppress the empty cells at bottom
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.aboutCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AboutCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Determine current about topic
    NSString *aboutTopic = [NSString stringWithFormat:@"ABOUT_%d", (int)indexPath.row + 1];
    
    // Set the main label of the cell
    cell.textLabel.text = NSLocalizedString(aboutTopic, aboutTopic);
    cell.imageView.image = [UIImage imageNamed:aboutTopic];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 1:
            [self showWebsite:@"http://www.iiseagrant.org"];
            break;
        case 2:
            [self showEmailDialog];
            break;
        case 3:
            [self showWebsite:@"https://www.facebook.com/ILINseagrant"];
            break;
        case 4:
            [self showWebsite:@"https://twitter.com/ILINSeaGrant"];
            break;
        default:
            [self performSegueWithIdentifier:@"showAboutDetail" sender:self];
            break;
    }
}

#pragma mark - Action
             
- (void) showWebsite: (NSString *) url
{
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:url];
	[self presentViewController:webViewController animated:YES completion:nil];
}

- (void) showEmailDialog
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* mailComposer = [[MFMailComposeViewController alloc] init];
        
        [mailComposer setMailComposeDelegate:self];
        [mailComposer setSubject:@"iOS App Feedback"];
        [mailComposer setToRecipients:[NSArray arrayWithObject:@"CWWMobileApp@uillinois.edu"]];
        
        [self presentViewController:mailComposer animated:YES completion:nil];
    } else {
        UIAlertView *myAlert = [[UIAlertView alloc]
                                initWithTitle:@"Error"
                                message:@"Cannot send email on this device."
                                delegate:nil
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil];
        [myAlert show];
    }
}

- (IBAction)share:(id)sender {
    // Set text to share
    NSString *iTunesLink = @"https://itunes.apple.com/us/app/chicago-water-walk/id778264032?mt=8";
    NSString *shareText = [NSString stringWithFormat:@"Sent from Chicago Water Walk. Get the app: %@", iTunesLink];
    
    // Set image to share
    UIImage *shareImage = [UIImage imageNamed:@"Share"];
    NSArray *activityItems = @[shareText, shareImage];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - Email

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAboutDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *selectedTopic = [NSString stringWithFormat:@"ABOUT_%d",
                                      (int)indexPath.row + 1];
        [[segue destinationViewController] setTopic:selectedTopic];
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
