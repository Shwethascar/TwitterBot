//
//  TwitterTableViewCell.m
//  TwitterBot
//
//  Created by Shwetha Gopalan on 2/6/15.
//  Copyright (c) 2015 Shwe. All rights reserved.
//

#import "TwitterTableViewCell.h"
#import "CallManager.h"

@implementation TwitterTableViewCell

- (void)awakeFromNib {
    // Initialization code
	self.thumbnail.layer.cornerRadius = self.thumbnail.frame.size.height/ 2;
	self.thumbnail.clipsToBounds = YES;
	self.thumbnail.layer.borderColor = ([UIColor colorWithRed:217.0/255.0 green:139.0/255.0 blue:122.0/255.0 alpha:1.0]).CGColor;
	self.thumbnail.layer.borderWidth = 2.0;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
