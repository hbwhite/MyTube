//
//  SettingsViewController.m
//  MyTube
//
//  Created by Harrison White on 3/20/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "SettingsViewController.h"
#import "MyTubeAppDelegate.h"
#import "QualityOptionsViewController.h"
#import "AboutViewController.h"
#import "SegmentedControlCell.h"
#import "SwitchCell.h"
#import "DetailCell.h"

#import "NetworkStatusChangeNotifier.h"
#import "SA_OAuthTwitterEngine.h"

#define BACKGROUND_AUDIO_SWITCH_TAG								0
#define AUTO_REPLAY_SWITCH_TAG									1
#define RESUME_VIDEOS_SWITCH_TAG								2
#define DOWNLOAD_ALERTS_SWITCH_TAG								3
#define ICON_BADGE_SWITCH_TAG									4

/*
#define DEFAULT_SWITCH_COLOR_RED								0
#define DEFAULT_SWITCH_COLOR_GREEN								0.75
#define DEFAULT_SWITCH_COLOR_BLUE								0
*/

#define COUNTRY_INDEX											0
#define LANGUAGE_INDEX											1

#define COUNTRIES_ARRAY											[NSArray arrayWithObjects:@"All Countries", @"United States", @"الأرجنتين", @"Australia", @"Brazil", @"Canadà", @"Czech Republic", @"France", @"Deutschland", @"United Kingdom", @"Hong Kong Sar China", @"India", @"Ireland", @"Israel", @"Italia", @"Japan", @"Mexico", @"Nederland", @"New Zealand", @"Polska", @"Россия", @"South Africa", @"South Korea", @"España", @"Sweden", @"Taiwan", nil]
#define COUNTRY_SUBTITLES_ARRAY									[NSArray arrayWithObjects:@"Do not filter based on country.", @"United States", @"Argentina", @"Australia", @"Brazil", @"Canada", @"Czech Republic", @"France", @"Germany", @"United Kingdom", @"Hong Kong Sar China", @"India", @"Ireland", @"Israel", @"Italy", @"Japan", @"Mexico", @"Netherlands", @"New Zealand", @"Poland", @"Russia", @"South Africa", @"South Korea", @"Spain", @"Sweden", @"Taiwan", nil]

#define LANGUAGES_ARRAY											[NSArray arrayWithObjects:@"All Languages", @"English", @"Français", @"Deutsch", @"日本語", @"Nederlands", @"Italiano", @"Español", @"Português", /* @"Português", */ @"Dansk", @"Suomi", @"Norsk Bokmål", @"Svenska", @"한국어", @"中文", @"中文", @"Русский", @"Polski", @"Türkçe", @"Українська", @"العربية", @"Hrvatski", @"Čeština", @"Ελληνικά", @"עברית", @"Română", @"Slovenčina", @"ไทย", @"Bahasa Indonesia", @"Bahasa Melayu", /* @"English (United Kingdom)", */ @"Català", @"Magyar", @"Tiếng Việt", nil]
#define LANGUAGE_SUBTITLES_ARRAY								[NSArray arrayWithObjects:@"Do not filter based on language.", @"English", @"French", @"German", @"Japanese", @"Dutch", @"Italian", @"Spanish", @"Portuguese", /* @"Portuguese", */ @"Danish", @"Finnish", @"Norwegian Bokmål", @"Swedish", @"Korean", @"Simplified Chinese", @"Traditional Chinese", @"Russian", @"Polish", @"Turkish", @"Ukrainian", @"Arabic", @"Croatian", @"Czech", @"Greek", @"Hebrew", @"Romanian", @"Slovak", @"Thai", @"Indonesian", @"Malay", /* @"English (United Kingdom)", */ @"Catalan", @"Hungarian", @"Vietnamese", nil]

static NSString *kTwitterAuthenticationDataKey					= @"Twitter Authentication Data";

static NSString *kCountryCodeKey								= @"Country Code";
static NSString *kLanguageCodeKey								= @"Language Code";
static NSString *kNullStr										= @"";

// static NSString *kOtherTitleStr								= @"Other";

static NSString *kMinimumSwitchTintColorFirmwareVersion			= @"5.0";

static NSString *kBackgroundAudioKey							= @"Background Audio";
static NSString *kAutoReplayKey									= @"Auto Replay";
static NSString *kResumeVideosKey								= @"Resume Videos";
static NSString *kDownloadAlertsKey								= @"Download Alerts";
static NSString *kIconBadgeKey									= @"Icon Badge";

