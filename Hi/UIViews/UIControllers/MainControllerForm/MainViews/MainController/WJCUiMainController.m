//
//  WJCUiMainController.m
//  Hi
//
//  Created by apple on 2018/3/21.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCUiMainController.h"
#import "WJCDevice.h"
#import "WJCOneParaViewCell.h"
#import "WJCGlobalConstants.h"
#import "WJCLeftViewController.h"
#import "WJCUiParaEditor.h"
#import "WJCDatasetParaTable.h"
#import "WJCArrayParaTable.h"
#import "YCXMenuItem.h"
#import "YCXMenu.h"
#import "WJCWorklistController.h"
#import "WJCProjectViewController.h"
#import "WJCRemoteViewController.h"


#define screenW [UIScreen mainScreen].bounds.size.width
#define screenH [UIScreen mainScreen].bounds.size.height

#define targetR 160
#define targetL -160

#define maxY 100

@interface WJCUiMainController ()<UITableViewDataSource,UITabBarDelegate,UITableViewDelegate,WJCUiLeftViewDelegate>{
    Boolean t;
    int nowGroup;
    Boolean changeGroupB;
    int tempG ;
    Boolean scrollChange;
    Boolean isOffline;
    
    Boolean isDriverStateUnfolded;  //驱动器状态显示是否展开
    Boolean errCnt; //驱动器报警闪烁
    float t1,t2,t3,t4;
}

@property (nonatomic,strong)  UITableView *paraTable;  //

//@property (nonatomic,strong)  NSThread *nowThread;  //

@property (nonatomic,strong)  NSArray<NSIndexPath *> *visibleCells;  //

@property (nonatomic,strong)  WJCLeftViewController *leftView;  //

@property (nonatomic,strong)  UIView *mainView;  //

@property (nonatomic,strong)  NSThread *nowThread;  //

@property (nonatomic,strong)  NSTimer *uiTimer;  //

@property (nonatomic,strong)  UIView *driverStatepanel;  //

@property (nonatomic,strong)  UIButton *errorLabel;  //报警

@property (nonatomic,strong)  UIView *statusPanel;  //驱动器状态

@property (nonatomic,strong)  UIImageView *enableImage;  //
@property (nonatomic,strong)  UIImageView *errorImage;  //
@property (nonatomic,strong)  UIImageView *busyImage;  //
@property (nonatomic,strong)  UIImageView *runningImage;  //
@property (nonatomic,strong)  UIImageView *reverseImage;  //
@property (nonatomic,strong)  UIImageView *readyImage;  //

@property (nonatomic,strong)  UISwitch *enabledSwitch;  //软使能切换

@property (nonatomic,strong)  NSMutableArray<UIImageView *> *statusImages;  //
@property (nonatomic,strong)  NSMutableArray<UILabel *> *statusImageLabels;  //

@property (nonatomic , strong) NSMutableArray *items;   //bar button显示菜单：远程、worklist、曲线
@end

@implementation WJCUiMainController
@synthesize items = _items;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    self->t = YES;
    
    self->nowGroup = 0;
    changeGroupB = NO;
    scrollChange = NO;
    
    [self performSelectorOnMainThread:@selector(readVisibleCells) withObject:nil waitUntilDone:YES];
    NSString *leftText = @"返回设备列表";
    if (isOffline) {
        leftText = @"返回文件列表";
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:leftText style:UIBarButtonItemStyleDone target:self action:@selector(leftClick)];
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回2" style:UIBarButtonItemStyleDone target:self action:@selector(leftClick)];
    //    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(leftClick)];
    self.navigationItem.title = [NSString stringWithFormat:@"CFGID%d",hiDevice.cfgId];
    
    
    [self setViews];
    [self setRightButtons];
    /** 侧滑效果
     */
    //拖动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    //添加手势
    [self.mainView addGestureRecognizer:pan];
    
    //添加点按手势
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    //    [self.view addGestureRecognizer:tap];
    if (isOffline) {
        
    } else {
        _uiTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(setTable) userInfo:nil repeats:YES];
    }

    //屏幕常亮
     [UIApplication sharedApplication].idleTimerDisabled = YES;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9){
        self.paraTable.cellLayoutMarginsFollowReadableWidth = NO;//9.0以上才有这个属性，针对ipad
    }

}

