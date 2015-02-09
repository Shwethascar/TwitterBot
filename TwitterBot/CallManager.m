//
//  CallManager.m
//  TwitterBot
//
//  Created by Shwetha Gopalan on 2/6/15.
//  Copyright (c) 2015 Shwe. All rights reserved.
//

#import "CallManager.h"

@implementation CallManager
{
	NSString *_consumerKey;
	NSString *_consumerSecret;
	NSDictionary *_authorizationDictionary;
}

- (instancetype)init {
	if (self = [super init]) {
		_consumerKey = @"sM0KtAoirNCpqSTUa9IOrgP2J";
		_consumerSecret = @"hQiUF9cZAkTXLioHH6Mzdq3wAXIse0aVDVUWNFblRoB0fmtiU1";
		
		[self generateAuthorizationHeader];
	}
	
	return self;
}

+ (instancetype)sharedCallManager {
	static dispatch_once_t predicate;
	static CallManager* sharedInstance = nil;
	dispatch_once(&predicate, ^{
		sharedInstance = [[CallManager alloc] init];
	});
	
	return sharedInstance;
}

- (void)generateAuthorizationHeader
{
	NSString *consumerString = [NSString stringWithFormat:@"%@:%@", _consumerKey, _consumerSecret];
	NSData *consumerData = [consumerString dataUsingEncoding:NSUTF8StringEncoding];
 
	// Get NSString from NSData object in Base64
	NSString *base64Encoded = [consumerData base64EncodedStringWithOptions:0];
	
	// get bearer token
	NSURL *tokenURL = [NSURL URLWithString:@"https://api.twitter.com/oauth2/token?grant_type=client_credentials"];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tokenURL
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:60.0];
	
	[request setHTTPMethod:@"POST"];
	[request setAllHTTPHeaderFields:@{@"Authorization" : [NSString stringWithFormat:@"Basic %@", base64Encoded], @"Host" : @"api.twitter.com"}];
	
	 __block NSString *bearerToken;

	NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
												completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
													
													if (!error) {
														NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
														
														if (error) {
															NSLog(@"Error converting data to json");
														}
														else {
															if ([jsonDictionary[@"token_type"] isEqualToString:@"bearer"]) {
																bearerToken = jsonDictionary[@"access_token"];
																
																 _authorizationDictionary = @{@"Authorization" : [NSString stringWithFormat:@"Bearer %@", bearerToken], @"Host" : @"api.twitter.com"};
															}
														}
														
													}
												}];
	
	[dataTask resume];
}

- (void)tweetsForSearchTerm:(NSString *)searchTerm
			completionBlock:(void (^)(NSMutableArray *))completionBlock
{
	NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
	
	NSURL *urlRequest = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=%@&result_type=mixed&count=50", [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlRequest
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:60.0];
	
	[request setHTTPMethod:@"GET"];
	[request setAllHTTPHeaderFields:_authorizationDictionary];
	
	NSMutableArray *results = [NSMutableArray array];
	
	__block BOOL success = YES;
	
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
												completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
													
													if (!error) {
														NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
														
														if (error) {
															success = NO;
															NSLog(@"Error converting data to json");
														}
														else {
															NSArray *statuses = jsonDictionary[@"statuses"];
															
															for (NSDictionary *dict in statuses) {
																NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
																NSDictionary *entries = dict[@"entities"];
																NSArray *media = entries[@"media"];
																
																if (media.count > 0) {
																	NSString *mediaURL = media[0][@"media_url_https"];
																	if (mediaURL) {
																		resultDict[@"imageURL"] = mediaURL;
																	}
																}
																
																resultDict[@"id"] = dict[@"id"];
																resultDict[@"favorites"] = dict[@"favorite_count"];
																resultDict[@"retweets"] = dict[@"retweet_count"];
																resultDict[@"tweet"] = dict[@"text"];
																
																NSString *created = dict[@"created_at"];
																NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
																NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
																[dateFormatter setCalendar:calendar];
																[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
																[dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss +zzzz yyyy"];
																NSDate *createdDate = [dateFormatter dateFromString:created];
																
																NSUInteger unitFlags =  NSCalendarUnitDay |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
																NSDateComponents *components = [calendar components:unitFlags fromDate:createdDate toDate:[NSDate date] options:0];
																NSString *since;
																
																if (components.day) {
																	since = [NSString stringWithFormat:@"%ldd", (long)components.day];
																}
																else if (components.hour) {
																	since = [NSString stringWithFormat:@"%ldh", (long)components.hour];
																}
																else if (components.minute) {
																	since = [NSString stringWithFormat:@"%ldm", (long)components.minute];
																}
																else if (components.second) {
																	since = [NSString stringWithFormat:@"%lds", (long)components.second];
																}
																
																resultDict[@"since"] = since;
																
																NSDictionary *user = dict[@"user"];
																resultDict[@"thumbnailURL"] = user[@"profile_image_url_https"];
																resultDict[@"name"] = user[@"name"];
																resultDict[@"handle"] = [NSString stringWithFormat:@"@%@", user[@"screen_name"]];
																
																[results addObject:resultDict];
															}
															
														}
														
														if (success && completionBlock) {
															completionBlock(results);
														}
														
														[[NSNotificationCenter defaultCenter] postNotificationName:@"gotTweets" object:self];
													}
													else {
														success = NO;
													}
												}];
	
	[dataTask resume];
}

- (void)retweetWithID:(NSString *)idString
	  completionBlock:(void (^)(NSString *))completionBlock
{
	NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
	
	NSURL *urlRequest = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/retweet/%@.json", idString]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlRequest
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:60.0];
	
	[request setHTTPMethod:@"POST"];
	[request setAllHTTPHeaderFields:_authorizationDictionary];
	
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
												completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
													
													if (!error) {
														NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
														
														if (error) {
															NSLog(@"Error reading JSON");
														}
														else {
															// TODO: Use actual OAuth tokens so this can be done for a single user account
															NSString *retweetCount = result[@"retweet_count"];
															
															if (completionBlock) {
																completionBlock(retweetCount);
															}
														}
													}
												}];
	
	[dataTask resume];

}

- (void)favoriteWithID:(NSString *)idString
	   completionBlock:(void (^)(NSString *))completionBlock
{
	NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
	
	NSURL *urlRequest = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/favorites/create.json?id=%@", idString]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlRequest
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:60.0];
	
	[request setHTTPMethod:@"POST"];
	[request setAllHTTPHeaderFields:_authorizationDictionary];
	
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
												completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
													
													if (!error) {
														NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
														
														if (error) {
															NSLog(@"Error reading JSON");
														}
														else {
															// TODO: Use actual OAuth tokens so this can be done for a single user account
															NSString *favoriteCount = result[@"favourites_count"];
															
															if (completionBlock) {
																completionBlock(favoriteCount);
															}

														}
													}
												}];
	
	[dataTask resume];
	
}

@end
