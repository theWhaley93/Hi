//
//  WJCWorklistEditorView.m
//  twoTableViews
//
//  Created by apple on 2018/5/17.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCWorklistEditorView.h"
#import "WJCWorklistEditorItemsView.h"
//#import "MenuView.h"
#import "WJCWorklistEditorRightView.h"
#import "WJCWorklistEditorRightView2.h"

#define screenW [UIScreen mainScreen].bounds.size.width

@interface WJCWorklistEditorView ()<UITableViewDelegate,UITableViewDataSource,ProductsDelegate>

@property (nonatomic,strong)  UITableView *groupTable;  //
@property (nonatomic,strong)  NSMutableArray *groupNames;  //
//@property (nonatomic,strong)  NSArray *tempGroupName;  //
@property (nonatomic,strong)  WJCWorklistEditorItemsView *groupItemVC;  //
@property (nonatomic,strong)  WJCParameters *hiParas;  //
@property (nonatomic,strong)  WJCHiWorklist *nowWorklist;  //当前
@property (nonatomic,strong)  WJCHiWorklist *tempHiWorklist;  //临时的worklist

//@property (nonatomic ,strong)MenuView   * menu;
//@property (nonatomic,strong)  WJCWorklistEditorRightView *demo;  //

@property (nonatomic,strong)  UIView *mainView;  //
@property (nonatomic,strong)  UIView *rightV;  //
@property (nonatomic,strong)  WJCWorklistEditorRightView2 *rightVC;  //

@end

@implementation WJCWorklistEditorView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setGroupValue];
    [self setTable];
    [self setGroupItems];
    
    [self setRightButtons];
//    [self setRightMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setGroupValue{
//    _tempGroupName = @[@"RU",@"AP",@"PU",@"UD",@"OP",@"PN",@"DR",@"AU",@"EC",@"CI"];
    
}
- (instancetype)initWithHiPara:(WJCParameters *)rHiPara withWorklist:(WJCHiWorklist*)rWorklist{
    if (self = [super init]) {
        _hiParas = rHiPara;
        _nowWorklist = rWorklist;
        
        _tempHiWorklist = [[WJCHiWorklist alloc] initWithName:_nowWorklist.name withHiPara:rHiPara];
        _tempHiWorklist.item = [_nowWorklist.item mutableCopy];
        

    }
    return self;
}

- (void)setTempWorklistToActualWorklist{
    [_nowWorklist.item removeAllObjects];
    _nowWorklist.item = [_tempHiWorklist.item mutableCopy];
}

#pragma mark- 界面搭建
- (void)setRightButtons{
    UIBarButtonItem *barMenu = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(rightButton)];
    self.navigationItem.rightBarButtonItem = barMenu;
}

- (void)rightButton{
    [self setTempWorklistToActualWorklist];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2] animated:YES];
}
//- (void)showRightMenu{
//    [self.menu show];
//    [self.demo reloadTable];
//
//}

//- (void)setRightMenu{
//    _demo = [[WJCWorklistEditorRightView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width * 0.6, [[UIScreen mainScreen] bounds].size.height) withWorklist:_nowWorklist];
////    demo.customDelegate = self;
//
//    self.menu = [[MenuView alloc]initWithDependencyView:self.view MenuView:_demo isShowCoverView:YES];
//}

- (void)setTable{
    //创建右侧滑出界面
    _rightVC = [[WJCWorklistEditorRightView2 alloc] initWithWorklist:_tempHiWorklist];
    [self addChildViewController:_rightVC];
    _rightV = _rightVC.view;
    [self.view addSubview:_rightV];
    //创建主界面
    UIView *mainV = [[UIView alloc] initWithFrame:self.view.bounds];
    mainV.backgroundColor = [UIColor whiteColor];
    self.mainView = mainV;
    [self.view addSubview:mainV];
    
//    float a = self.navigationController.navigationBar.bounds.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height;
    float tempHe = 0;
    if ([[UIApplication sharedApplication] statusBarFrame].size.height >44) {
        tempHe = 20;
    }
    self.groupTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.bounds.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height-tempHe, self.view.frame.size.width * 0.3, self.view.frame.size.height-(self.navigationController.navigationBar.bounds.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height-tempHe)) style:UITableViewStylePlain];
    self.groupTable.delegate = self;
    self.groupTable.dataSource = self;
    self.groupTable.showsVerticalScrollIndicator = NO;
    self.groupTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //加边框
    self.groupTable.layer.borderWidth = 0.2;
    self.groupTable.layer.borderColor = [[UIColor blackColor] CGColor];
    [self.mainView addSubview:self.groupTable];
    
    //添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    
    [self.mainView addGestureRecognizer:pan];
    
    
    //给控制器的View添加点按手势
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
//    [self.mainView addGestureRecognizer:tap];
}

