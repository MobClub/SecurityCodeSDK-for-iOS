

#import "SectionsViewController.h"
#import "NSDictionary-DeepMutableCopy.h"

#import <SMS_SDK/SMS_SDK.h>

@interface SectionsViewController ()
{
    NSMutableData*_data;
    int _state;
    NSString* _duid;
    NSString* _token;
    NSString* _appKey;
    NSString* _appSecret;
    NSMutableArray* _areaArray;
}

@end


@implementation SectionsViewController
@synthesize names;
@synthesize keys;
@synthesize table;
@synthesize search;
@synthesize allNames;
#pragma mark -
#pragma mark Custom Methods
- (void)resetSearch {
    NSMutableDictionary *allNamesCopy = [self.allNames mutableDeepCopy];//deep copy
    self.names = allNamesCopy;
    //[allNamesCopy release];
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];

    [keyArray addObject:UITableViewIndexSearch];//add the search icon to index bar
    [keyArray addObjectsFromArray:[[self.allNames allKeys] 
                                   sortedArrayUsingSelector:@selector(compare:)]];
    self.keys = keyArray;
    //[keyArray release];
}
- (void)handleSearchForTerm:(NSString *)searchTerm
{
    NSMutableArray *sectionsToRemove = [[NSMutableArray alloc] init];
    [self resetSearch];
    
    for (NSString *key in self.keys) {
        NSMutableArray *array = [names valueForKey:key];
        NSMutableArray *toRemove = [[NSMutableArray alloc] init];
        for (NSString *name in array) {
            if ([name rangeOfString:searchTerm 
                            options:NSCaseInsensitiveSearch].location == NSNotFound)
                [toRemove addObject:name];//add the  unfit object to remove array
        }
        
        //if all of the object in this section are unfit 
        //add whole array's key to  section remove array
        if ([array count] == [toRemove count])
            [sectionsToRemove addObject:key];
        
        //remove the unfit objects in toRemove array 
        [array removeObjectsInArray:toRemove];
        //[toRemove release];
    }
    // remove the unfit sections in sectionsToRemove array
    [self.keys removeObjectsInArray:sectionsToRemove];
    //[sectionsToRemove release];
    
    //reload tableView data
    [table reloadData];
}

- (void)viewDidLoad {
    //UIToolbar* myToolBar=[[UIToolbar alloc] initWithFrame:rect];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    CGFloat statusBarHeight=0;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        statusBarHeight=20;
    }
    
    //创建一个导航栏
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0+statusBarHeight, 320, 44)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:nil];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back", nil)
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(clickLeftButton)];
    
    //设置导航栏内容
    [navigationItem setTitle:NSLocalizedString(@"countrychoose", nil)];
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    [navigationItem setLeftBarButtonItem:leftButton];
    
    //把导航栏添加到视图中
    [self.view addSubview:navigationBar];
    
    //添加搜索框
    search=[[UISearchBar alloc] init];
    search.frame=CGRectMake(0, 44+statusBarHeight, 320, 44);
    [self.view addSubview:search];
    
    //添加table
    table=[[UITableView alloc] initWithFrame:CGRectMake(0, 88+statusBarHeight, 320, self.view.bounds.size.height-(88+statusBarHeight)) style:UITableViewStylePlain];
    [self.view addSubview:table];

    table.dataSource=self;
    table.delegate=self;
    search.delegate=self;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"country"
                                                     ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] 
                          initWithContentsOfFile:path];
    self.allNames = dict;

    [self resetSearch];
    [table reloadData];
    [table setContentOffset:CGPointMake(0.0, 44.0) animated:NO];
}

-(void)setAreaArray:(NSMutableArray*)array
{
    _areaArray=[NSMutableArray arrayWithArray:array];
}

