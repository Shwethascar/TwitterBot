//
//  TwitterTableViewController.m
//  TwitterBot
//
//  Created by Shwetha Gopalan on 2/6/15.
//  Copyright (c) 2015 Shwe. All rights reserved.
//

#import "TwitterTableViewController.h"
#import "Chameleon.h"
#import "ChameleonStatusBar.h"
#import "ChameleonMacros.h"
#import "TwitterTableViewCell.h"
#import "MBProgressHUD.h"
#import "CallManager.h"

@interface TwitterTableViewController ()

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSMutableDictionary *retweetButtonDictionary;
@property (nonatomic, strong) NSMutableDictionary *favoriteButtonDictionary;

@end

@implementation TwitterTableViewController
{
	id _tweetObserver;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tweets = [NSMutableArray array];
	
	// When OAuth is implemented, each retweet/favorite state can be persisted and fetched
	self.retweetButtonDictionary = [NSMutableDictionary dictionary];
	self.favoriteButtonDictionary = [NSMutableDictionary dictionary];
	
	self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
	self.HUD.mode = MBProgressHUDModeIndeterminate;
	[self.view addSubview:self.HUD];
	[self.HUD show:YES];
	
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.estimatedRowHeight = 518.0;
	
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:217.0/255.0 green:139.0/255.0 blue:122.0/255.0 alpha:1.0];
	
	[self registerObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	[self unregisterObservers];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TwitterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"twitterPost" forIndexPath:indexPath];
	
	NSString *index = [NSString stringWithFormat:@"%lu", indexPath.row];
	
	NSDictionary *tweetDictionary = self.tweets[indexPath.row];
	
	cell.name.text = tweetDictionary[@"name"];
	cell.handle.text = tweetDictionary[@"handle"];
	cell.since.text = tweetDictionary[@"since"];
	cell.tweetBody.text = tweetDictionary[@"tweet"];
	
	cell.retweets = [NSString stringWithFormat:@"%@", tweetDictionary[@"retweets"]];
	NSDictionary *retweetInfo = self.retweetButtonDictionary[index];
	if (retweetInfo == nil) {
		[cell.retweetButton setTitle:[NSString stringWithFormat:@"%@", tweetDictionary[@"retweets"]] forState:UIControlStateNormal & UIControlStateSelected];
		
		self.retweetButtonDictionary[index] = @{@"state" : [NSString stringWithFormat:@"%lu", UIControlStateNormal], @"retweets" : cell.retweets};
	}
	else {
		[cell.retweetButton setTitle:retweetInfo[@"retweets"] forState:UIControlStateNormal & UIControlStateSelected];
		BOOL selected = [retweetInfo[@"state"] isEqualToString:[NSString stringWithFormat:@"%lu", UIControlStateSelected]] ? YES : NO;
		[cell.retweetButton setSelected:selected];
	}
	
	if (cell.retweetButton.state == UIControlStateSelected) {
		cell.retweetButton.imageView.image = [UIImage imageNamed:@"retweet_highlight.png"];
		cell.retweetButton.titleLabel.textColor = [UIColor orangeColor];
	}
	else {
		cell.retweetButton.imageView.image = [UIImage imageNamed:@"retweet_normal.png"];
	}
	
	
	cell.favorites = [NSString stringWithFormat:@"%@", tweetDictionary[@"favorites"]];
	NSDictionary *favoritesInfo = self.favoriteButtonDictionary[index];
	if (favoritesInfo == nil) {
		[cell.favoriteButton setTitle:[NSString stringWithFormat:@"%@", tweetDictionary[@"favorites"]] forState:UIControlStateNormal & UIControlStateSelected];
		
		[cell.favoriteButton setSelected:NO];
		
		self.favoriteButtonDictionary[index] = @{@"state" : [NSString stringWithFormat:@"%lu", UIControlStateNormal], @"favorites" : cell.favorites};
	}
	else {
		[cell.favoriteButton setTitle:favoritesInfo[@"favorites"] forState:UIControlStateNormal & UIControlStateSelected];
		BOOL selected = [favoritesInfo[@"state"] isEqualToString:[NSString stringWithFormat:@"%lu", UIControlStateSelected]] ? YES : NO;
		[cell.favoriteButton setSelected:selected];
	}
	
	if (cell.favoriteButton.state == UIControlStateSelected) {
		cell.favoriteButton.imageView.image = [UIImage imageNamed:@"favorite_highlight.png"];
		cell.favoriteButton.titleLabel.textColor = [UIColor orangeColor];
	}
	else {
		cell.favoriteButton.imageView.image = [UIImage imageNamed:@"favorite_normal.png"];
	}
	
	cell.tweetImage.image = [UIImage imageNamed:@"placeholder.png"];
	cell.thumbnail.image = [UIImage imageNamed:@"placeholder.png"];
	
	NSURL *thumbnailURL = [NSURL URLWithString:tweetDictionary[@"thumbnailURL"]];
	NSURL *imageURL = [NSURL URLWithString:tweetDictionary[@"imageURL"]];
	
	NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
	
	if (imageURL) {
		NSURLSessionDataTask *imageTask = [session dataTaskWithURL:imageURL
												 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
													 if (!error) {
														 dispatch_async(dispatch_get_main_queue(), ^{
														 cell.tweetImage.image = [UIImage imageWithData:data];
														 });
													 }
												 }];
		[imageTask resume];
	}
	else {
		cell.tweetImage.image = nil;
	}
	
	if (thumbnailURL) {
		NSURLSessionDataTask *thumbnailTask = [session dataTaskWithURL:thumbnailURL
													 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
														 if (!error) {
															 dispatch_async(dispatch_get_main_queue(), ^{
																 cell.thumbnail.image = [UIImage imageWithData:data];
															 });
														 }
													 }];
		[thumbnailTask resume];
	}
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *tweetDict = self.tweets[indexPath.row];
	
	if (tweetDict[@"imageURL"])
	{
		return 518;
	}
	else {
		return 200;
	}
}

