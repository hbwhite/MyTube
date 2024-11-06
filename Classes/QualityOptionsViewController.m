//
//  QualityOptionsViewController.m
//  MyTube
//
//  Created by Harrison White on 5/9/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "QualityOptionsViewController.h"

// Needed for kAdUnitID
#import "MyTubeAppDelegate.h"

static NSString *kSection1SelectedRowKey				= @"Quality Settings Section 1 Selected Row";
static NSString *kSection2SelectedRowKey				= @"Quality Settings Section 2 Selected Row";

static NSString *kBestQualityTitleStr					= @"Best Quality";
static NSString *kStandardDefinitionTitleStr			= @"Standard Definition";
static NSString *kPromptTitleStr						= @"Prompt";

static NSString *kBestQualitySubtitleSuffixStr			= @" in the best available quality.";
static NSString *kStandardDefinitionSubtitleSuffixStr	= @" in standard definition.";
static NSString *kPromptSubtitleStr						= @"If applicable, choose the video quality.";

@implementation QualityOptionsViewController

@synthesize theTableView;
@synthesize isAdObserver;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)adDidLoad {
	theTableView.frame = CGRectMake(0, 0, 320, 317);
}

- (void)adDidFailLoad {
	theTableView.frame = CGRectMake(0, 0, 320, 367);
}

- (void)viewWillAppear:(BOOL)animated {
	if (!isAdObserver) {
		isAdObserver = YES;
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(adDidLoad) name:kAdDidLoadNotification object:nil];
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(adDidFailLoad) name:kAdDidFailLoadNotification object:nil];
		if (![[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]bannerViewContainer]isHidden]) {
			[self adDidLoad];
		}
	}
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Streaming";
	}
	else {
		return @"Downloading";
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	
	NSString *verb = (indexPath.section == 0) ? @"Stream" : @"Download";
	
	if (indexPath.row == 0) {
		cell.textLabel.text = kBestQualityTitleStr;
		cell.detailTextLabel.text = [verb stringByAppendingString:kBestQualitySubtitleSuffixStr];
	}
	else if (indexPath.row == 1) {
		cell.textLabel.text = kStandardDefinitionTitleStr;
		cell.detailTextLabel.text = [verb stringByAppendingString:kStandardDefinitionSubtitleSuffixStr];
	}
	else {
		cell.textLabel.text = kPromptTitleStr;
		cell.detailTextLabel.text = kPromptSubtitleStr;
	}
	
	if (indexPath.section == 0) {
		if (indexPath.row == [[NSUserDefaults standardUserDefaults]integerForKey:kSection1SelectedRowKey]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
		else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
	else {
		if (indexPath.row == [[NSUserDefaults standardUserDefaults]integerForKey:kSection2SelectedRowKey]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
		else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *key = (indexPath.section == 0) ? kSection1SelectedRowKey : kSection2SelectedRowKey;
	if (indexPath.row == [defaults integerForKey:key]) {
		return;
	}
	NSInteger previousRow = 0;
	previousRow = [defaults integerForKey:key];
	[defaults setInteger:indexPath.row forKey:key];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:previousRow inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end
