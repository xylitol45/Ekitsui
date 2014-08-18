//
//  StationViewController.m
//  TestTwitter
//
//  Created by セラフ on 2013/11/08.
//  Copyright (c) 2013年 セラフ. All rights reserved.
//

#import "StationViewController.h"
#import "TwitterViewController.h"

@interface StationViewController ()

@property (nonatomic, strong) NSMutableArray* prefArray;
@property (nonatomic, strong) NSMutableArray* prefNameArray;

@property (nonatomic, strong) NSMutableArray *filteredArray;

@end

@implementation StationViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.prefArray = nil;
        self.prefNameArray = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.searchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"StationCell"];
    
    
    if (self.prefArray==nil) {
        self.prefArray = [[NSMutableArray alloc] init];
    }
    if (self.prefNameArray==nil){
        self.prefNameArray = [[NSMutableArray alloc]init];
    }
    
    NSString *_path = [[NSBundle mainBundle] pathForResource:@"Station" ofType:@"plist"];
	NSArray *_array = [NSArray arrayWithContentsOfFile:_path];
    
    for (int i = 0; i < [_array count]; i++) {
        
        NSMutableDictionary *prefDict = [[NSMutableDictionary alloc]init];
        
        [self.prefArray addObject:prefDict];
        
        
        NSDictionary *_dict = [_array objectAtIndex:i];
        [prefDict setObject:[_dict objectForKey:@"pref_name"] forKey:@"pref_name"];
        
        [self.prefNameArray addObject:[_dict objectForKey:@"pref_name"]];
        
        NSMutableArray *_stationArray = [[NSMutableArray alloc]init];

        [prefDict setObject: _stationArray  forKey:@"station"];
        
        NSArray *_array2 = [_dict objectForKey:@"line"];
        if (_array2 == nil){
            continue;
        }
        
        for (int j=0;j<[_array2 count];j++) {
            
            NSDictionary *_dict2 = [_array2 objectAtIndex:j];
            NSString *_line_name = [_dict2 objectForKey:@"line_name"];
            NSArray *_array3 = [_dict2 objectForKey:@"station"];
            
            if (_array3 == nil){
                continue;
            }
            
            for (int k=0;k<[_array3 count];k++) {
                
                NSDictionary *_dict3 = [_array3 objectAtIndex:k];
                
                NSDictionary *_stationDict =
                    [[NSDictionary alloc]
                     initWithObjectsAndKeys:_line_name, @"line_name", [_dict3 objectForKey:@"station_name"], @"station_name",nil];
                
                [_stationArray addObject:_stationDict];
                
            }
        }
    }

    self.filteredArray = [NSMutableArray arrayWithCapacity:[self.prefArray count]];
    
    if ([self respondsToSelector:@selector(imageCacheFinished)]) {
        [self performSelectorOnMainThread:@selector(imageCacheFinished) withObject:nil waitUntilDone:YES];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) imageCacheFinished {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

//    if (self.prefArray!=nil) {
//        return [self.prefArray count];
//    }
    
    NSLog(@"numberOfRowsInSection");
    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        return [self.prefArray count];
    } else {
        return [self.filteredArray count];
    }
 
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSLog(@"numberOfRowsInSection");
    
    // NSArray *_stationArray = nil;
    NSDictionary *_dict = nil;
    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        if (self.prefArray!=nil) {
            _dict = [self.prefArray objectAtIndex:section];
        }
        
    } else {
        if (self.filteredArray != nil) {
            _dict = [self.filteredArray objectAtIndex:section];
        }
    }

    
    
        if (_dict != nil) {
            
            NSArray *_stationArray = [_dict objectForKey:@"station"];
            
            return [_stationArray count];
        }
    
    
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath");
    
    
    static NSString *CellIdentifier = @"StationCell";
    
    if (indexPath==nil) {
//        return nil;
    }
    
    //UITableView* _tableView = nil;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    
    NSDictionary *_dict = nil;
    // if (!self.searchDisplayController.active) {
    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
            //        return nil;
        _dict = [self.prefArray objectAtIndex:indexPath.section];
        
    } else {
        _dict = [self.filteredArray objectAtIndex:indexPath.section];

    }
    
    NSArray *_array = [_dict objectForKey:@"station"];
    NSDictionary *_station = [_array objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [_station objectForKey:@"station_name"];
    cell.detailTextLabel.text = [_station objectForKey:@"line_name"];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSLog(@"titleForHeaderInSection");

    
//    if (self.prefArray!=nil){
//        NSDictionary *_dict = [self.prefArray objectAtIndex:section];
//        return [_dict objectForKey:@"pref_name"];
//    }
    
    NSDictionary *_dict = nil;
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        //        return nil;
        _dict = [self.prefArray objectAtIndex:section];
        
    } else {
        _dict = [self.filteredArray objectAtIndex:section];
        
    }
    
    if (_dict != nil) {
        return [_dict objectForKey:@"pref_name"];
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        [self performSegueWithIdentifier:@"Next TwitterViewController" sender:self];
    }
    else {
//      [self performSegueWithIdentifier:@"fromAll" sender:self];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
       NSLog(@"prepareForSegue");
    
    // どのセクションの何行目が選択されたかでセルを取得
    UITableViewCell *cell;
    if ([segue.identifier isEqualToString:@"Next HistoryViewController"]) {
        return;
    }
    
    if ([segue.identifier isEqualToString:@"Next TwitterViewController"]) {
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        
        cell = [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
        
        [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
    }
    
    NSLog(@"%@", cell.textLabel.text);
    
    // 移動先が持つラベルに選択セルの文字列を設定
    TwitterViewController *_viewController = [segue destinationViewController];
    _viewController.receiveString = cell.textLabel.text;
    
}

//TableViewのインデックスリストに表示させたい文字列を設定する。
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{    
    NSLog(@"sectionIndexTitlesForTableView");
    
    //インスタンス変数のstrArrayを設定している。
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        return self.prefNameArray;
    }
    
    return nil;
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
//    [self.filteredCandyArray removeAllObjects];
//    // Filter the array using NSPredicate
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
//    filteredCandyArray = [NSMutableArray arrayWithArray:[candyArray filteredArrayUsingPredicate:predicate]];

    NSLog(@"filterContentForSearchText");
    
    [self.filteredArray removeAllObjects];
    
    for(int i=0;i<[self.prefArray count];i++) {
        
        NSDictionary *_dict = [self.prefArray objectAtIndex:i];
        
        NSString *_pref_name = [_dict objectForKey:@"pref_name"];
        NSArray *_stationArray = [_dict objectForKey:@"station"];
        NSArray *_filteredStationArray = nil;
        // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
        
        _filteredStationArray =
        [_stationArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(station_name contains[c] %@)", searchText]];
        
        if ([_filteredStationArray count]>0) {
            
            NSDictionary *_dict2 = [[NSDictionary alloc] initWithObjectsAndKeys:_pref_name, @"pref_name", _filteredStationArray, @"station", nil];
            
            [self.filteredArray addObject:_dict2];
            
        }
    }

}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
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