- (instancetype)initWithIsOffline:(Boolean) rIsOffline{
    if (self = [super init]) {
        isOffline = rIsOffline;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    if (isOffline) {
        
    } else {
        _nowThread = [[NSThread alloc] initWithTarget:self selector:@selector(readThread) object:nil];
        [_nowThread start];
        
        [_uiTimer setFireDate:[NSDate distantPast]];
    }

}

- (void)viewDidDisappear:(BOOL)animated{
    if (isOffline) {
        
    } else {
        [_uiTimer setFireDate:[NSDate distantFuture]];
        [_nowThread cancel];
    }

}
#pragma mark - UI界面动作
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
//        NSLog(@"%f",[[UIApplication sharedApplication] statusBarFrame].size.height);
//        if ([[UIApplication sharedApplication] statusBarFrame].size.height >44) {
//            tempHe = 20;
//        }
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        
        t1 = self.navigationController.navigationBar.frame.size.height;
        t2 = statusBarFrame.size.height;
        t3 = 0;
//        if((t2==40) ||(t2>44))
        if((t2==40))
            t3=20;
        [YCXMenu showMenuInView:self.view fromRect:CGRectMake(self.view.frame.size.width - 50, t1+t2-t3, 50, 0) menuItems:self.items selected:^(NSInteger index, YCXMenuItem *item) {
            
            //点击右上角菜单
            switch (index) {
                case 0:{
                    /*
                    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                    
                    NSString *file = @"11KW-20A-HT1805202R-F.htnwk";
                    
                    NSString *filePath = [NSString stringWithFormat:@"%@%@%@",documentPath,@"/",file];//[[NSBundle mainBundle] pathForResource:file ofType:nil];
                    NSError *errorLis = nil;
                    NSString *filecContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF16LittleEndianStringEncoding error:&errorLis];
                    WJCHiWorklist *tempWorklist = [WJCHiWorklist hiWorklistWithStr:filecContent withHiPara:hiDevice.paras];
                    [hiDevice addWorklist:tempWorklist];
                    */
                    WJCProjectViewController *tempWorklistC = [[WJCProjectViewController alloc] initWithDevice:hiDevice];
                    
                    [self.navigationController pushViewController:tempWorklistC animated:YES];
                    /*
                    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                    
                    NSString *file = @"11KW-20A-HT1805202R-F.htnwk";
                    
                    NSString *filePath = [NSString stringWithFormat:@"%@%@%@",documentPath,@"/",file];//[[NSBundle mainBundle] pathForResource:file ofType:nil];
                    NSError *errorLis = nil;
                    NSString *filecContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF16LittleEndianStringEncoding error:&errorLis];
                    WJCHiWorklist *tempWorklist = [WJCHiWorklist hiWorklistWithStr:filecContent withHiPara:hiDevice.paras];
                    [hiDevice addWorklist:tempWorklist];
                     
                    WJCWorklistController *tempWorklistC = [[WJCWorklistController alloc] initWithWorklist:hiDevice.worklists[0] withDevice:hiDevice withIsOffline:isOffline];

                    [self.navigationController pushViewController:tempWorklistC animated:YES];
                    */
                    break;
                }
                case 1:{
                    if (isOffline) {
                        [self popDialogWithTittle:@"提示" message:@"离线模式无法进入远程协助界面"];
                    } else {
                        WJCRemoteViewController *remoteVC = [[WJCRemoteViewController alloc] initWithHiDevice:hiDevice];
                        [self.navigationController pushViewController:remoteVC animated:YES];
                    }

                    break;
                }
                default:
                    break;
            }
            
//            NSLog(@"%@",item);
        }];
    }
}

- (void)test1{
    [self popDialogWithTittle:@"test" message:@"worklist"];
}
-(void)test2{
    [self popDialogWithTittle:@"test" message:@"chart"];
}
/**返回按钮/Users/apple/Desktop/dev/Hi/Hi/Hi/UIViews/UIControllers/MainControllerForm/MainViews/MainController/WJCUiMainController.m
 */
