//
//  FirstViewController.m
//  TestTwitter
//
//  Created by セラフ on 2013/11/05.
//  Copyright (c) 2013年 セラフ. All rights reserved.
//

#import "FirstViewController.h"

#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface FirstViewController ()

@end

@implementation FirstViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    return;
    
    // エミュレータでも問題なく動く
    // postのクライアント表示はiOSになる。
//    SLComposeViewController *twitterPostVC =
//    [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
//    [twitterPostVC setInitialText:@"iOSのSocialFrameworkから投稿テスト。\nSLComposeViewController簡単。"];
//    [self presentViewController:twitterPostVC animated:YES completion:nil];

    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore
         requestAccessToAccountsWithType:accountType
         options:nil
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 NSArray *accountArray = [accountStore accountsWithAccountType:accountType];
                 if (accountArray.count > 0) {
                     // NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1.1/statuses/update.json"];
                     
                     NSURL * url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
                     
//                     NSDictionary *params = [NSDictionary dictionaryWithObject:@"SLRequest post test." forKey:@"status"];
                     NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:@"赤坂" forKey:@"q"];
                     [params setValue:@"ja" forKey:@"lang"];
                     [params setValue:@"50" forKey:@"count"];
                     
                     SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                             requestMethod:SLRequestMethodGET
                                                                       URL:url
                                                                parameters:params];
                     [request setAccount:[accountArray objectAtIndex:0]];
                     [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                         NSLog(@"responseData=%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                         
                         
                         NSDictionary *_dict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                         
                         NSArray *_array = [_dict objectForKey:@"statuses"];
                         
                         if (_array != nil) {
                             
                             for (int i=0; i < [_array count]; i++) {
                                 
                                 NSDictionary *_dict2 = [_array objectAtIndex:i];
                                 
                                 NSLog(@"log %@", [_dict2 objectForKey:@"created_at"]);
                                 NSLog(@"log %@", [_dict2 objectForKey:@"text"]);
                                 
                                 
                             }
                             
                             
                         }
                         
                         NSLog(@"TEST");
                         
                         
                     }];
                 }
             }
         }];
    }
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
