//
//  ListViewController.m
//  MyTube
//
//  Created by Harrison White on 7/23/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "ListViewController.h"

// Needed for kCountryCodesArray.
// Needed in order to observe when ads load or fail to load.
#import "MyTubeAppDelegate.h"

@interface ListViewController ()

@property (nonatomic, assign) IBOutlet UITableView *theTableView;
@property (nonatomic, assign) NSString *_tableHeaderTitle;
@property (nonatomic, assign) NSMutableArray *optionsArray;
@property (nonatomic, assign) NSMutableArray *optionSubtitlesArray;
@property (nonatomic, assign) NSMutableArray *correspondingValuesArray;
@property (nonatomic, assign) NSMutableString *_selectedOption;
@property (nonatomic) NSInteger selectedOptionIndex;
@property (readwrite) BOOL isAdObserver;

- (void)updateSelectedOptionIndex;
- (void)adDidLoad;
- (void)adDidFailLoad;

@end

@implementation ListViewController

@synthesize delegate;
@synthesize theTableView;
@synthesize _tableHeaderTitle;
@synthesize optionsArray;
@synthesize optionSubtitlesArray;
@synthesize correspondingValuesArray;
@synthesize _selectedOption;
@synthesize selectedOptionIndex;
@synthesize isAdObserver;

- (void)setTableHeaderTitle:(NSString *)tableHeaderTitle {
	_tableHeaderTitle = tableHeaderTitle;
	[theTableView reloadData];
}

- (void)setOptions:(NSArray *)options {
	[optionsArray setArray:options];
	[theTableView reloadData];
}

- (void)setOptionSubtitles:(NSArray *)optionSubtitles {
	[optionSubtitlesArray setArray:optionSubtitles];
	[theTableView reloadData];
}

- (void)setCorrespondingValues:(NSArray *)correspondingValues {
	[correspondingValuesArray setArray:correspondingValues];
	[self updateSelectedOptionIndex];
	[theTableView reloadData];
}

- (void)setSelectedOption:(NSString *)selectedOption {
	[_selectedOption setString:selectedOption];
	[self updateSelectedOptionIndex];
	[theTableView reloadData];
}

- (void)updateSelectedOptionIndex {
	for (int i = 0; i < [correspondingValuesArray count]; i++) {
		if ([[correspondingValuesArray objectAtIndex:i]isEqualToString:_selectedOption]) {
			selectedOptionIndex = i;
			break;
		}
	}
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	optionsArray = [[NSMutableArray alloc]init];
	optionSubtitlesArray = [[NSMutableArray alloc]init];
	correspondingValuesArray = [[NSMutableArray alloc]init];
	_selectedOption = [[NSMutableString alloc]init];
	return self;
}

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return _tableHeaderTitle;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [optionsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL isDetailCell = ([optionSubtitlesArray count] > indexPath.row);
	
    /* static */ NSString *CellIdentifier = isDetailCell ? @"Cell 1" : @"Cell 2";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:isDetailCell ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	
	cell.textLabel.text = [optionsArray objectAtIndex:indexPath.row];
	if (isDetailCell) {
		cell.detailTextLabel.text = [optionSubtitlesArray objectAtIndex:indexPath.row];
	}
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.textLabel.numberOfLines = 2;
	if (indexPath.row == selectedOptionIndex) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
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
	
	if (selectedOptionIndex != indexPath.row) {
		NSInteger previousSelectedOptionIndex = selectedOptionIndex;
		selectedOptionIndex = indexPath.row;
		if (delegate) {
			if ([delegate respondsToSelector:@selector(listViewControllerDidSelectOptionAtIndex:)]) {
				[delegate listViewControllerDidSelectOptionAtIndex:indexPath.row];
			}
		}
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:previousSelectedOptionIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	}
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
	self.optionsArray = nil;
	self.correspondingValuesArray = nil;
	self._selectedOption = nil;
}

- (void)dealloc {
	[optionsArray release];
	[correspondingValuesArray release];
	[_selectedOption release];
    [super dealloc];
}

@end
