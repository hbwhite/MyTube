//
//  VideosViewController.m
//  MyTube
//
//  Created by Harrison White on 3/2/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "VideosViewController.h"
#import "MyTubeAppDelegate.h"

#define ROW_HEIGHT							90

static NSString *kFilePathExtensionStr		= @"mp4";
static NSString *kDownloadPathExtensionStr	= @"download";

static NSString *kEntityNameStr				= @"Video";
static NSString *kCacheNameStr				= @"VideoCache";

static NSString *kStringFormatSpecifierStr	= @"%@";
static NSString *kSizeFormatStr				= @"%@ MB";

static NSString *kDecimalStr				= @".";
static NSString *kTenthAppendStr			= @"0";
static NSString *kWholeNumberAppendStr		= @".00";

static NSString *kDurationKey				= @"duration";
static NSString *kFileNameKey				= @"fileName";
static NSString *kQualityKey				= @"quality";
static NSString *kSizeKey					= @"size";
static NSString *kSubmitterKey				= @"submitter";
static NSString *kThumbnailKey				= @"thumbnail";
static NSString *kTitleKey					= @"title";
static NSString *kVideoIDKey				= @"videoID";

@interface VideosViewController ()

@property (nonatomic, assign) IBOutlet UITableView *theTableView;
@property (nonatomic, assign) UIBarButtonItem *editButton;
@property (nonatomic, assign) NSManagedObject *pendingVideo;
@property (readwrite) BOOL searching;
@property (readwrite) BOOL viewIsVisible;
@property (readwrite) BOOL isAdObserver;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)editButtonPressed;
- (void)adDidLoad;
- (void)adDidFailLoad;
- (NSString *)filePathForVideo:(NSManagedObject *)video;
- (NSString *)downloadPathForVideo:(NSManagedObject *)video;
- (BOOL)fileExistsForVideo:(NSManagedObject *)video;
- (void)configureCell:(DownloadedVideoCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (NSString *)stringFromDecimalNumber:(NSDecimalNumber *)decimalNumber;
- (void)abortWithError:(NSError *)error;
- (UITableView *)currentTableView;
- (NSFetchedResultsController *)fetchedResultsController;
- (void)performFetch;
- (NSString *)applicationDataStorageDirectory;
- (NSString *)applicationDocumentsDirectory;
- (void)didFinishSearching;

@end

@implementation VideosViewController

@synthesize theTableView;
@synthesize editButton;
@synthesize pendingVideo;
@synthesize searching;
@synthesize viewIsVisible;
@synthesize isAdObserver;

@synthesize fetchedResultsController;
@synthesize managedObjectContext;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	editButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonPressed)];
	self.navigationItem.rightBarButtonItem = editButton;
	
	theTableView.rowHeight = ROW_HEIGHT;
	
	managedObjectContext = [(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
	
	[NSFetchedResultsController deleteCacheWithName:kCacheNameStr];
	[self performFetch];
}

- (void)editButtonPressed {
	if (theTableView.editing) {
		[theTableView setEditing:NO animated:YES];
		editButton.title = @"Edit";
		editButton.style = UIBarButtonItemStyleBordered;
	}
	else {
		[theTableView setEditing:YES animated:YES];
		editButton.title = @"Done";
		editButton.style = UIBarButtonItemStyleDone;
	}
}

- (void)adDidLoad {
	theTableView.frame = CGRectMake(0, 0, 320, 317);
}

- (void)adDidFailLoad {
	theTableView.frame = CGRectMake(0, 0, 320, 367);
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
	tableView.rowHeight = ROW_HEIGHT;
}

- (void)viewWillAppear:(BOOL)animated {	
	/*
	// If this is implemented, the file extensions MUST remain constant or the app be modified to handle the changes
	// so as to prevent unnecessary deletion of video files.
	NSArray *fetchedObjectsArray = [[self fetchedResultsController]fetchedObjects];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	for (NSString *fileName in [fileManager contentsOfDirectoryAtPath:[self applicationDocumentsDirectory] error:nil]) {
		BOOL videoExistsForFile = NO;
		for (int i = 0; i < [fetchedObjectsArray count]; i++) {
			if ([[[[fetchedObjectsArray objectAtIndex:i]valueForKey:kFileNameKey]stringByAppendingPathExtension:kFilePathExtensionStr]isEqualToString:fileName]) {
				videoExistsForFile = YES;
				break;
			}
		}
		if (!videoExistsForFile) {
			[fileManager removeItemAtPath:[[self applicationDocumentsDirectory]stringByAppendingPathComponent:fileName] error:nil];
		}
	}
	*/
	
	/*
	NSManagedObjectContext *context = [[self fetchedResultsController]managedObjectContext];
	for (NSManagedObject *video in [[self fetchedResultsController]fetchedObjects]) {
		if (![self fileExistsForVideo:video]) {
			[context deleteObject:video];
		}
	}
	if ([context hasChanges]) {
		// Save the context.
		NSError *error = nil;
		if (![context save:&error]) {
			[self abortWithError:error];
		}
	}
	*/
	
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

- (NSString *)filePathForVideo:(NSManagedObject *)video {
	return [[self applicationDocumentsDirectory]stringByAppendingPathComponent:[[video valueForKey:kFileNameKey]stringByAppendingPathExtension:kFilePathExtensionStr]];
}

- (NSString *)downloadPathForVideo:(NSManagedObject *)video {
	return [[self applicationDataStorageDirectory]stringByAppendingPathComponent:[[video valueForKey:kFileNameKey]stringByAppendingPathExtension:kDownloadPathExtensionStr]];
}

- (BOOL)fileExistsForVideo:(NSManagedObject *)video {
	return (([[NSFileManager defaultManager]fileExistsAtPath:[self filePathForVideo:video]]) || ([[NSFileManager defaultManager]fileExistsAtPath:[self downloadPathForVideo:video]]));
}


- (void)viewDidAppear:(BOOL)animated {
	viewIsVisible = YES;
	[super viewDidAppear:animated];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/

- (void)viewDidDisappear:(BOOL)animated {
	viewIsVisible = NO;
	[super viewDidDisappear:animated];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ROW_HEIGHT;
}

- (void)configureCell:(DownloadedVideoCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *video = [fetchedResultsController objectAtIndexPath:indexPath];
	cell.thumbnailImageView.image = [UIImage imageWithData:[video valueForKey:kThumbnailKey]];
	cell.titleLabel.text = [video valueForKey:kTitleKey];
    cell.qualityLabel.text = [MetadataLoader stringForQuality:[[video valueForKey:kQualityKey]integerValue]];
    cell.sizeLabel.text = [NSString stringWithFormat:kSizeFormatStr, [self stringFromDecimalNumber:[video valueForKey:kSizeKey]]];
	cell.durationLabel.text = [video valueForKey:kDurationKey];
    cell.submitterLabel.text = [video valueForKey:kSubmitterKey];
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
}

- (NSString *)stringFromDecimalNumber:(NSDecimalNumber *)decimalNumber {
	NSMutableString *formattedDecimalNumber = [NSMutableString stringWithFormat:kStringFormatSpecifierStr, decimalNumber];
	if ([formattedDecimalNumber rangeOfString:kDecimalStr].length > 0) {
		if ([[[formattedDecimalNumber componentsSeparatedByString:kDecimalStr]lastObject]length] < 2) {
			[formattedDecimalNumber appendString:kTenthAppendStr];
		}
	}
	else {
		[formattedDecimalNumber appendString:kWholeNumberAppendStr];
	}
	/*
	if ([formattedDecimalNumber rangeOfString:kDecimalStr].length <= 0) {
		[formattedDecimalNumber appendString:kWholeNumberAppendStr];
	}
	*/
	return [NSString stringWithString:formattedDecimalNumber];
}

- (void)abortWithError:(NSError *)error {
	/*
	Replace this implementation with code to handle the error appropriately.
	abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	*/
	
	NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	abort();
}

#pragma mark -
#pragma mark Table view data source

- (UITableView *)currentTableView {
	if (searching) {
		if ([self.searchDisplayController.searchBar.text length] > 0) {
			return self.searchDisplayController.searchResultsTableView;
		}
		else {
			return theTableView;
		}
	}
	else {
		return theTableView;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return [[fetchedResultsController sections]count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections]objectAtIndex:section];
	NSInteger numberOfObjects = [sectionInfo numberOfObjects];
	return numberOfObjects;
}

// - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	/*
	if ([self.searchDisplayController.searchBar.text length] > 0) {
		NSInteger fetchedObjectsCount = [[[self fetchedResultsController]fetchedObjects]count];
		if (fetchedObjectsCount > 0) {
			return [NSString stringWithFormat:@"Search Results (%i)", fetchedObjectsCount];
		}
		else {
			return @"Search Results (None)";
		}
	 }
	 else {
	 */
		// id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController]sections]objectAtIndex:section];
		// return [sectionInfo name];
	// }
// }

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	DownloadedVideoCell *cell = (DownloadedVideoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[DownloadedVideoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
	}
	
	// Configure the cell...
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return YES;
}
*/

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
	
	if (fetchedResultsController != nil) {
		return fetchedResultsController;
	}
	
	/*
	 Set up the fetched results controller.
	 */
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityNameStr inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:kTitleKey ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:kCacheNameStr];
	aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}

- (void)performFetch {
	NSError *error = nil;
	if (![[self fetchedResultsController]performFetch:&error]) {
		[self abortWithError:error];
	}
}

#pragma mark -
#pragma mark Fetched results controller delegate

/*
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[[self currentTableView]beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[[self currentTableView]insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[[self currentTableView]deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	
	UITableView *tableView = [self currentTableView];
	
	if (indexPath) {
		// [tableView beginUpdates];
		
		switch(type) {
				
			case NSFetchedResultsChangeInsert:
				[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeDelete:
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeUpdate:
				[self configureCell:(DownloadedVideoCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
				break;
				
			case NSFetchedResultsChangeMove:
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
				break;
		}
		
		[tableView endUpdates];
	}
	else {
		[tableView endUpdates];
		[tableView reloadData];
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[[self currentTableView]endUpdates];
}
*/

// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// In the simplest, most efficient, case, reload the table view.
	[[self currentTableView]reloadData];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the managed object for the given index path
		
        NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
        NSManagedObject *video = [[self fetchedResultsController]objectAtIndexPath:indexPath];
		if ([self fileExistsForVideo:video]) {
			[[NSFileManager defaultManager]removeItemAtPath:[[self applicationDocumentsDirectory]stringByAppendingPathComponent:[[video valueForKey:kFileNameKey]stringByAppendingPathExtension:kFilePathExtensionStr]] error:nil];
		}
		[context deleteObject:video];
		
		// Save the context.
		NSError *error = nil;
		if (![context save:&error]) {
			[self abortWithError:error];
		}
	}   
	else if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
	}   
}