- (void)leftClick{
    if (isOffline) {
        [self.navigationController popToViewController:self.navigationController.childViewControllers[2] animated:YES];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定退出设备?" preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert];
        
        UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [_nowThread cancel];
                [_uiTimer invalidate];
                _uiTimer = nil;
                [self.navigationController popToViewController:self.navigationController.childViewControllers[1] animated:YES];
            
        }];
        [alert addAction:okAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            
        }]];
        
        
        [self presentViewController:alert animated:YES completion:nil];

    }

}
/**获取可见的cells
 */
- (void)readVisibleCells{
    self.visibleCells = [self.paraTable indexPathsForVisibleRows];
}

- (void)showDriverState{
    //状态栏报警
//    NSLog(@"connect %d",hiDevice.hiCom.clientSocket.isConnected);
    //20190507 wjc 增加与操作器tcp断开连接状态判断
    if (hiDevice.hiCom.clientSocket.isConnected){
        //tcp连接正常
        if (hiDevice.driverState.isError) {
            [self.errorLabel setTitle:hiDevice.driverState.errDescription forState:UIControlStateNormal];
            [self.errorLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            if (errCnt) {
                self.errorLabel.backgroundColor = [UIColor yellowColor];
            } else{
                self.errorLabel.backgroundColor = [UIColor lightGrayColor];
            }
        } else if (hiDevice.driverState.isHint) {
            [self.errorLabel setTitle:hiDevice.driverState.warningDescription forState:UIControlStateNormal];
            [self.errorLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            if (errCnt) {
                self.errorLabel.backgroundColor = [UIColor grayColor];
            } else{
                self.errorLabel.backgroundColor = [UIColor lightGrayColor];
            }
        } else if ((!hiDevice.driverState.isError) && (!hiDevice.driverState.isHint)) {
            [self.errorLabel setTitle:@"无报警" forState:UIControlStateNormal];
            [self.errorLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.errorLabel.backgroundColor = [UIColor lightGrayColor];
        }

        
    } else {
        //tcp连接断开
        [self.errorLabel setTitle:@"与WiFi操作器连接断开" forState:UIControlStateNormal];
        [self.errorLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.errorLabel.backgroundColor = [UIColor redColor];
    }
    

    
    errCnt = ~errCnt;
    
    if (hiDevice.driverState.isSoftwareEnabled) {
        [_enabledSwitch setOn:YES];
    } else {
        [_enabledSwitch setOn:NO];
    }
    
    
    if (hiDevice.driverState.isPulseEnabled) {
        _enableImage.image = [UIImage imageNamed:@"green1"];
    } else
        _enableImage.image = [UIImage imageNamed:@"gray1"];
    
    
    if (hiDevice.driverState.isError) {
        _errorImage.image = [UIImage imageNamed:@"green1"];
    } else
        _errorImage.image = [UIImage imageNamed:@"gray1"];
    
    
    if (hiDevice.driverState.isBusy) {
        _busyImage.image = [UIImage imageNamed:@"green1"];
    } else
        _busyImage.image = [UIImage imageNamed:@"gray1"];
    
    if (hiDevice.driverState.isRunning) {
        _runningImage.image = [UIImage imageNamed:@"green1"];
    } else
        _runningImage.image = [UIImage imageNamed:@"gray1"];
    
    if (hiDevice.driverState.isReverse) {
        _reverseImage.image = [UIImage imageNamed:@"green1"];
    } else
        _reverseImage.image = [UIImage imageNamed:@"gray1"];
    
    if (hiDevice.driverState.isReady) {
        _readyImage.image = [UIImage imageNamed:@"green1"];
    } else
        _readyImage.image = [UIImage imageNamed:@"gray1"];
}

-(void)setTable{
//    NSLog(@"%@",[NSThread currentThread]);
    if (self->t) {
        //        self.paraTable.dataSource = self;
        //        self.paraTable.rowHeight = 52.5f;
        self->t = NO;
    } else {
        [self.paraTable reloadData];
        
        //        [self.paraTable reloadInputViews];
        //        NSArray *visibleCells = [self.parasTable indexPathsForVisibleRows];
        //        [self.parasTable reloadData];
        //        NSLog(@"%d",visibleCells.count);
        //        for (int i=0; i<self.visibleCells.count; i++)
        {
            //            [self.paraTable reloadRowsAtIndexPaths:self.visibleCells withRowAnimation:UITableViewRowAnimationAutomatic];
            //            [self.parasTable reloadRowsAtIndexPaths:<#(nonnull NSArray<NSIndexPath *> *)#> withRowAnimation:<#(UITableViewRowAnimation)#>]
        }
        //        NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
        //        [self.parasTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    }
//    NSLog(@"%@",[NSThread currentThread]);
    
    [self showDriverState];
    
//    self.errorLabel.titleLabel.text = hiDevice.driverState.errDescription;
}
/** 创建主界面 和左滑出现的界面
 */
- (void)setViews{
    
    _leftView = [[WJCLeftViewController alloc] init];
    _leftView.groupItems = hiDevice.paras.actualGroup;
    _leftView->theDelegate = self;
    [self addChildViewController:_leftView];
    [self.view addSubview:_leftView.view];
    
    _paraTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50) style:UITableViewStylePlain];
    self.paraTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.paraTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.paraTable.dataSource = self;
    self.paraTable.rowHeight = 52.5f;
    
    self.paraTable.delegate = self;
    
    
    _mainView = [[UIView alloc] initWithFrame:self.view.bounds];
    [_mainView addSubview:self.paraTable];
    
    
    //报警状态栏：1使能开关；2报警显示；3驱动器状态展开按钮
    _driverStatepanel = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50)];
    _driverStatepanel.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
    
    //1.使能开关
    UILabel *teLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, 55, 40)];
    teLabel.text = @"软使能";
    
    _enabledSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(63, 10, 55, 40)];
    _enabledSwitch.tintColor = [UIColor whiteColor];
    
    [_enabledSwitch addTarget:self action:@selector(changeSoftEnable:) forControlEvents:UIControlEventValueChanged];
    //2.报警显示，uibutton
    self.errorLabel = [[UIButton alloc] initWithFrame:CGRectMake(120, 0, self.view.bounds.size.width-44-120-4, 50)];
    self.errorLabel.titleLabel.numberOfLines = 2;
    [self.errorLabel addTarget:self action:@selector(resetAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //error长按动作
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(errorLabelLongP:)];
    longPress.minimumPressDuration = 0.8;
    [self.errorLabel addGestureRecognizer:longPress];
    

    //3.驱动器状态展开按钮
    UIButton *showBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-44, 5, 40, 40)];
    [showBtn setBackgroundImage:[UIImage imageNamed:@"if_fold"] forState:UIControlStateNormal];
    
    [showBtn addTarget:self action:@selector(unfoldAction:) forControlEvents:UIControlEventTouchUpInside];
    isDriverStateUnfolded = NO;
    
    [_driverStatepanel addSubview:teLabel];
    [_driverStatepanel addSubview:_enabledSwitch];
    [_driverStatepanel addSubview:showBtn];
    [_driverStatepanel addSubview:self.errorLabel];
    
    
    //驱动器状态灯
    _statusPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
    _statusPanel.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];

    
    _statusImages = [[NSMutableArray alloc] initWithCapacity:6];
    _statusImageLabels = [[NSMutableArray alloc] initWithCapacity:6];
    
    //驱动器状态label
    float temF = self.view.bounds.size.width / 3;
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(40, 2, (temF)-40, 30)];
    label1.text = @"Enabled";
    [_statusImageLabels addObject:label1];

    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(40 + (temF), 2, temF-40, 30)];
    label2.text = @"Error";
    [_statusImageLabels addObject:label2];

    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(40 + (temF)*2, 2, temF-40, 30)];
    label3.text = @"Busy";
    [_statusImageLabels addObject:label3];

    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(40, 32, temF-40, 30)];
    label4.text = @"Running";
    [_statusImageLabels addObject:label4];

    UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(40 + temF, 32, (self.view.bounds.size.width / 3)-40, 30)];
    label5.text = @"Reverse";
    [_statusImageLabels addObject:label5];

    UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(40 + temF*2, 32, temF-40, 30)];
    label6.text = @"Ready";
    [_statusImageLabels addObject:label6];
    
    //驱动器状态图标
    _enableImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gray1"]];
    [_statusImages addObject:_enableImage];

    _errorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gray1"]];
    [_statusImages addObject:_errorImage];
    
    _busyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gray1"]];
    [_statusImages addObject:_busyImage];

    _runningImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gray1"]];
    [_statusImages addObject:_runningImage];
    
    _reverseImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gray1"]];
    [_statusImages addObject:_reverseImage];

    _readyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gray1"]];
    [_statusImages addObject:_readyImage];

    for (int i=0; i<6; i++) {
        [_statusPanel addSubview:_statusImages[i]];
        [_statusPanel addSubview:_statusImageLabels[i]];
    }
    //收起状态灯
    _driverStatepanel.frame = CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50);
    _statusPanel.frame = CGRectMake(0, self.view.bounds.size.height-60, 0, 0);
    _paraTable.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50);
    
    float temFte = self.view.bounds.size.width / 3;
    for (int i=0; i<3; i++) {
        _statusImages[i].frame = CGRectMake(temFte*i, 2, 30, 0);
        _statusImageLabels[i].frame = CGRectMake(40+temFte*i, 2, temFte - 40, 0);
    }
    for (int i=3; i<6; i++) {
        _statusImages[i].frame = CGRectMake((self.view.bounds.size.width / 3)*(i-3), 32, 30, 0);
        _statusImageLabels[i].frame = CGRectMake(40+temFte*(i-3), 32, temFte - 40, 0);
    }
    
    [_mainView addSubview:_driverStatepanel];
    [_mainView addSubview:_statusPanel];
    
    
    [self.view addSubview:_mainView];
    

}