- (void)registerObservers {
	__weak typeof(self) weakSelf = self;
	
	_tweetObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"gotTweets"
																		 object:nil
																		  queue:nil
																	 usingBlock:^(NSNotification *note) {
																		 [weakSelf.HUD hide:YES];
																		 [weakSelf.HUD removeFromSuperview];
																		 [weakSelf.tableView reloadData];
																	 }];
}

- (void)unregisterObservers {
	[[NSNotificationCenter defaultCenter] removeObserver:_tweetObserver];
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)retweeted:(id)sender {
	__weak typeof(self) weakSelf = self;
	
	CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tableView];
	NSIndexPath *hitIndex = [self.tableView indexPathForRowAtPoint:hitPoint];
	
	NSDictionary *tweet = self.tweets[hitIndex.row];
	__block NSMutableDictionary *retweetInfo = [self.retweetButtonDictionary[[NSString stringWithFormat:@"%lu", hitIndex.row]] mutableCopy];
	
	__block UIButton *button = (UIButton *)sender;
	[[CallManager sharedCallManager] retweetWithID:tweet[@"id"] completionBlock:^(NSString *retweetCount) {
		// TODO: Change this when we actually call the POST APIs
		// NSUInteger retweetCountValue = [retweetCount integerValue];
		dispatch_async(dispatch_get_main_queue(), ^{
			NSUInteger retweetCountValue;
			
			if (![retweetInfo[@"state"] isEqualToString:[NSString stringWithFormat:@"%lu", UIControlStateSelected]]) {
				retweetCountValue  = [retweetInfo[@"retweets"] integerValue]+ 1;
			}
			else {
				retweetCountValue = [retweetInfo[@"retweets"] integerValue];
			}
			
			[button setSelected:YES];
			
			[weakSelf configureRetweetButton:button retweets:retweetCountValue];
			
			retweetInfo[@"state"] = [NSString stringWithFormat:@"%lu", UIControlStateSelected];
			retweetInfo[@"retweets"] = [NSString stringWithFormat:@"%lu", retweetCountValue];
			weakSelf.retweetButtonDictionary[[NSString stringWithFormat:@"%lu", hitIndex.row]] = retweetInfo;
		});
	}];
}

- (void)configureRetweetButton:(UIButton *)button retweets:(NSUInteger)retweets
{
	[button setTitle:[NSString stringWithFormat:@"%lu", retweets] forState:UIControlStateNormal & UIControlStateSelected];
	
	if (button.state == UIControlStateSelected) {
		button.imageView.image = [UIImage imageNamed:@"retweet_highlight.png"];
		button.titleLabel.textColor = [UIColor orangeColor];
	}
	else {
		button.imageView.image = [UIImage imageNamed:@"retweet_normal.png"];
	}
}

- (void)configureFavoriteButton:(UIButton *)button favorites:(NSUInteger)favorites
{
	[button setTitle:[NSString stringWithFormat:@"%lu", favorites] forState:UIControlStateNormal & UIControlStateSelected];
	
	if (button.state == UIControlStateSelected) {
		button.imageView.image = [UIImage imageNamed:@"favorite_highlight.png"];
		button.titleLabel.textColor = [UIColor orangeColor];
	}
	else {
		button.imageView.image = [UIImage imageNamed:@"favorite_normal.png"];
	}
}

- (IBAction)favorited:(id)sender {
	__weak typeof(self) weakSelf = self;
	
	CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tableView];
	NSIndexPath *hitIndex = [self.tableView indexPathForRowAtPoint:hitPoint];
	
	NSDictionary *tweet = self.tweets[hitIndex.row];
	__block NSMutableDictionary *favoriteInfo = [self.favoriteButtonDictionary[[NSString stringWithFormat:@"%lu", hitIndex.row]] mutableCopy];
	
	__block UIButton *button = (UIButton *)sender;
	
	[[CallManager sharedCallManager] favoriteWithID:tweet[@"id"] completionBlock:^(NSString *favoriteCount) {
		// TODO: Change this when we actually call the POST APIs
		// NSUInteger favoriteCountValue = [favoriteCount integerValue];
		dispatch_async(dispatch_get_main_queue(), ^{
			NSUInteger favoriteCountValue;
			UIControlState state = [favoriteInfo[@"state"] integerValue];
			
			if (state == UIControlStateSelected) {
				[button setSelected:NO];
				state = UIControlStateNormal;
				favoriteCountValue = [favoriteInfo[@"favorites"] integerValue] - 1;
			}
			else {
				[button setSelected:YES];
				state = UIControlStateSelected;
				favoriteCountValue = [favoriteInfo[@"favorites"] integerValue]+ 1;
			}
			
			[weakSelf configureFavoriteButton:button favorites:favoriteCountValue];
			
			favoriteInfo[@"state"] = [NSString stringWithFormat:@"%lu", state];
			favoriteInfo[@"favorites"] = [NSString stringWithFormat:@"%lu", favoriteCountValue];
			weakSelf.favoriteButtonDictionary[[NSString stringWithFormat:@"%lu", hitIndex.row]] = favoriteInfo;
		});
	}];
}

@end
