//
//  CallManager.h
//  TwitterBot
//
//  Created by Shwetha Gopalan on 2/6/15.
//  Copyright (c) 2015 Shwe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CallManager : NSObject

+ (instancetype)sharedCallManager;
- (void)tweetsForSearchTerm:(NSString *)searchTerm
			completionBlock:(void (^)(NSMutableArray *))completionBlock;


- (void)retweetWithID:(NSString *)idString
	  completionBlock:(void (^)(NSString *))completionBlock;

- (void)favoriteWithID:(NSString *)idString
	   completionBlock:(void (^)(NSString *))completionBlock;

@end