- (void)changeSoftEnable:(UISwitch*)sender{
    
    if (isOffline) {
        
    } else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认是否切换使能" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            hiDevice.driverState.toChangeSoftwareEnabled = YES;
        }];
        UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            
        }];
        [alert addAction:okAlert];
        [alert addAction:cancelAlert];
        [self presentViewController:alert animated:YES completion:nil];
    }

}
//重连接
-(void)reconnectSocket{
    BOOL reconnectBool = [hiDevice.hiCom reconnectSocket];
    if (reconnectBool){
        [self popDialogWithTittle:@"提示" message:@"重连接成功！"];
    } else {
        [self popDialogWithTittle:@"提示" message:@"重连接失败！"];
    }
}
/**
 按钮动作，重连接
 */
-(void)errorLabelLongP:(UILongPressGestureRecognizer*)gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        NSLog(@"长按事件");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否重连接WiFi操作器？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            //                [hiDevice.hiCom reconnectSocket];
            [self reconnectSocket];
        }];
        UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            
        }];
        [alert addAction:okAlert];
        [alert addAction:cancelAlert];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

/**
按钮动作，重置
 */
-(void)resetAction:(UIButton*)sender{
    
    if (isOffline) {
        
    } else{
        if (hiDevice.hiCom.clientSocket.isConnected){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否清除报警" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                hiDevice.driverState.toReset = YES;
            }];
            UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                
            }];
            [alert addAction:okAlert];
            [alert addAction:cancelAlert];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否重连接WiFi操作器？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//                [hiDevice.hiCom reconnectSocket];
                [self reconnectSocket];
            }];
            UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                
            }];
            [alert addAction:okAlert];
            [alert addAction:cancelAlert];
            [self presentViewController:alert animated:YES completion:nil];
        }

    }

}


