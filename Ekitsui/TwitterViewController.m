//
//  TestViewController.m
//  TestTwitter
//
//  Created by セラフ on 2013/11/05.
//  Copyright (c) 2013年 セラフ. All rights reserved.
//

#import "Define.h"
#import "TwitterViewController.h"

#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "UIImageView+WebCache.h"

@interface TwitterViewController ()
@property  NSMutableArray* dataArray;
@end

@implementation TwitterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.dataArray = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

     UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    
    // 更新アクションを設定
     [refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    
    // UITableViewControllerにUIRefreshControlを設定
     self.refreshControl = refreshControl;

}

- (void) viewWillAppear:(BOOL)animated  {
    
    self.title = self.receiveString;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:HISTORY_FILE];

    NSMutableArray *_array = [[NSMutableArray alloc] initWithContentsOfFile:dataPath];
    [_array removeObject:self.title];
    NSMutableArray *_array2 = [[NSMutableArray alloc] initWithObjects:self.title, nil] ;
    [_array2 addObjectsFromArray:_array];
    
    [_array2 writeToFile:dataPath atomically:YES];
    
    
    [self reloadTwitterData];
    
    
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TestCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UIImageView *_imageView = (UIImageView*) [cell.contentView viewWithTag:1];
    UIWebView *_webView = (UIWebView*) [cell.contentView viewWithTag:2];

    
    NSDictionary *_dict = [self.dataArray objectAtIndex:indexPath.row];
    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setTimeStyle:NSDateFormatterFullStyle];
//    [formatter setDateFormat:@"EEE MMM dd HH:mm:ss ZZZ yyyy"];
//    NSDate *date = [formatter dateFromString:[_dict objectForKey:@"created_at"]];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:locale];
    [formatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    NSDate *date = [formatter dateFromString:[_dict objectForKey:@"created_at"]];
    
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    // NSDate* date = [NSDate date];
    // NSString* dateStr = [formatter stringFromDate:date];
    
    // cell.textLabel.text = [formatter stringFromDate:date];//[_dict objectForKey:@"created_at"];
    // cell.detailTextLabel.text = [_dict objectForKey:@"text"];
    
    NSDictionary *_user = [_dict objectForKey:@"user"];
    NSString *_userName = nil;
    NSString *_profileImageUrl = nil;
    if (_user != nil) {
        _userName = [_user objectForKey:@"name"];
        _profileImageUrl = [_user objectForKey:@"profile_image_url"];
    }
    
    int _diff = fabsf([date timeIntervalSinceNow]);
    
    NSString *_diffText = @"";
    if (_diff >= 24 * 3600) {
        _diffText = [NSString stringWithFormat:@"%d日前", (int)(_diff / (24*3600))];
    } else if (_diff >= 3600) {
        _diffText = [NSString stringWithFormat:@"%d時間前", (int)(_diff / (3600))];
    } else if (_diff >= 60) {
        _diffText = [NSString stringWithFormat:@"%d分前", (int)(_diff / 60)];
    } else {
        _diffText = [NSString stringWithFormat:@"%d秒前", (int)(_diff)];
    }
    
    
    NSString *_html =
        [NSString stringWithFormat:@"<html><body style='font-size:10px;'><span style='font-weight:bold;'>%@</span> %@<br />%@</body></html>",
            _userName, _diffText, [_dict objectForKey:@"text"]];
                       
    [_webView loadHTMLString:_html baseURL:nil];
    
    
    for(id subview in _webView.subviews)
    {
        if([[subview class] isSubclassOfClass:[UIScrollView class]])
        {
            ((UIScrollView *) subview).bounces = NO;
            ((UIScrollView *) subview).scrollEnabled = NO;
        }
    }
    _webView.scalesPageToFit = NO;

    [_imageView sd_setImageWithURL:[NSURL URLWithString:_profileImageUrl] placeholderImage:[UIImage imageNamed:@"placeholder.gif"] options:SDWebImageCacheMemoryOnly];

    
    return cell;


    
}

- (void) onReloadTwitterDataFinished {
    [self.tableView reloadData];
}

- (void)onRefresh:(id)sender
{
    // 更新開始
    [self.refreshControl beginRefreshing];
    
    // 更新処理をここに記述
    [self reloadTwitterData];
    
    // 更新終了
    [self.refreshControl endRefreshing];
}

- (void) reloadTwitterData {
    
    
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
                     NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:self.receiveString forKey:@"q"];
                     [params setValue:@"ja" forKey:@"lang"];
                     [params setValue:@"100" forKey:@"count"];
                     
                     SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                             requestMethod:SLRequestMethodGET
                                                                       URL:url
                                                                parameters:params];
                     [request setAccount:[accountArray objectAtIndex:0]];
                     [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                         // NSLog(@"responseData=%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                         
                         
                         NSDictionary *_dict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                         
                         self.dataArray =  _dict[@"statuses"] ;
                         
                         if ([self respondsToSelector:@selector(onReloadTwitterDataFinished)]) {
                             [self performSelectorOnMainThread:@selector(onReloadTwitterDataFinished) withObject:nil waitUntilDone:YES];
                         }
                         
                         //[self.tableView reloadData];
                         
                         //                         for (UITableViewCell *cell in [self.tableView visibleCells]){
                         //                             [self updateCell:cell atIndexPath:[self.tableView indexPathForCell:cell]];
                         //                         }
                         
//                         NSLog(@"TEST");
                         
                         
                     }];
                 }
             }
         }];
    }

    
    
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
