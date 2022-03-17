//
//  WJCWorklistEditorRightView2.m
//  Hi
//
//  Created by apple on 2018/5/21.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCWorklistEditorRightView2.h"

@interface WJCWorklistEditorRightView2 ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)  UITableView *worklistTable;  //
@property (nonatomic,strong)  WJCHiWorklist *tempWorklist;  //

@end

@implementation WJCWorklistEditorRightView2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithWorklist:(WJCHiWorklist *)rWorklist{
    if (self = [super init]) {
        _tempWorklist = rWorklist;
        [self setView];
    }
    return self;
}
- (void)setView{
    self.view.backgroundColor = [UIColor whiteColor];
    
    float tempHe = 0;
    if ([[UIApplication sharedApplication] statusBarFrame].size.height >44) {
        tempHe = 20;
    }
    float widS = [UIScreen mainScreen].bounds.size.width*0.4;
    //中间tableview
    UITableView *contentTableView        = [[UITableView alloc]initWithFrame:CGRectMake(widS, self.navigationController.navigationBar.bounds.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height, self.view.frame.size.width-widS, self.view.frame.size.height-(self.navigationController.navigationBar.bounds.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height-tempHe)) style:UITableViewStyleGrouped];
//    UITableView *contentTableView        = [[UITableView alloc]initWithFrame:CGRectMake(60, 0, self.view.frame.size.width-60, self.view.frame.size.height- self.view.frame.size.height-(self.navigationController.navigationBar.bounds.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height)) style:UITableViewStylePlain];
    [contentTableView setBackgroundColor:[UIColor whiteColor]];
    contentTableView.dataSource          = self;
    contentTableView.delegate            = self;
    contentTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [contentTableView setBackgroundColor:[UIColor whiteColor]];
    //    contentTableView.separatorStyle      = UITableViewCellSeparatorStyleNone;
    //    contentTableView.tableFooterView = [UIView new];
    contentTableView.layer.borderWidth = 0.2;
    contentTableView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    contentTableView.separatorColor = [UIColor darkGrayColor];

    
    self.worklistTable = contentTableView;
    [self.view addSubview:contentTableView];
}
- (void)reloadTable{
    [self.worklistTable reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tempWorklist.item.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    return 45 ;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//
//    return @"当前Worklist参数";
//}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    

    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor lightGrayColor];//[UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:0.7];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, 300 , 30)];
    label.text = @"当前Worklist参数";
            
    [view addSubview:label];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *str = [NSString stringWithFormat:@"LeftView%li",indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:str];
        
    }
    [cell setBackgroundColor:[UIColor whiteColor]];
    //    [cell.textLabel setTextColor:[UIColor grayColor]];
    
    //    cell.hidden = NO;
    cell.textLabel.text = _tempWorklist.item[indexPath.row].sName;
    cell.detailTextLabel.text = _tempWorklist.item[indexPath.row].nowPara.lDescribe;
    
    //cell分隔线
    [cell setSeparatorInset:UIEdgeInsetsZero];
    cell.backgroundColor = [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1.0];
//    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame] ;
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
}
@end