/**
 展开／收起驱动器状态灯，按钮
 */
-(void)unfoldAction:(UIButton*)sender{
//    BOOL test = [hiDevice.hiCom reconnectSocket];
    
    if (isDriverStateUnfolded) {
        //收起状态灯
        [sender setBackgroundImage:[UIImage imageNamed:@"if_fold"] forState:UIControlStateNormal];
        
        _driverStatepanel.frame = CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50);
        _statusPanel.frame = CGRectMake(0, self.view.bounds.size.height-60, 0, 0);
        _paraTable.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50);

        float temF = self.view.bounds.size.width / 3;
        for (int i=0; i<3; i++) {
            _statusImages[i].frame = CGRectMake(temF*i, 2, 30, 0);
            _statusImageLabels[i].frame = CGRectMake(40+temF*i, 2, temF - 40, 0);
        }
        for (int i=3; i<6; i++) {
            _statusImages[i].frame = CGRectMake((self.view.bounds.size.width / 3)*(i-3), 32, 30, 0);
            _statusImageLabels[i].frame = CGRectMake(40+temF*(i-3), 32, temF - 40, 0);
        }
    } else {
        //展开状态灯
        [sender setBackgroundImage:[UIImage imageNamed:@"if_unfold"] forState:UIControlStateNormal];
        _driverStatepanel.frame = CGRectMake(0, self.view.bounds.size.height-50-60, self.view.bounds.size.width, 50);
        _statusPanel.frame = CGRectMake(0, self.view.bounds.size.height-60, self.view.bounds.size.width, 60);
        _paraTable.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50-60);
        float temF = self.view.bounds.size.width / 3;
        for (int i=0; i<3; i++) {
            _statusImages[i].frame = CGRectMake(5+temF*i, 2, 30, 30);
            _statusImageLabels[i].frame = CGRectMake(40+temF*i, 2, temF - 40, 30);
        }
        for (int i=3; i<6; i++) {
            _statusImages[i].frame = CGRectMake(5+temF*(i-3), 32, 30, 30);
            _statusImageLabels[i].frame = CGRectMake(40+temF*(i-3), 32, temF - 40, 30);
        }
        
    }
    isDriverStateUnfolded = ~ isDriverStateUnfolded;
    
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

