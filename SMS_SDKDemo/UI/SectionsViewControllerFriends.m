

#import "SectionsViewControllerFriends.h"
#import "NSDictionary-DeepMutableCopy.h"
#import "CustomCell.h"
#import "SMS_SDK/SMS_SDK.h"
#import "SMS_SDK/SMS_AddressBook.h"
#import "InvitationViewControllerEx.h"
#import "VerifyViewController.h"

@interface SectionsViewControllerFriends ()
{
    NSMutableArray* _testArray1;
    NSMutableArray* _testArray2;
    
    NSMutableArray* _addressBookData;
    NSMutableArray* _friendsData;
    NSMutableArray* _friendsData2;
    
    NSMutableArray* _other;

}

@end


@implementation SectionsViewControllerFriends
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
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];

    [keyArray addObject:UITableViewIndexSearch];//add the search icon to index bar
    [keyArray addObjectsFromArray:[[self.allNames allKeys] 
                                   sortedArrayUsingSelector:@selector(compare:)]];
    self.keys = keyArray;
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
    }
    // remove the unfit sections in sectionsToRemove array
    [self.keys removeObjectsInArray:sectionsToRemove];
    
    //reload tableView data
    [table reloadData];
}

-(void)clickLeftButton
{
    [self dismissViewControllerAnimated:YES completion:^{
        _window.hidden=YES;
    }];
    
    //修改消息条数为0
    [SMS_SDK setLatelyFriendsCount:0];

    if (_friendsBlock) {
        _friendsBlock(1,0);
    }

}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _friendsData=[NSMutableArray array];
        
        _friendsData2=[NSMutableArray array];
    }
    return self;
}

-(void)setMyData:(NSArray*) array
{
    _friendsData=[NSMutableArray arrayWithArray:array];
}

-(void)setMyBlock:(ShowNewFriendsCountBlock)block
{
    _friendsBlock=block;
}

