//
//  WJCWorklistEditorRightView.m
//  Hi
//
//  Created by apple on 2018/5/21.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCWorklistEditorRightView.h"

#define ImageviewWidth    18
#define Frame_Width       self.frame.size.width//200

@interface WJCWorklistEditorRightView()<UITableViewDelegate,UITableViewDataSource>
//界面ui
@property (nonatomic,strong)  UITableView *contentTableView;  //

//内存数据
@property (nonatomic,strong)  WJCHiWorklist *nowWorklist;  //

@end

@implementation WJCWorklistEditorRightView

- (instancetype)initWithFrame:(CGRect)rFrame withWorklist:(WJCHiWorklist *)rWorklist{
    if (self = [super initWithFrame:rFrame]) {
        _nowWorklist = rWorklist;
        [self setView];
    }
    return self;
}

- (void)setView{
    self.backgroundColor = [UIColor whiteColor];
    
    //添加头部
    UIView *headerView     = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Frame_Width, 64)];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];//[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0]];
    
    UILabel *NameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 100, 30)];
    [NameLabel setText:@"Worklist参数"];
    [headerView addSubview:NameLabel];
    
    [self addSubview:headerView];
    
    //中间tableview
    UITableView *contentTableView        = [[UITableView alloc]initWithFrame:CGRectMake(0, headerView.frame.size.height, Frame_Width, self.frame.size.height - headerView.frame.size.height )
                                                                       style:UITableViewStylePlain];
    [contentTableView setBackgroundColor:[UIColor whiteColor]];
    contentTableView.dataSource          = self;
    contentTableView.delegate            = self;
    contentTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [contentTableView setBackgroundColor:[UIColor whiteColor]];
//    contentTableView.separatorStyle      = UITableViewCellSeparatorStyleNone;
//    contentTableView.tableFooterView = [UIView new];
    
    self.contentTableView = contentTableView;
    [self addSubview:contentTableView];
}
- (void)reloadTable{
    [self.contentTableView reloadData];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#pragma mark - tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _nowWorklist.item.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 45 ;
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
    cell.textLabel.text = _nowWorklist.item[indexPath.row].sName;
    cell.detailTextLabel.text = _nowWorklist.item[indexPath.row].nowPara.lDescribe;
    
    //cell分隔线
    [cell setSeparatorInset:UIEdgeInsetsZero];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    

    
}
@end
