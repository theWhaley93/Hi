//
//  WJCLeftViewController.m
//  Hi
//
//  Created by apple on 2018/3/21.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCLeftViewController.h"



@interface WJCLeftViewController ()<UITableViewDelegate, UITableViewDataSource>{
    int selectIndex;

}

@property (nonatomic,strong)  UITableView *groupTable;  //显示的组


@end


@implementation WJCLeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selectIndex = 0;
    [self setGroupTable];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9){
        self.groupTable.cellLayoutMarginsFollowReadableWidth = NO;//9.0以上才有这个属性，针对ipad
    }
    self.navigationItem.title = @"参数组";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI界面
- (void)setGroupTable{
    _groupTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height-self.navigationController.navigationBar.bounds.size.height) style:UITableViewStylePlain];
    _groupTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _groupTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    _groupTable.dataSource = self;
    _groupTable.rowHeight = 52.5f;
    
    _groupTable.delegate = self;
    _groupTable.separatorColor = [UIColor darkGrayColor];

    [self.view addSubview:_groupTable];
}


#pragma mark- TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groupItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.groupItems[indexPath.row].abbreviativeName;//[NSString stringWithFormat:@"%d",indexPath.row];
    cell.detailTextLabel.text = self.groupItems[indexPath.row].fullName;
    if (selectIndex == indexPath.row) {
//       cell.imageView.image = [UIImage imageNamed:@"if_device"];
        cell.imageView.image = [UIImage imageNamed:@"if_hand_groupselect"];
        cell.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    } else {
//        cell.imageView.image = [UIImage imageNamed:@"if_document"];
        cell.imageView.image = [UIImage imageNamed:@"if_hand_group"];
        cell.backgroundColor = [UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0];
    }
    
    //cell图片尺寸适当
    CGSize itemSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0, 0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //cell.backgroundColor = [UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0];//[UIColor lightGrayColor];//[UIColor colorWithRed:90.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1.0];
//    [UIColor colorWithRed:110.0/255.0 green:113.0/255.0 blue:115.0/255.0 alpha:1.0];
    
    
    //cell分隔线
    [cell setSeparatorInset:UIEdgeInsetsZero];

    return cell;
}

#pragma mark- TableView delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectIndex = indexPath.row;
    [_groupTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    if ([theDelegate respondsToSelector:@selector(changeGroupWithIndex:)])
    {
        
        [theDelegate changeGroupWithIndex:selectIndex];
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
