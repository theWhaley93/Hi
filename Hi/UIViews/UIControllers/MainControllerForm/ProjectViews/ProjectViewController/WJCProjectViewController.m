//
//  WJCProjectViewController.m
//  Hi
//
//  Created by apple on 2018/5/10.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCProjectViewController.h"
#import "ZKSegment.h"
#import "WJCFilesManger.h"
#import "WJCFilesViewController.h"
#import "WJCWorklistController.h"
#import "WJCWorklistEditorView.h"
#import "WJCWorklistViewController.h"
#import "YCXMenuItem.h"
#import "YCXMenu.h"

typedef enum{
    ProjectWorklistView, ProjectChartView
} ProjectViewMode;

@interface WJCProjectViewController ()<UITableViewDataSource,UITableViewDelegate>{
    ProjectViewMode projectMode;
    float t1 ,t2,t3,t4,t5;
}


@property (nonatomic,strong)  UITableView *itemTable;  //worklist和chart的table
@property (nonatomic,strong)  UIView *mainView;  //

@property (nonatomic,strong)  UIButton *createButton;   //
@property (nonatomic,strong)  UIButton *openButton;     //

@property (nonatomic, strong) ZKSegment *zkSegment;      //tab control
@property (nonatomic,assign)  ZKSegmentStyle zkSegmentStyle;


@property (nonatomic,strong)   WJCDevice *nowDevice;  //hi device

@property (nonatomic , strong) NSMutableArray *items;   //bar 新建／打开文件夹
@end


@implementation WJCProjectViewController
@synthesize items = _items;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setMainView];
    //左右栏切换
    [self resetSegment];
    self.zkSegmentStyle = ZKSegmentLineStyle;

    [self setTable];
//    [self setButtons];
    
    [self setRightButtons];
    
    self.navigationItem.title = @"工程及文件";
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9){
        self.itemTable.cellLayoutMarginsFollowReadableWidth = NO;//9.0以上才有这个属性，针对ipad
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [_itemTable reloadData];
}
#pragma mark - 菜单栏内容
- (NSMutableArray *)items {
    if (!_items) {
        
        // set title
        //        YCXMenuItem *menuTitle = [YCXMenuItem menuTitle:@"Menu" WithIcon:nil];
        //        menuTitle.foreColor = [UIColor whiteColor];
        //        menuTitle.titleFont = [UIFont boldSystemFontOfSize:20.0f];
        
        //set logout button
        //        YCXMenuItem *logoutItem = [YCXMenuItem menuItem:@"退出" image:nil target:self action:@selector(logout:)];
        //        logoutItem.foreColor = [UIColor redColor];
        //        logoutItem.alignment = NSTextAlignmentCenter;
        
        //set item
        _items = [@[
                    [YCXMenuItem menuItem:@"新建文件"
                                    image:nil
                                      tag:100
                                 userInfo:@{@"title":@"Menu"}],
                    [YCXMenuItem menuItem:@"打开文件"
                                    image:nil
                                      tag:101
                                 userInfo:@{@"title":@"Menu"}]
                    //                    [YCXMenuItem menuItem:@"曲线采集"
                    //                                    image:nil
                    //                                      tag:102
                    //                                 userInfo:@{@"title":@"Menu"}]
                    ] mutableCopy];
    }
    return _items;
}

- (void)setItems:(NSMutableArray *)items {
    _items = items;
}
#pragma mark- 界面搭建
- (void)setRightButtons{
    /*
     UIBarButtonItem * rightBarItem1 = [[UIBarButtonItem alloc] initWithTitle:@"worklist" style:UIBarButtonItemStylePlain target:self action:@selector(test1)];
     //    rightBarItem1.image = [UIImage imageNamed:@"writeable"];
     //    rightBarItem1.
     UIBarButtonItem * rightBarItem2 = [[UIBarButtonItem alloc] initWithTitle:@"chart" style:UIBarButtonItemStylePlain target:self action:@selector(test2)];
     //    rightBarItem2.image = [UIImage imageNamed:@"unwriteable"];
     self.navigationItem.rightBarButtonItems = @[rightBarItem1,rightBarItem2];
     */
    UIBarButtonItem *barMenu = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"if_more3"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];//initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showMenu)];
    //    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"if_more3"] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItem = barMenu;
}
- (void)showMenu{
    [YCXMenu setTintColor:[UIColor darkGrayColor]];
    [YCXMenu setSelectedColor:[UIColor lightGrayColor]];
    if ([YCXMenu isShow]){
        [YCXMenu dismissMenu];
    } else {
//        float tempHe = 0;
//        if ([[UIApplication sharedApplication] statusBarFrame].size.height >44) {
//            tempHe = 20;
//        }
        [YCXMenu showMenuInView:self.view fromRect:CGRectMake(self.view.frame.size.width - 50, t1+t2-t3, 50, 0) menuItems:self.items selected:^(NSInteger index, YCXMenuItem *item) {
            
            //点击右上角菜单
            switch (index) {
                case 0:{
                    switch (projectMode) {
                        case ProjectWorklistView:
                        {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请输入要创建的worklist名称" preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert];
                            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                                //                textField.placeholder = @"请输入worklist名";
                                textField.text = @"untitled worklist";
                                [textField performSelector:@selector(selectAll:) withObject:nil afterDelay:0];
                            }];
                            
                            UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                                //新建worklist动作
                                WJCHiWorklist *tempCreateWorklist = [[WJCHiWorklist alloc] initWithName:alert.textFields[0].text withHiPara:_nowDevice.paras];
                                [_nowDevice.projectManger addWorklist:tempCreateWorklist];
                                [_itemTable reloadData];
                                
                                
                                
                            }];
                            [alert addAction:okAlert];
                            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                                
                            }]];
                            
                            
                            [self presentViewController:alert animated:YES completion:nil];
                            
                            break;
                        }
                        case ProjectChartView:
                            [self popDialogWithTittle:@"提示" message:@"此功能待完善"];
                            break;
                    }


                    break;
                }
                case 1:{
                    WJCFilesViewController *tempFilesView = [[WJCFilesViewController alloc] initWithDevice:_nowDevice];
                    [self.navigationController pushViewController:tempFilesView animated:YES];
                    
                    break;
                }
                default:
                    break;
            }
            
            //            NSLog(@"%@",item);
        }];
    }
}
//创建mainview
- (void)setMainView{
    _mainView = [[UIView alloc] initWithFrame:self.view.bounds];
    _mainView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];//[UIColor whiteColor];
    [self.view addSubview:_mainView];
