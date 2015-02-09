//
//  TwitterTableViewCell.h
//  TwitterBot
//
//  Created by Shwetha Gopalan on 2/6/15.
//  Copyright (c) 2015 Shwe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *handle;
@property (weak, nonatomic) IBOutlet UILabel *tweetBody;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UILabel *since;
@property (weak, nonatomic) IBOutlet UIImageView *tweetImage;

@property (nonatomic, copy) NSString *retweets;
@property (nonatomic, copy) NSString *favorites;

@end
