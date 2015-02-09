//
//  TwitterTableViewController.h
//  TwitterBot
//
//  Created by Shwetha Gopalan on 2/6/15.
//  Copyright (c) 2015 Shwe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *tweets;

- (IBAction)retweeted:(id)sender;
- (IBAction)favorited:(id)sender;


@end
