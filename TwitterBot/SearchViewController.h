//
//  SearchViewController.h
//  TwitterBot
//
//  Created by Shwetha Gopalan on 2/7/15.
//  Copyright (c) 2015 Shwe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@end