//    self.view.backgroundColor = [UIColor whiteColor];
}
//创建table
- (void)setTable{
//    float tempHe = 0;
//    if ([[UIApplication sharedApplication] statusBarFrame].size.height >=40) {
//        tempHe = 20;
//    }
    t4 = self.zkSegment.frame.size.height;
    _itemTable = [[UITableView alloc] initWithFrame:CGRectMake(0, t4+t1+t2-t3, self.view.bounds.size.width, self.view.bounds.size.height-(t4+t1+t2-t3))];
    _itemTable.dataSource = self;
    _itemTable.delegate = self;
    [_mainView addSubview:_itemTable];
    _itemTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}
//创建两个按钮：新建worklist／chart按钮；从文件打开worklist／chart按钮
- (void)setButtons{
    float btnWidth =  self.view.bounds.size.width / 2 - 20;
    _createButton = [[UIButton alloc] initWithFrame:CGRectMake(10+2, self.view.bounds.size.height-52, btnWidth, 45)];
    [_createButton setTitle:@"新建" forState:UIControlStateNormal];
    _createButton.backgroundColor = [UIColor darkGrayColor];
    
    [_createButton setBackgroundImage:[self imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    [_createButton.layer setCornerRadius:6.0];
    [_createButton addTarget:self action:@selector(createFile) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    _openButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2+10-2 , self.view.bounds.size.height-52, btnWidth, 45)];
    [_openButton setTitle:@"打开文件" forState:UIControlStateNormal];
    _openButton.backgroundColor = [UIColor darkGrayColor];

    [_openButton setBackgroundImage:[self imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    [_openButton.layer setCornerRadius:6.0];
    [_openButton addTarget:self action:@selector(openFile) forControlEvents:UIControlEventTouchUpInside];
    
    [_mainView addSubview:_createButton];
    [_mainView addSubview:_openButton];
}

- (UIImage *) imageWithColor:(UIColor *)rColor{
    CGRect rect =CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [rColor CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    return image;
}
#pragma mark- 按钮动作
- (void)openFile{
    WJCFilesViewController *tempFilesView = [[WJCFilesViewController alloc] initWithDevice:_nowDevice];
    [self.navigationController pushViewController:tempFilesView animated:YES];
}
- (void)createFile{
    switch (projectMode) {
        case ProjectWorklistView:
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请输入要创建的worklist名称" preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请输入worklist名";
                textField.text = @"untitled worklist";
                [textField performSelector:@selector(selectAll:) withObject:nil afterDelay:0];
            }];
            
            UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                //新建worklist动作
                WJCHiWorklist *tempCreateWorklist = [[WJCHiWorklist alloc] initWithName:alert.textFields[0].text withHiPara:_nowDevice.paras];
                [_nowDevice.projectManger addWorklist:tempCreateWorklist];
                [_itemTable reloadData];
                
                
                
            }];
            [alert addAction:okAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                
            }]];

            
            [self presentViewController:alert animated:YES completion:nil];
            
            break;
        }
        case ProjectChartView:
            [self popDialogWithTittle:@"提示" message:@"此功能待完善"];
            break;
    }
    
}
//创建tab control，切换worklist和曲线
#pragma mark- 左右栏切换
- (void)resetSegment {
    if (self.zkSegment) {
        [self.zkSegment removeFromSuperview];
    }
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    
    t1 = self.navigationController.navigationBar.frame.size.height;
    t2 = statusBarFrame.size.height;
    t3 = 0;
//    if((t2==40) ||(t2>44))
    if((t2==40))
        t3=20;
    self.zkSegment = [ZKSegment
                      zk_segmentWithFrame:CGRectMake(0, t1+t2-t3, self.view.bounds.size.width, 45)
                      style:self.zkSegmentStyle];
    // 可手动设置各种颜色；
    // 如不设置则使用默认颜色
    self.zkSegment.zk_itemDefaultColor = [UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1];
    switch (self.zkSegmentStyle) {
        case ZKSegmentLineStyle:
            self.zkSegment.zk_itemSelectedColor = [UIColor colorWithRed:202 / 255.0 green:51 / 255.0 blue:54 / 255.0 alpha:1];
            break;
        case ZKSegmentRectangleStyle:
            self.zkSegment.zk_itemSelectedColor = [UIColor colorWithRed:250 / 255.0 green:250 / 255.0 blue:250 / 255.0 alpha:1];
            break;
        case ZKSegmentTextStyle:
            self.zkSegment.zk_itemSelectedColor = [UIColor colorWithRed:202 / 255.0 green:51 / 255.0 blue:54 / 255.0 alpha:1];
            break;
    }
    self.zkSegment.zk_itemStyleSelectedColor = [UIColor colorWithRed:202 / 255.0 green:51 / 255.0 blue:54 / 255.0 alpha:1];
    self.zkSegment.zk_backgroundColor = [UIColor colorWithRed:238 / 255.0 green:238 / 255.0 blue:238 / 255.0 alpha:1];
    //    __weak typeof(self) weakSelf = self;
    self.zkSegment.zk_itemClickBlock = ^(NSString *itemName, NSInteger itemIndex) {
        //        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        //左右切换动作
        if (itemIndex == 0) {
            projectMode = ProjectWorklistView;
            [_itemTable reloadData];
        } else if (itemIndex ==1){
            projectMode = ProjectChartView;
            [_itemTable reloadData];
        }

        
    };
    [self.zkSegment zk_setItems:@[ @"Worklist", @"曲线列表" ]];
    [self.view addSubview:self.zkSegment];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - table view datasourse
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger resultNum=0;
    switch (projectMode) {
        case ProjectWorklistView:
            resultNum = _nowDevice.projectManger.worklistCount;
            break;
            
        case ProjectChartView:
            resultNum = _nowDevice.projectManger.chartCount;
            break;
    }
    return resultNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
    switch (projectMode) {
        case ProjectWorklistView:
//            cell.imageView.image = [UIImage imageNamed:@"if_document"];
            cell.imageView.image = [UIImage imageNamed:@"if_hand_worklist"];
            cell.textLabel.text = _nowDevice.projectManger.worklists[indexPath.row].name;
            break;
            
        case ProjectChartView:
//            cell.imageView.image = [UIImage imageNamed:@"if_hichart"];
            cell.imageView.image = [UIImage imageNamed:@"if_hand_chart"];
            cell.textLabel.text = _nowDevice.projectManger.charts[indexPath.row].name;
            break;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    //cell图片尺寸适当
    CGSize itemSize = CGSizeMake(36, 36);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0, 0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //cell分隔线
    [cell setSeparatorInset:UIEdgeInsetsZero];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (projectMode) {
        case ProjectWorklistView:{

//            WJCWorklistController *tempWorklistC = [[WJCWorklistController alloc] initWithWorklist:_nowDevice.projectManger.worklists[indexPath.row] withDevice:_nowDevice withIsOffline:_nowDevice.isOffline];
            WJCWorklistViewController *tempWorklistC = [[WJCWorklistViewController alloc] initWithWorklist:_nowDevice.projectManger.worklists[indexPath.row] withDevice:_nowDevice withIsOffline:_nowDevice.isOffline];
            [self.navigationController pushViewController:tempWorklistC animated:YES];
            break;}
            
        case ProjectChartView:
            [self popDialogWithTittle:@"提示" message:@"此功能待完善"];
            break;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (projectMode) {
        case ProjectWorklistView:{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定要删除本条worklist?" preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert];
            
            UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                //确定删除
                [_nowDevice.projectManger.worklists removeObjectAtIndex:indexPath.row];
                [_itemTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                
            }];
            [alert addAction:okAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                //取消删除动作
                
            }]];
            
            
            [self presentViewController:alert animated:YES completion:nil];
            
            break;
        }
        case ProjectChartView:{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定要删除本条曲线?" preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert];
            
            UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                //确定删除
                [_nowDevice.projectManger.charts removeObjectAtIndex:indexPath.row];
                [_itemTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                
            }];
            [alert addAction:okAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                //取消删除动作
                
            }]];
            
            
            [self presentViewController:alert animated:YES completion:nil];
            break;
        }
    }
}

#pragma mark - 初始化
- (instancetype)initWithDevice:(WJCDevice *)rDevice{
    if (self = [super init]) {
        _nowDevice = rDevice;
        projectMode = ProjectWorklistView;
    }
    return self;
}

/**弹出提示框
 */
- (void)popDialogWithTittle:(NSString *)rTittle message:(NSString *)rMessage{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:rTittle message:rMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
    }];
    [alert addAction:okAlert];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