- (NSString *)applicationDataStorageDirectory {
	// return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	return @"/private/var/mobile/Library/MyTube/";
}

- (NSString *)applicationDocumentsDirectory {
	// return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	return @"/private/var/mobile/Media/MyTube/";
}

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

#pragma mark -
#pragma mark Search bar delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self didFinishSearching];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	if ([searchBar.text length] <= 0) {
		[self didFinishSearching];
	}
}

- (void)didFinishSearching {
	if (searching) {
		searching = NO;
	}
	[self performFetch];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if ([searchText length] > 0) {
		if (!searching) {
			searching = YES;
		}
	}
	else if (searching) {
		searching = NO;
	}
	
	[NSFetchedResultsController deleteCacheWithName:kCacheNameStr];
	NSFetchRequest *fetchRequest = [[self fetchedResultsController]fetchRequest];
	if ((searching) && ([searchText length] > 0)) {
		NSString *formattedSearchText = [searchText stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
		NSString *titlePredicateFormat = [NSString stringWithFormat:@"%@ contains[cd] '%@'", kTitleKey, formattedSearchText];
		NSString *submitterPredicateFormat = [NSString stringWithFormat:@"%@ contains[cd] '%@'", kSubmitterKey, formattedSearchText];
		[fetchRequest setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(%@) OR (%@)", titlePredicateFormat, submitterPredicateFormat]]];
	}
	else {
		[fetchRequest setPredicate:nil];
	}
	
	[self performFetch];
	[[self currentTableView]reloadData];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    pendingVideo = [[self fetchedResultsController]objectAtIndexPath:indexPath];
	[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]presentOptionsActionSheetForVideoWithID:[pendingVideo valueForKey:kVideoIDKey] title:[pendingVideo valueForKey:kTitleKey]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (pendingVideo) {
		NSManagedObjectContext *context = [[self fetchedResultsController]managedObjectContext];
		[context deleteObject:pendingVideo];
		
		// Save the context.
		NSError *error = nil;
		if (![context save:&error]) {
			[self abortWithError:error];
		}
		
		pendingVideo = nil;
	}
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
	if (error) {
		UIAlertView *sendFailedAlert = [[UIAlertView alloc]
										initWithTitle:@"Send Failed"
										message:@"Your message could not be sent. This could be due to little or no Internet connectivity."
										delegate:self
										cancelButtonTitle:@"Cancel"
										otherButtonTitles:@"Retry", nil];
		sendFailedAlert.tag = 0;
		[sendFailedAlert show];
		[sendFailedAlert release];
	}
}

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
	NSManagedObject *video = [[self fetchedResultsController]objectAtIndexPath:indexPath];
	if ([self fileExistsForVideo:video]) {
		ContainerViewController *rootViewController = [(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]rootViewController];
		// rootViewController.delegate = self;
		[rootViewController playVideoForEntity:video];
	}
	else {
		pendingVideo = video;
		UIAlertView *fileNotFoundAlert = [[UIAlertView alloc]
										  initWithTitle:@"File Not Found"
										  message:@"This video could not be played because the file it represents cannot be found. You may have accidentally deleted it through SSH or other means. Its alias will be removed automatically."
										  delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
		[fileNotFoundAlert show];
		[fileNotFoundAlert release];
	}
}

/*
- (NSManagedObject *)entityForNextVideo:(NSManagedObject *)currentVideo {
	NSInteger currentVideoIndex = 0;
	NSArray *fetchedObjectsArray = [[self fetchedResultsController]fetchedObjects];
	for (int i = 0; i < [fetchedObjectsArray count]; i++) {
		if ([[fetchedObjectsArray objectAtIndex:i]isEqual:currentVideo]) {
			currentVideoIndex = i;
			break;
		}
	}
	NSInteger nextVideoIndex = (currentVideoIndex + 1);
	if ([fetchedObjectsArray count] > nextVideoIndex) {
		return [fetchedObjectsArray objectAtIndex:nextVideoIndex];
	}
	else if ([fetchedObjectsArray count] > 1) {
		return [fetchedObjectsArray objectAtIndex:0];
	}
	else {
		return nil;
	}
}

- (NSManagedObject *)entityForPreviousVideo:(NSManagedObject *)currentVideo {
	NSInteger currentVideoIndex = 0;
	NSArray *fetchedObjectsArray = [[self fetchedResultsController]fetchedObjects];
	for (int i = 0; i < [fetchedObjectsArray count]; i++) {
		if ([[fetchedObjectsArray objectAtIndex:i]isEqual:currentVideo]) {
			currentVideoIndex = i;
			break;
		}
	}
	if (currentVideoIndex > 0) {
		return [fetchedObjectsArray objectAtIndex:(currentVideoIndex - 1)];
	}
	else if ([fetchedObjectsArray count] > 1) {
		return [fetchedObjectsArray lastObject];
	}
	else {
		return nil;
	}
}
*/

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	// Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	// For example: self.myOutlet = nil;
	
	self.editButton = nil;
	self.fetchedResultsController = nil;
	self.managedObjectContext = nil;
}



- (void)dealloc {
	[editButton release];
	[fetchedResultsController release];
	[managedObjectContext release];
	[super dealloc];
}


@end