static NSString *kCountrySelectTitleStr							= @"Country";
static NSString *kLanguageSelectTitleStr						= @"Language";

static NSString *kFacebookImageTitleStr							= @"Facebook";
static NSString *kFacebookSelectedImageTitleStr					= @"Facebook-Selected";

static NSString *kTwitterImageTitleStr							= @"Twitter";
static NSString *kTwitterSelectedImageTitleStr					= @"Twitter-Selected";

static NSString *kRepoURLStr									= @"http://www.harrisonapps.com/repo";
static NSString *kWebsiteURLStr									= @"http://www.harrisonapps.com";
static NSString *kFacebookURLStr								= @"http://www.facebook.com/harrisonapps";
static NSString *kTwitterURLStr									= @"http://www.twitter.com/harrisonapps";

@implementation SettingsViewController

@synthesize theTableView;
@synthesize countryTitle;
@synthesize languageTitle;
@synthesize localizationSelectedRow;
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
	if (countryTitle) {
		[countryTitle release];
		countryTitle = nil;
	}
	if (languageTitle) {
		[languageTitle release];
		languageTitle = nil;
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *revisedCountryCodesArray = [[NSArray arrayWithObject:kNullStr]arrayByAddingObjectsFromArray:kCountryCodesArray];
	for (int i = 0; i < [revisedCountryCodesArray count]; i++) {
		if ([[revisedCountryCodesArray objectAtIndex:i]isEqualToString:[defaults objectForKey:kCountryCodeKey]]) {
			countryTitle = [[COUNTRIES_ARRAY objectAtIndex:i]retain];
			break;
		}
	}
	/*
	if (!countryTitle) {
		countryTitle = [kOtherTitleStr retain];
	}
	*/
	NSArray *revisedLanguagesArray = [[NSArray arrayWithObject:kNullStr]arrayByAddingObjectsFromArray:kLanguageCodesArray];
	for (int i = 0; i < [revisedLanguagesArray count]; i++) {
		if ([[revisedLanguagesArray objectAtIndex:i]isEqualToString:[defaults objectForKey:kLanguageCodeKey]]) {
			languageTitle = [[LANGUAGES_ARRAY objectAtIndex:i]retain];
			break;
		}
	}
	/*
	if (!languageTitle) {
		languageTitle = [kOtherTitleStr retain];
	}
	*/
	[theTableView reloadData];
	
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
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	
	switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			return 2;
			break;
		case 2:
			return 1;
			break;
		case 3:
			return 1;
			break;
		case 4:
			return 1;
			break;
		case 5:
			return 1;
			break;
		case 6:
			return 2;
			break;
		case 7:
			return 4;
			break;
		case 8:
		{
			if (([[[UIDevice currentDevice]systemVersion]compare:@"5.0"] != NSOrderedAscending) && (NSClassFromString(@"TWTweetComposeViewController"))) {
				return 1;
			}
			else {
				return 2;
			}
		}
		case 9:
			return 1;
			break;
		default:
			return 0;
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Browsing Source";
	}
	else if (section == 8) {
		return @"Sign Out...";
	}
	else {
		return nil;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0) {
		return @"Allows you to browse the desktop or mobile version of YouTube.";
	}
	else if (section == 2) {
		return @"Continue where you left off on saved videos.";
	}
	else if (section == 3) {
		return @"Notifies you when videos finish downloading if the app is running in the background.";
	}
	else if (section == 4) {
		return @"Badge the app icon with the number of downloads.";
	}
	else if (section == 6) {
		return @"Country and language settings apply only to the videos listed by the app.";
	}
	else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 43;
	}
	else {
		return 44;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		static NSString *CellIdentifier = @"Cell 1";
        
        SegmentedControlCell *cell = (SegmentedControlCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[SegmentedControlCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
        }
        
        // Configure the cell...
		
		return cell;
	}
	else if (indexPath.section < 5) {
		/* static */ NSString *CellIdentifier = nil;
		
		if ((indexPath.section == 1) && (indexPath.row == 0)) {
			CellIdentifier = @"Cell 2";
		}
		else {
			CellIdentifier = @"Cell 3";
		}
        
        SwitchCell *cell = (SwitchCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[SwitchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
        }
        
        // Configure the cell...
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
		if ((indexPath.section == 1) && (indexPath.row == 0)) {
			cell.textLabel.text = @"Background Audio";
			cell.imageView.image = [UIImage imageNamed:@"Audio"];
			cell.cellSwitch.tag = BACKGROUND_AUDIO_SWITCH_TAG;
			cell.cellSwitch.on = [defaults boolForKey:kBackgroundAudioKey];
			if ([[[UIDevice currentDevice]systemVersion]compare:kMinimumSwitchTintColorFirmwareVersion] != NSOrderedAscending) {
				cell.cellSwitch.onTintColor = [UIColor orangeColor];
			}
		}
		else {
			if (indexPath.section == 1) {
				cell.textLabel.text = @"Auto Replay";
				cell.imageView.image = [UIImage imageNamed:@"Replay"];
				cell.cellSwitch.tag = AUTO_REPLAY_SWITCH_TAG;
				cell.cellSwitch.on = [defaults boolForKey:kAutoReplayKey];
			}
			else if (indexPath.section == 2) {
				cell.textLabel.text = @"Resume Videos";
				cell.imageView.image = [UIImage imageNamed:@"Resume"];
				cell.cellSwitch.tag = RESUME_VIDEOS_SWITCH_TAG;
				cell.cellSwitch.on = [defaults boolForKey:kResumeVideosKey];
			}
			else if (indexPath.section == 3) {
				cell.textLabel.text = @"Download Alerts";
				cell.imageView.image = [UIImage imageNamed:@"Alerts"];
				cell.cellSwitch.tag = DOWNLOAD_ALERTS_SWITCH_TAG;
				cell.cellSwitch.on = [defaults boolForKey:kDownloadAlertsKey];
			}
			else if (indexPath.section == 4) {
				cell.textLabel.text = @"Icon Badge";
				cell.imageView.image = [UIImage imageNamed:@"Badge"];
				cell.cellSwitch.tag = ICON_BADGE_SWITCH_TAG;
				cell.cellSwitch.on = [defaults boolForKey:kIconBadgeKey];
			}
			/*
			if ([[[UIDevice currentDevice]systemVersion]compare:kMinimumSwitchTintColorFirmwareVersion] != NSOrderedAscending) {
				cell.cellSwitch.onTintColor = [UIColor colorWithRed:DEFAULT_SWITCH_COLOR_RED green:DEFAULT_SWITCH_COLOR_GREEN blue:DEFAULT_SWITCH_COLOR_BLUE alpha:1];
			}
			*/
		}
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		[cell.cellSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
		cell.imageView.backgroundColor = [UIColor clearColor];
		
        return cell;
    }
	else if (indexPath.section == 6) {
		static NSString *CellIdentifier = @"Cell 5";
		
		DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[DetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		}
		
		// Configure the cell...
		
		if (indexPath.row == 0) {
			cell.textLabel.text = kCountrySelectTitleStr;
			cell.detailLabel.text = countryTitle;
		}
		else {
			cell.textLabel.text = kLanguageSelectTitleStr;
			cell.detailLabel.text = languageTitle;
		}
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		
		return cell;
	}
	else {
		/* static */ NSString *CellIdentifier = nil;
		if (indexPath.section == 5) {
			CellIdentifier = @"Cell 4";
		}
		else if (indexPath.section == 7) {
			CellIdentifier = @"Cell 6";
		}
		else if (indexPath.section == 8) {
			CellIdentifier = @"Cell 7";
		}
		else {
			CellIdentifier = @"Cell 8";
		}
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc]initWithStyle:(indexPath.section == 7) ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		}
		
		// Configure the cell...
		
		if (indexPath.section == 5) {
			cell.textLabel.text = @"Quality Options";
			cell.imageView.image = [UIImage imageNamed:@"Quality_Options"];
			cell.imageView.highlightedImage = [UIImage imageNamed:@"Quality_Options-Selected"];
		}
		else if (indexPath.section == 7) {
			if (indexPath.row == 0) {
                cell.textLabel.text = @"Add Our Repo";
                cell.detailTextLabel.text = @"harrisonapps.com/repo";
                cell.imageView.image = [UIImage imageNamed:@"Repo"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"Repo-Selected"];
            }
            else if (indexPath.row == 1) {
                cell.textLabel.text = @"Visit Our Website";
                cell.detailTextLabel.text = @"harrisonapps.com";
                cell.imageView.image = [UIImage imageNamed:@"Website"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"Website-Selected"];
            }
            else if (indexPath.row == 2) {
				cell.textLabel.text = @"Like Our Facebook Page";
				cell.detailTextLabel.text = @"facebook.com/harrisonapps";
				cell.imageView.image = [UIImage imageNamed:kFacebookImageTitleStr];
				cell.imageView.highlightedImage = [UIImage imageNamed:kFacebookSelectedImageTitleStr];
			}
			else {
				cell.textLabel.text = @"Follow Us on Twitter";
				cell.detailTextLabel.text = @"twitter.com/harrisonapps";
				cell.imageView.image = [UIImage imageNamed:kTwitterImageTitleStr];
				cell.imageView.highlightedImage = [UIImage imageNamed:kTwitterSelectedImageTitleStr];
			}
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else if (indexPath.section == 8) {
			if (indexPath.row == 0) {
				cell.textLabel.text = @"Facebook";
				cell.imageView.image = [UIImage imageNamed:kFacebookImageTitleStr];
				cell.imageView.highlightedImage = [UIImage imageNamed:kFacebookSelectedImageTitleStr];
			}
			else {
				cell.textLabel.text = @"Twitter";
				cell.imageView.image = [UIImage imageNamed:kTwitterImageTitleStr];
				cell.imageView.highlightedImage = [UIImage imageNamed:kTwitterSelectedImageTitleStr];
			}
			cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		}
		else if (indexPath.section == 9) {
			cell.textLabel.text = @"About";
			cell.imageView.image = [UIImage imageNamed:@"About"];
			cell.imageView.highlightedImage = [UIImage imageNamed:@"About-Selected"];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		cell.imageView.backgroundColor = [UIColor clearColor];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	}
}

- (void)switchValueChanged:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	UISwitch *theSwitch = sender;
	if (theSwitch.tag == BACKGROUND_AUDIO_SWITCH_TAG) {
		[defaults setBool:theSwitch.on forKey:kBackgroundAudioKey];
	}
	else if (theSwitch.tag == AUTO_REPLAY_SWITCH_TAG) {
		[defaults setBool:theSwitch.on forKey:kAutoReplayKey];
	}
	else if (theSwitch.tag == RESUME_VIDEOS_SWITCH_TAG) {
		[defaults setBool:theSwitch.on forKey:kResumeVideosKey];
	}
	else if (theSwitch.tag == DOWNLOAD_ALERTS_SWITCH_TAG) {
		[defaults setBool:theSwitch.on forKey:kDownloadAlertsKey];
	}
	else {
		[defaults setBool:theSwitch.on forKey:kIconBadgeKey];
	}
	[defaults synchronize];
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
	
	if (indexPath.section == 5) {
		QualityOptionsViewController *qualityOptionsViewController = [[QualityOptionsViewController alloc]initWithNibName:@"QualityOptionsViewController" bundle:nil];
		qualityOptionsViewController.title = @"Quality Options";
		[self.navigationController pushViewController:qualityOptionsViewController animated:YES];
		[qualityOptionsViewController release];
	}
	else if (indexPath.section == 6) {
		localizationSelectedRow = indexPath.row;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		ListViewController *listViewController = [[ListViewController alloc]initWithNibName:@"ListViewController" bundle:nil];
		listViewController.delegate = self;
		if (indexPath.row == 0) {
			listViewController.title = kCountrySelectTitleStr;
			[listViewController setTableHeaderTitle:kCountrySelectTitleStr];
			[listViewController setOptions:COUNTRIES_ARRAY];
			[listViewController setOptionSubtitles:COUNTRY_SUBTITLES_ARRAY];
			[listViewController setCorrespondingValues:[[NSArray arrayWithObject:kNullStr]arrayByAddingObjectsFromArray:kCountryCodesArray]];
			[listViewController setSelectedOption:[defaults objectForKey:kCountryCodeKey]];
		}
		else {
			listViewController.title = kLanguageSelectTitleStr;
			[listViewController setTableHeaderTitle:kLanguageSelectTitleStr];
			[listViewController setOptions:LANGUAGES_ARRAY];
			[listViewController setOptionSubtitles:LANGUAGE_SUBTITLES_ARRAY];
			[listViewController setCorrespondingValues:[[NSArray arrayWithObject:kNullStr]arrayByAddingObjectsFromArray:kLanguageCodesArray]];
			[listViewController setSelectedOption:[defaults objectForKey:kLanguageCodeKey]];
		}
		[self.navigationController pushViewController:listViewController animated:YES];
		[listViewController release];
	}
	else if (indexPath.section == 7) {
		if (indexPath.row == 0) {
            NSString *title = nil;
            if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                title = @"Add our official repo to your sources to get access to our other apps and stay up-to-date on future versions of MyTube:\n\nharrisonapps.com/repo\n\nTake note of the repo URL above,\nthen press the button below to launch Cydia and add it as a source.";
            }
            else {
                title = @"Add our official repo to your sources to get access to our other apps and stay up-to-date on future versions of MyTube:\n\nharrisonapps.com/repo\n\nTake note of the repo URL above, then press the button below to launch Cydia and add it as a source.";
            }
            UIActionSheet *addRepoActionSheet = [[UIActionSheet alloc]
                                                 initWithTitle:title
                                                 delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 destructiveButtonTitle:nil
                                                 otherButtonTitles:@"Launch Cydia", @"More Info", nil];
            addRepoActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [addRepoActionSheet showInView:[(ContainerViewController *)[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]rootViewController]view]];
            [addRepoActionSheet release];
        }
        else {
            NSString *url = nil;
            if (indexPath.row == 1) {
                url = kWebsiteURLStr;
            }
            else if (indexPath.row == 2) {
                url = kFacebookURLStr;
            }
            else {
                url = kTwitterURLStr;
            }
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
		}
	}
	else if (indexPath.section == 8) {
		if (indexPath.row == 0) {
			MyTubeAppDelegate *delegate = (MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate];
			Facebook *facebook = delegate.facebook;
			[facebook logout:delegate];
		}
		else if (indexPath.row == 1) {
			BOOL didSignOut = NO;
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			if ([[defaults stringForKey:kTwitterAuthenticationDataKey]length] > 0) {
				[defaults removeObjectForKey:kTwitterAuthenticationDataKey];
				[defaults synchronize];
				didSignOut = YES;
			}
			SA_OAuthTwitterEngine *twitterEngine = [(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]twitterEngine];
			if (twitterEngine) {
				if ([twitterEngine respondsToSelector:@selector(clearAccessToken)]) {
					[twitterEngine clearAccessToken];
				}
			}
			if (didSignOut) {
				UIAlertView *signOutSuccessfulAlert = [[UIAlertView alloc]
													   initWithTitle:@"Sign Out Successful"
													   message:@"You have successfully signed out of Twitter."
													   delegate:nil
													   cancelButtonTitle:@"OK"
													   otherButtonTitles:nil];
				[signOutSuccessfulAlert show];
				[signOutSuccessfulAlert release];
			}
			else {
				UIAlertView *alreadySignedOutAlert = [[UIAlertView alloc]
													  initWithTitle:@"Already Signed Out"
													  message:@"You are already signed out of Twitter."
													  delegate:nil
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
				[alreadySignedOutAlert show];
				[alreadySignedOutAlert release];
			}
		}
	}
	else if (indexPath.section == 9) {
		AboutViewController *aboutViewController = [[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
		aboutViewController.title = @"About";
		[self.navigationController pushViewController:aboutViewController animated:YES];
		[aboutViewController release];
	}
}

- (void)listViewControllerDidSelectOptionAtIndex:(NSInteger)index {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (localizationSelectedRow == COUNTRY_INDEX) {
		if (index == 0) {
			[defaults setObject:kNullStr forKey:kCountryCodeKey];
		}
		else {
			[defaults setObject:[kCountryCodesArray objectAtIndex:(index - 1)] forKey:kCountryCodeKey];
		}
	}
	else {
		if (index == 0) {
			[defaults setObject:kNullStr forKey:kLanguageCodeKey];
		}
		else {
			[defaults setObject:[kLanguageCodesArray objectAtIndex:(index - 1)] forKey:kLanguageCodeKey];
		}
	}
	[defaults synchronize];
	[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]clearCache];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.countryTitle = nil;
	self.languageTitle = nil;
}

- (void)dealloc {
	[countryTitle release];
	[languageTitle release];
    [super dealloc];
}

@end