#pragma mark - 页面跳转


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
                    [YCXMenuItem menuItem:@"工程或文件"
                                    image:nil
                                      tag:100
                                 userInfo:@{@"title":@"Menu"}],
                    [YCXMenuItem menuItem:@"远程协助"
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
#pragma mark - 线程操作

- (void)readThread{
    
    while (1) {
        WJCOneGroup *tpGroup = hiDevice.paras.actualGroup[self->nowGroup];
        //            NSArray *visibleCells = [self.parasTable indexPathsForVisibleRows];
        //            NSInteger count = visibleCells.count;
        
        //        [self performSelectorOnMainThread:@selector(readVisibleCells) withObject:nil waitUntilDone:YES];
        
        //刷新驱动器状态和标幺值
        [hiDevice.perUnitValues uploadPerUnitValues:hiDevice.hiCom];
        [hiDevice.driverState uploadDriverStateWithHiCom:hiDevice.hiCom withDescDealer:hiDevice.descDealer];
        
        if (self.visibleCells.count <= 0) {
            [self performSelectorOnMainThread:@selector(readVisibleCells) withObject:nil waitUntilDone:YES];
        }
        for (int i = self.visibleCells[0].row; i<=self.visibleCells[self.visibleCells.count-1].row; i++)
            //        for (int i = 0; i<tpGroup.visibleItems.count; i++)
        {
            WJCOneParameter *nowOnePara = hiDevice.paras.paras[tpGroup.visibleItems[i]->index];
            [hiDevice.hiCom readWithPara:nowOnePara isArrayEnable:false];
//            NSString *tempps;
//            if (hiDevice.paras.paras[tpGroup.visibleItems[i]->index].isString) {
//                tempps = [hiDevice.hiCom readStringData:tpGroup.visibleItems[i]->index subindex:0];//[self.hiCom readData:((WJCOneParameter *)(self.paraArray[i])).index subindex:0];
//                [hiDevice.paras.paras[tpGroup.visibleItems[i]->index] setValHex:0 arrayIndex:0 val:tempps];
//            } else if (hiDevice.paras.paras[tpGroup.visibleItems[i]->index].isArray){
//
//            } else {
//                tempps = [hiDevice.hiCom readData:tpGroup.visibleItems[i]->index subindex:0];//[self.hiCom readData:((WJCOneParameter *)(self.paraArray[i])).index subindex:0];
//                [hiDevice.paras.paras[tpGroup.visibleItems[i]->index] setValHex:0 arrayIndex:0 val:tempps];
//            }
            

//            if (([tempps length] != ([hiDevice.paras.paras[tpGroup.visibleItems[i]->index].defHex length])) && (![tempps isEqualToString:COMM_TIMEOUT]) ){
//                NSLog(@"%@--%@--%@",hiDevice.paras.paras[tpGroup.visibleItems[i]->index].sDescribe,hiDevice.paras.paras[tpGroup.visibleItems[i]->index].defHex,tempps);
//            }
            
            [NSThread sleepForTimeInterval:0.02f];
            
            
            
            
            if (changeGroupB) {
                changeGroupB = NO;
                self->nowGroup = tempG;
                //            [self performSelectorOnMainThread:@selector(changeGroup) withObject:nil waitUntilDone:YES];
                [_paraTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                [self performSelectorOnMainThread:@selector(readVisibleCells) withObject:nil waitUntilDone:YES];
                tpGroup = hiDevice.paras.actualGroup[self->nowGroup];
                continue;
            }
            
            if (scrollChange) {
                scrollChange = NO;
                [self performSelectorOnMainThread:@selector(readVisibleCells) withObject:nil waitUntilDone:YES];
                continue;
            }
            if ([[NSThread currentThread] isCancelled]) {
                [NSThread exit];
                
            }
        }
        

        
        
        
//        [self performSelectorOnMainThread:@selector(setTable) withObject:nil waitUntilDone:NO];
    }
}




#pragma mark - 侧滑效果

//手指点击控制器的View.
- (void)tap{
    
    //让Main的frame跟控制器的尺寸大小一样.
    [UIView animateWithDuration:0.25 animations:^{
        self.mainView.frame = self.view.bounds;
    }];
    
}



//当手指拖动时调用.
-(void)pan:(UIPanGestureRecognizer *)pan{
    
    //获取手指在屏幕上面的偏移量
    CGPoint transP = [pan translationInView:self.mainView];
    
    //在这里为什么不用Transform,是因为我们移动时,要改变的尺寸大小.用Transform只能改变它的位置.
    //    self.mainV.transform  = CGAffineTransformTranslate(self.mainV.transform, transP.x, 0);
    
    //计算mainV的Frame
    self.mainView.frame = [self frameWithOffsetX:transP.x];
    
    //判断当前MainV的x值是大于0还是小于0.如果是大于0 , 显示左边,小于0 显示右边
    
//    if (self.mainView.frame.origin.x > 0) {
//        self.leftView.hidden = YES;
//    }else if(self.mainView.frame.origin.x < 0){
//        self.leftView.hidden = NO;
//    }
    
    //判断手指的状态
    if(pan.state == UIGestureRecognizerStateEnded){
        
        CGFloat target = 0;
        //当手指松开,要判断MainV的x值是否大于屏幕的一半.如果大于屏幕一半时, 自动定位到右边一个位置.
        if (self.mainView.frame.origin.x > screenW * 0.2) {
            target = targetR;
        }else if(CGRectGetMaxX(self.mainView.frame) < screenW * 0.2){
            //当手指松开,要判断MainV的最大的X值是否小于屏幕的一半.如果小于屏幕的一半时, 自动定位到左边的位置.
            target = targetL;
        }
        
        CGFloat offsetX = target - self.mainView.frame.origin.x;
//        NSLog(@"%f",offsetX);
        CGRect frame =  [self frameWithOffsetX:offsetX];
        [UIView animateWithDuration:0.18 animations:^{
            
            self.mainView.frame = frame;
        }];
        
    }
    //复位
    [pan setTranslation:CGPointZero inView:self.mainView];
    
}


//根据偏移量计算mainV的frame.
- (CGRect)frameWithOffsetX:(CGFloat)offsetX{
    
    
    //取出最原始的Frame
    CGRect frame = self.mainView.frame;
    frame.origin.x += offsetX;
    //获取屏幕的宽度
    //有可能frame.origin.x有可能是小于0,小于0的话, 得出的Y值就会小于0,小于0就会出现, 红色的View向上走.
    //对结果取绝对值.
    //    frame.origin.y =  fabs(frame.origin.x * maxY / screenW);
    //计算frame的高度
    frame.size.height = screenH - 2 * frame.origin.y;
    
    return frame;
}






- (void)changeGroupWithIndex:(int)rIndex{

    if (isOffline) {
        self->nowGroup = rIndex;
        [self.paraTable reloadData];
    } else{
        tempG = rIndex;
        changeGroupB = YES;
        [UIView animateWithDuration:0.2 animations:^{
            self.mainView.frame = self.view.bounds;
        }];
    }
}

#pragma mark - TableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return hiDevice.paras.actualGroup[self->nowGroup].visibleItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
     static NSString *identifier= @"car";
     WJCCarView *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
     if (cell == nil) {
     cell = [[[NSBundle mainBundle] loadNibNamed:@"CarView" owner:nil options:nil] firstObject];
     }
     */
    static NSString *identifier= @"MainCell";
    WJCOneParaViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [WJCOneParaViewCell oneParaViewCellWithTableView:tableView];
        //    cell.descDealer = hiDevice.descDealer;
        //    cell.onePara = hiDevice.paras.paras[hiDevice.paras.actualGroup[self->nowGroup].visibleItems[indexPath.row]->index];

        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //cell分隔线
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    [cell loadCellInfoWithPara:hiDevice.paras.paras[hiDevice.paras.actualGroup[self->nowGroup].visibleItems[indexPath.row]->index] withParaName:hiDevice.paras.actualGroup[self->nowGroup].visibleItems[indexPath.row]->abbreviativeName withDesc:hiDevice.descDealer];
    //    [cell setSeparatorInset:UIEdgeInsetsZero];
    return cell;
}


#pragma mark - TableView ScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    scrollChange = YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WJCOneParameter *tempPara = hiDevice.paras.paras[hiDevice.paras.actualGroup[self->nowGroup].visibleItems[indexPath.row]->index];
    NSString *paraName = hiDevice.paras.actualGroup[self->nowGroup].visibleItems[indexPath.row]->abbreviativeName;
    if ((tempPara.isArray) && (tempPara.isDataSet)) {
        
        WJCDatasetParaTable *tempT = [[WJCDatasetParaTable alloc] initWithDescDealer:hiDevice.descDealer withPara:tempPara withComm:hiDevice.hiCom withIsOffline:isOffline withParaName:paraName];
        [self.navigationController pushViewController:tempT animated:YES];
        
    } else if ((!tempPara.isArray) && (tempPara.isDataSet)) {
        
        WJCDatasetParaTable *tempT = [[WJCDatasetParaTable alloc] initWithDescDealer:hiDevice.descDealer withPara:tempPara withComm:hiDevice.hiCom withIsOffline:isOffline withParaName:paraName];
        [self.navigationController pushViewController:tempT animated:YES];
        
        
    } else if ((tempPara.isArray) && (!tempPara.isDataSet)) {
        
        WJCArrayParaTable *tempT = [[WJCArrayParaTable alloc] initWithDescDealer:hiDevice.descDealer withPara:tempPara withComm:hiDevice.hiCom withIsOffline:isOffline withParaName:paraName withSubindex:0];
        [self.navigationController pushViewController:tempT animated:YES];
        
        
    } else if ((!tempPara.isArray) && (!tempPara.isDataSet)) {
        
        WJCUiParaEditor *paraView = [[WJCUiParaEditor alloc] initWitPara:tempPara withName:paraName withDescDealer:hiDevice.descDealer withSubindex:0 withArrayIndex:0 withCom:hiDevice.hiCom withOffline:isOffline];
        [self.navigationController pushViewController:paraView animated:YES];
        
        
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