- (void)setGroupItems{
    _groupItemVC = [[WJCWorklistEditorItemsView alloc] initWithHiPara:_hiParas withActualWorklist:_nowWorklist withTempWorklist:_tempHiWorklist];
    _groupItemVC.delegate = self;
    [self addChildViewController:_groupItemVC];
    [self.mainView addSubview:_groupItemVC.view];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark- 侧滑
- (void)tap{
    //让MainV复位
    
    [UIView animateWithDuration:0.3 animations:^{
        self.mainView.frame = self.view.bounds;
    }];
    
}



#define targetR 275
#define targetL -260
- (void)pan:(UIPanGestureRecognizer *)pan{
    
    //获取偏移量
    CGPoint transP = [pan  translationInView:self.mainView];
    //为什么不使用transform,是因为我们还要去修改高度,使用transform,只能修改,x,y
    //self.mainV.transform = CGAffineTransformTranslate(self.mainV.transform, transP.x, 0);
    
    self.mainView.frame = [self frameWithOffsetX:transP.x];
    
//    //判断拖动的方向
//    if(self.mainView.frame.origin.x > 0){
//        //向右
//        self.rightV.hidden = YES;
//    }else if(self.mainView.frame.origin.x < 0){
//        //向左
//        self.rightV.hidden = NO;
//    }
    
    //当手指松开时,做自动定位.
    CGFloat target = 0;
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        //        if (self.mainV.frame.origin.x > screenW * 0.5 ) {
        //            //1判断在右侧
        //            //当前View的x有没有大于屏幕宽度的一半,大于就是在右侧
        //            target = targetR;
        //        }else
        if(CGRectGetMaxX(self.mainView.frame) < screenW * 0.7){
            //2.判断在左侧
            //当前View的最大的x有没有小于屏幕宽度的一半,小于就是在左侧
            target = -screenW*0.62;
            //target = targetL;
        }
        
        
        //计算当前mainV的frame.
        CGFloat offset = target - self.mainView.frame.origin.x;
        [UIView animateWithDuration:0.3 animations:^{
            
            self.mainView.frame =  [self frameWithOffsetX:offset];
            [self.rightVC reloadTable];
        }];
        
        
    }
    
    
    //复位
    [pan setTranslation:CGPointZero inView:self.mainView];
    
}

#define maxY 100
//根据偏移量计算MainV的frame
- (CGRect)frameWithOffsetX:(CGFloat)offsetX {
    
//    NSLog(@"offsetX===%f",offsetX);
    
    CGRect frame = self.mainView.frame;
//    NSLog(@"x====%f",frame.origin.x);
    frame.origin.x += offsetX;
    
    //当拖动的View的x值等于屏幕宽度时,maxY为最大,最大为100
    // 375 * 100 / 375 = 100
    
    //对计算的结果取绝对值
//    CGFloat y =  fabs( frame.origin.x *  maxY / screenW);
//    frame.origin.y = y;
    
    
    //屏幕的高度减去两倍的Y值
//    frame.size.height = [UIScreen mainScreen].bounds.size.height - (2 * frame.origin.y);
    
    return frame;
}





#pragma mark-tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _hiParas.actualGroup.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *ident = @"Group";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
    }
    
    cell.textLabel.text = _hiParas.actualGroup[indexPath.row].abbreviativeName;
    cell.detailTextLabel.text = _hiParas.actualGroup[indexPath.row].fullName;
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBlack];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_groupItemVC) {
        [_groupItemVC scrollToSelectedIndexPath:indexPath];
    }
}
#pragma mark - ProductsDelegate
- (void)willDisplayHeaderView:(NSInteger)section {
    
    [self.groupTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:section inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)didEndDisplayingHeaderView:(NSInteger)section {
    
    [self.groupTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:section-1 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}
@end
