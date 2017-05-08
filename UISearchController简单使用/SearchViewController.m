//
//  SearchViewController.m
//  fmdb+单例
//
//  Created by owen on 16/8/5.
//  Copyright © 2016年 owen. All rights reserved.
//在iOS9中，UISearchDisplayController 已经被UISearchController替代。搜索框是一种常用的控件。

#import "SearchViewController.h"

@interface SearchViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchControllerDelegate,UISearchResultsUpdating>


//searchController
@property (nonatomic,retain) UISearchController *searchController;

//tableView
@property (nonatomic,strong) UITableView *skTableView;

//数据源
@property (nonatomic,strong) NSMutableArray *dataListArry;
@property (nonatomic,strong) NSMutableArray *searchListArry;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"搜索列表";
    
    self.dataListArry = [NSMutableArray array];
    self.searchListArry = [NSMutableArray array];
    self.dataListArry = [NSMutableArray arrayWithCapacity:100];
    
    //产生100个数字+三个随机字母
    for (NSInteger i =0; i<100; i++) {
        
         [self.dataListArry addObject:[NSString stringWithFormat:@"%ld%@",(long)i,[self shuffledAlphabet]]];
    }
    self.skTableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 0,[UIScreen  mainScreen].bounds.size.width ,[UIScreen  mainScreen].bounds.size.height)];
    
    self.skTableView.delegate = self;
    self.skTableView.dataSource = self;
    //隐藏tableViewCell下划线
//    self.skTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    //创建UISearchController
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    //设置代理
    self.searchController.delegate= self;
    self.searchController.searchResultsUpdater = self;
    
    //包着搜索框外层的颜色
    self.searchController.searchBar.barTintColor = [UIColor yellowColor];
    
    //提醒字眼
    self.searchController.searchBar.placeholder= @"请输入关键字搜索";

    //提前在搜索框内加入搜索词
    self.searchController.searchBar.text = @"我是周杰伦";

    
    //设置UISearchController的显示属性，以下3个属性默认为YES
    
    //搜索时，背景变暗色
    self.searchController.dimsBackgroundDuringPresentation = NO;
    //搜索时，背景变模糊
//    self.searchController.obscuresBackgroundDuringPresentation = NO;
    
    //点击搜索的时候,是否隐藏导航栏
//    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    //位置
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    // 添加 searchbar 到 headerview
    self.skTableView.tableHeaderView = self.searchController.searchBar;
    
    #warning 如果进入预编辑状态,searchBar消失(UISearchController套到TabBarController可能会出现这个情况),请添加下边这句话
    self.definesPresentationContext=YES;
    
    [self.view addSubview: self.skTableView];
}

//产生3个随机字母
- (NSString *)shuffledAlphabet {
    
    NSMutableArray * shuffledAlphabet = [NSMutableArray arrayWithArray:@[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"]];
    
    NSString *strTest = [[NSString alloc]init];
    for (int i=0; i<3; i++) {
        int x = arc4random() % 25;
        strTest = [NSString stringWithFormat:@"%@%@",strTest,shuffledAlphabet[x]];
    }
    return strTest;
}

//设置区域的行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (self.searchController.active) {
        
        return [self.searchListArry count];
    }
    else{
    
        return [self.dataListArry count];
    }
}

//返回单元格内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *flag=@"cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:flag];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:flag];
    }
    if (self.searchController.active) {
        [cell.textLabel setText:self.searchListArry[indexPath.row]];
    }
    else{
        [cell.textLabel setText:self.dataListArry[indexPath.row]];
    }
    return cell;
}





//谓词搜索过滤
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    //    //修改"Cancle"退出字眼,这样修改,按钮一开始就直接出现,而不是搜索的时候再出现
    //    searchController.searchBar.showsCancelButton = YES;
    //    for(id sousuo in [searchController.searchBar subviews])
    //    {
    //
    //        for (id zz in [sousuo subviews])
    //        {
    //
    //            if([zz isKindOfClass:[UIButton class]]){
    //                UIButton *btn = (UIButton *)zz;
    //                [btn setTitle:@"搜索" forState:UIControlStateNormal];
    //                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //            }
    //
    //            
    //        }
    //    }
    
    NSLog(@"updateSearchResultsForSearchController");
    NSString *searchString = [self.searchController.searchBar text];
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchString];
    if (self.searchListArry!= nil) {
        [self.searchListArry removeAllObjects];
    }
    //过滤数据
    self.searchListArry= [NSMutableArray arrayWithArray:[self.dataListArry filteredArrayUsingPredicate:preicate]];
    //刷新表格
    [self.skTableView reloadData];
}



#pragma mark - UISearchControllerDelegate代理
//测试UISearchController的执行过程

- (void)willPresentSearchController:(UISearchController *)searchController
{
    NSLog(@"willPresentSearchController");
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    NSLog(@"didPresentSearchController");

//    [self.view addSubview:self.searchController.searchBar];
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"willDismissSearchController");
}

- (void)didDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"didDismissSearchController");
}

- (void)presentSearchController:(UISearchController *)searchController
{
    NSLog(@"presentSearchController");
}







@end