#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [keys count];
    
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
    //for seaching mode,if not fit result return,nothing will be displayed
    if ([keys count] == 0)
        return 0;
    
    NSString *key = [keys objectAtIndex:section];
    NSArray *nameSection = [names objectForKey:key];
    return [nameSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    //NSUInteger row = [indexPath row];
    
    NSString *key = [keys objectAtIndex:section];
    NSArray *nameSection = [names objectForKey:key];
    
    static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SectionsTableIdentifier ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier: SectionsTableIdentifier ];
    }
    
    NSString* str1 = [nameSection objectAtIndex:indexPath.row];
    
    NSRange range=[str1 rangeOfString:@"+"];
    
    NSString* str2=[str1 substringFromIndex:range.location];
    
    NSString* areaCode=[str2 stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSString* countryName=[str1 substringToIndex:range.location];

    
    //cell.textLabel.text = [nameSection objectAtIndex:row];
    cell.textLabel.text=countryName;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"+%@",areaCode];
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section
{
    if ([keys count] == 0)
        return nil;

    NSString *key = [keys objectAtIndex:section];
    //the search bar section don't need header
    if (key == UITableViewIndexSearch)
        return nil;
    
    return key;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    //if it is in searching mode,hide the index bar
    if (isSearching)
        return nil;
    
    return keys;
}
#pragma mark -
#pragma mark Table View Delegate Methods
- (NSIndexPath *)tableView:(UITableView *)tableView 
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //you can selectd a row to exit the searching mode
    [search resignFirstResponder];
    search.text = @"";
    isSearching = NO;
    [tableView reloadData];
    return indexPath;
}
- (NSInteger)tableView:(UITableView *)tableView 
sectionForSectionIndexTitle:(NSString *)title 
               atIndex:(NSInteger)index
{
    NSString *key = [keys objectAtIndex:index];
    //if it is click the search title,show the search bar,else show the section at index
    if (key == UITableViewIndexSearch)
    {
        //show the search bar
        [tableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    }
    else return index;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSString *key = [keys objectAtIndex:section];
    NSArray *nameSection = [names objectForKey:key];
    
    NSString* str1 = [nameSection objectAtIndex:indexPath.row];
    NSRange range=[str1 rangeOfString:@"+"];
    NSString* str2=[str1 substringFromIndex:range.location];
    NSString* areaCode=[str2 stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString* countryName=[str1 substringToIndex:range.location];

    CountryAndAreaCode* country=[[CountryAndAreaCode alloc] init];
    country.countryName=countryName;
    country.areaCode=areaCode;
    
    NSLog(@"%@ %@",countryName,areaCode);
    
    [self.view endEditing:YES];
    
    int compareResult = 0;
    
    for (int i=0; i<_areaArray.count; i++)
    {
        NSDictionary* dict1=[_areaArray objectAtIndex:i];
        
        [dict1 objectForKey:areaCode];
        NSString* code1 = [dict1 valueForKey:@"zone"];
        if ([code1 isEqualToString:areaCode])
        {
            compareResult=1;
            break;
        }
    }
    
    if (!compareResult)
    {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                      message:NSLocalizedString(@"doesnotsupportarea", nil)
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                            otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    //传递数据
    if ([self.delegate respondsToSelector:@selector(setSecondData:)]) {
        [self.delegate setSecondData:country];
    }
    
    //关闭当前
    [self clickLeftButton];
}

#pragma mark -
#pragma mark Search Bar Delegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchTerm = [searchBar text];
    [self handleSearchForTerm:searchTerm];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    isSearching = YES;
    [table reloadData];
}
- (void)searchBar:(UISearchBar *)searchBar 
    textDidChange:(NSString *)searchTerm
{
    if ([searchTerm length] == 0)
    {
        [self resetSearch];
        [table reloadData];
        return;
    }
    
    [self handleSearchForTerm:searchTerm];
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    isSearching = NO;
    search.text = @"";

    [self resetSearch];
    [table reloadData];
    
    [searchBar resignFirstResponder];
}

-(void)clickLeftButton
{
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

@end