- (void)viewDidLoad
{
    self.view.backgroundColor=[UIColor whiteColor];
    
    CGFloat statusBarHeight=0;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        statusBarHeight=20;
    }
    //创建一个导航栏
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0+statusBarHeight, 320, 44)];
    
    //创建一个导航栏集合
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:nil];
    
    //创建一个左边按钮
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back", nil)
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(clickLeftButton)];
    

    //把导航栏集合添加入导航栏中，设置动画关闭
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    
    //把左右两个按钮添加入导航栏集合中
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
    
    _other=[NSMutableArray array];
    
    _addressBookData=[SMS_SDK addressBook];
    
    
    NSLog(@"获取到了%zi条通讯录信息",_addressBookData.count);
    
    NSLog(@"获取到了%zi条好友信息",_friendsData.count);
    
    
    //双层循环 取出重复的通讯录信息
    for (int i=0; i<_friendsData.count; i++) {
        NSDictionary* dict1=[_friendsData objectAtIndex:i];
        NSString* phone1=[dict1 objectForKey:@"phone"];
        NSString* name1=[dict1 objectForKey:@"nickname"];
        for (int j=0; j<_addressBookData.count; j++) {
            SMS_AddressBook* person1=[_addressBookData objectAtIndex:j];
            for (int k=0; k<person1.phonesEx.count; k++) {
                if ([phone1 isEqualToString:[person1.phonesEx objectAtIndex:k]]) {
                    if (person1.name) {
                        NSString* str1=[NSString stringWithFormat:@"%@+%@",name1,person1.name];
                        NSString* str2=[str1 stringByAppendingString:@"@"];
                
                        [_friendsData2 addObject:str2];
                    }
                    else
                    {
                        //[_friendsData2 addObject:@""];
                    }
                    
                    [_addressBookData removeObjectAtIndex:j];
                }

            }
        }
    }
    NSLog(@"_friends1:%zi",_friendsData.count);
    NSLog(@"_friends2:%zi",_friendsData2.count);
    
    for (int i=0; i<_addressBookData.count; i++) {
        SMS_AddressBook* person1=[_addressBookData objectAtIndex:i];
        NSString* str1=[NSString stringWithFormat:@"%@+%@",person1.name,person1.phones];
        NSString* str2=[str1 stringByAppendingString:@"#"];
        NSLog(@"%@",str2);
        [_other addObject:str2];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    _testArray1=[NSMutableArray array];
    _testArray2=[NSMutableArray array];
    
    if (_friendsData2.count>0) {
        [dict setObject:_friendsData2 forKey:NSLocalizedString(@"hasjoined", nil)];
    }
    if (_other.count>0) {
         [dict setObject:_other forKey:NSLocalizedString(@"toinvitefriends", nil)];
    }
    
    self.allNames = dict;
    
    [self resetSearch];
    [table reloadData];
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

- (void)CustomCellBtnClick:(CustomCell *)cell
{
    [self.view endEditing:YES];
    NSLog(@"cell的按钮被点击了-第%i组,第%i行", cell.section,cell.index);
    
    UIButton* btn=cell.btn;
    NSLog(@"%@",btn.titleLabel.text);
    
    NSString* newStr=btn.titleLabel.text;
    
    if ([newStr isEqualToString:NSLocalizedString(@"addfriends", nil)])
    {
        NSLog(@"添加好友");
        NSLog(@"添加好友回调 用户自行处理");
        
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addfriendstitle", nil) message:NSLocalizedString(@"addfriendsmsg", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
    
    if ([newStr isEqualToString:NSLocalizedString(@"invitefriends", nil)])
    {
        NSLog(@"邀请好友");
        InvitationViewControllerEx* invit=[[InvitationViewControllerEx alloc] init];
//        
        [invit setData:cell.name];

        [invit setPhone:cell.nameDesc AndPhone2:@""];
//
        [self presentViewController:invit animated:YES completion:^{
            ;
        }];

    }


}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    
    NSString *key = [keys objectAtIndex:section];
    NSArray *nameSection = [names objectForKey:key];
    
    static NSString *CellWithIdentifier = @"CustomCellIdentifier";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    if (cell == nil) {
        //cell = [[[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil] lastObject];
        cell=[[CustomCell alloc] init];
        
        cell.delegate = self;
    }

    NSString* str1 = [nameSection objectAtIndex:indexPath.row];
    
    NSString* newStr1=[str1 substringFromIndex:(str1.length-1)];
    //NSLog(@"%@",newStr1);
    
    NSRange range=[str1 rangeOfString:@"+"];
    
    NSString* str2=[str1 substringFromIndex:range.location];
    
    NSString* phone=[str2 stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSString *cccc = [phone substringToIndex:[phone length] - 1];
    
    NSString* name=[str1 substringToIndex:range.location];
    
    if ([newStr1 isEqualToString:@"@"]) {
        UIButton* btn=cell.btn;
        
        [btn setTitle:NSLocalizedString(@"addfriends", nil) forState:UIControlStateNormal];
        
        cell.nameDesc=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"phonecontacts", nil),cccc];
    }
    
    if ([newStr1 isEqualToString:@"#"]) {
        UIButton* btn=cell.btn;
        
        [btn setTitle:NSLocalizedString(@"invitefriends", nil) forState:UIControlStateNormal];
        
        cell.nameDesc=[NSString stringWithFormat:@"%@",cccc];
        cell.nameDescLabel.hidden=YES;
    }
    
    cell.name=name;
    cell.index = (int)indexPath.row;
    cell.section = (int)[indexPath section];
    
    int myindex=(int)(cell.index)%14;
    //NSLog(@"%i",myindex);
    //NSString *icon = [NSString stringWithFormat:@"images.bundle/%i.jpg", i + 1];
    NSString* imagePath=[NSString stringWithFormat:@"smssdk.bundle/%i.png",myindex+1];
    //NSString* imagePath=[NSString stringWithFormat:@"%i.png",myindex+1];
    
    cell.image=[UIImage imageNamed:imagePath];
    
    return cell;
}

#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
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
    NSLog(@"%@ %@",countryName,areaCode);
}

#pragma mark -
#pragma mark Search Bar Delegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //click search button at keyboard,will do something
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
    
    //when you type something in text field,the search is beginning(synchronization)
    [self handleSearchForTerm:searchTerm];
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //reset Search bar
    isSearching = NO;
    search.text = @"";

    [self resetSearch];
    [table reloadData];
    
    //dismiss the keyboard
    [searchBar resignFirstResponder];
}
@end
