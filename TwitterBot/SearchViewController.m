//
//  SearchViewController.m
//  TwitterBot
//
//  Created by Shwetha Gopalan on 2/7/15.
//  Copyright (c) 2015 Shwe. All rights reserved.
//

#import "SearchViewController.h"
#import "TwitterTableViewController.h"
#import "CallManager.h"

@interface SearchViewController ()

@property (nonatomic, strong) CallManager *callManager;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.callManager = [CallManager sharedCallManager];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
	
	[self.view addGestureRecognizer:tap];
	self.searchTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[self.callManager tweetsForSearchTerm:self.searchTextField.text completionBlock:^(NSMutableArray *results) {
		TwitterTableViewController *dest = (TwitterTableViewController*)segue.destinationViewController;
		dest.tweets = results;
		[dest.tableView reloadData];
	}];
}


- (void)dismissKeyboard:(id)sender {
	[self.searchTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[self performSegueWithIdentifier:@"searchSegue" sender:self];
	return YES;
}

@end
