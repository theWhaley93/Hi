//
//  WJCWorklistViewController.m
//  Hi
//
//  Created by apple on 2018/5/25.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCWorklistViewController.h"
#import "WJCWorklistViewCell.h"
#import "YCXMenu.h"
#import "WJCWorkllistParaEditor.h"
#import "WJCWorklistEditorView.h"
#import "WJCWorklistDataSetController.h"
#import "WJCArrayParaTable.h"
#import "LCLoadingHUD.h"
#import "WJCGlobalConstants.h"

typedef enum{
    WJCWorklistOtherOperateNone,WJCWorklistOtherOperateResetPara,WJCWorklistOtherOperateSelfLearn,WJCWorklistOtherOperateAutoCorrection
}WJCWorklistOtherOperate;

@interface WJCWorklistViewController ()<WJCDownloadWorklistDelegate,UITableViewDelegate,UITableViewDataSource>{
    Boolean isOffline;
    WJCWorklistOperate nowWorklistOperate;
    WJCWorklistOtherOperate nowWorklistOtherOperate;
    int uploadTimes;
    Boolean isDriverStateUnfolded;  //驱动器状态显示是否展开
    Boolean errCnt; //驱动器报警闪烁
    float t1,t2,t3,t4;
}



@property (nonatomic,strong)  NSThread *nowThread;  //

@property (nonatomic,strong)  NSTimer *uiTimer;  //
@property (nonatomic , strong) NSMutableArray *items;   //bar button显示菜单：

@property (nonatomic,strong)  UITableView *tableView;  //

@property (nonatomic,strong)  UIView *driverStatepanel;  //

@property (nonatomic,strong)  UIButton *errorLabel;  //报警

@property (nonatomic,strong)  UIView *statusPanel;  //驱动器状态


@property (nonatomic,strong)  UISwitch *enabledSwitch;  //软使能切换

//@property (nonatomic,strong)  NSMutableArray<UIImageView *> *statusImages;  //
//@property (nonatomic,strong)  NSMutableArray<UILabel *> *statusImageLabels;  //
@property (nonatomic,strong)  NSMutableArray<UIButton *> *opButton;  //
@property (nonatomic,strong)  NSMutableArray<UILabel *> *worklistLabel;  //
@property (nonatomic,strong)  NSMutableArray<NSString *> *worklistLabelVal;  //

@property (nonatomic,strong)  WJCOneParameter *dr12Para;  //
@property (nonatomic,strong)  WJCOneParameter *an05Para;  //
@end

@implementation WJCWorklistViewController
@synthesize items = _items;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViews];
    [self setRightButtons];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = _nowWorklist.name;
    
    //清除多余cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    self.tableView.rowHeight = 66.5;
    
    if (isOffline) {
        
    } else {
        _uiTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(setTable) userInfo:nil repeats:YES];
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9){
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;//9.0以上才有这个属性，针对ipad
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    if (isOffline) {
        [self.tableView reloadData];
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
#pragma mark - 初始化controller
- (instancetype)initWithWorklist:(WJCHiWorklist *)rWorklist withDevice:(WJCDevice *)rDevice withIsOffline:(Boolean)rIsOffline{
    if (self = [super init]) {
        _nowWorklist = rWorklist;
        _nowWorklist.theDelegate = self;
        _nowDevice = rDevice;
        isOffline = rIsOffline;
        nowWorklistOperate = WJCWorklistOperateNone;
        nowWorklistOtherOperate = WJCWorklistOtherOperateNone;
        _an05Para = [rDevice.paras getOneParaWithIndex:609];
        _dr12Para = [rDevice.paras getOneParaWithIndex:161];
        _worklistLabelVal = [[NSMutableArray alloc] initWithCapacity:2];
        _worklistLabelVal[0] = @"DR12:";
        _worklistLabelVal[1] = @"AN05:";
    }
    return self;
}
#pragma mark - 界面创建
/** 创建主界面 和左滑出现的界面
 */
- (void)setViews{
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50) style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 66.5f;
    
    self.tableView.delegate = self;
    
    
    [self.view addSubview:self.tableView];
    
    
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
    
    _opButton = [[NSMutableArray alloc] initWithCapacity:3];
    
    float temF = self.view.bounds.size.width / 3;
    float btnWidth = temF -20;
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(10, 4, btnWidth, 35)];
    [button1 setTitle:@"" forState:UIControlStateNormal];
    button1.backgroundColor = [UIColor darkGrayColor];
    
    [button1 setBackgroundImage:[self imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    [button1.layer setCornerRadius:6.0];
    [button1 addTarget:self action:@selector(resetPara) forControlEvents:UIControlEventTouchUpInside];
    [_opButton addObject:button1];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(10+temF, 4, btnWidth, 35)];
    [button2 setTitle:@"" forState:UIControlStateNormal];
    button2.backgroundColor = [UIColor darkGrayColor];
    
    [button2 setBackgroundImage:[self imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    [button2.layer setCornerRadius:6.0];
    [button2 addTarget:self action:@selector(selfLearn) forControlEvents:UIControlEventTouchUpInside];
    [_opButton addObject:button2];
    
    UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(10+2*temF, 4, btnWidth, 35)];
    [button3 setTitle:@"" forState:UIControlStateNormal];
    button3.backgroundColor = [UIColor darkGrayColor];
    
    [button3 setBackgroundImage:[self imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    [button3.layer setCornerRadius:6.0];
    [button3 addTarget:self action:@selector(autoCorrection) forControlEvents:UIControlEventTouchUpInside];
    [_opButton addObject:button3];
    for (int i=0; i<3; i++) {
        [_statusPanel addSubview:_opButton[i]];
    }
    
    _worklistLabel = [[NSMutableArray alloc] initWithCapacity:2];
    float temF2 = self.view.bounds.size.width / 2;
    float lblWidth = temF2 -10;
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(30, 44, lblWidth, 17)];
    label1.text = _worklistLabelVal[0];
    [_worklistLabel addObject:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10+temF2, 44, lblWidth, 17)];
    label2.text = _worklistLabelVal[1];
    [_worklistLabel addObject:label2];
    for (int i=0; i<2; i++) {
        [_statusPanel addSubview:_worklistLabel[i]];
    }
    /*
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
    */
    [self.view addSubview:_driverStatepanel];
    [self.view addSubview:_statusPanel];
    
    //收起状态灯
    
    _driverStatepanel.frame = CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50);
    _statusPanel.frame = CGRectMake(0, self.view.bounds.size.height-65, 0, 0);
    _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50);
    
    float temFte = self.view.bounds.size.width / 3;
    float btnWidthte = temFte - 20;
    for (int i=0; i<3; i++) {
        _opButton[i].frame = CGRectMake(temFte*i+10, 4, btnWidthte, 0);
        //            _statusImageLabels[i].frame = CGRectMake(40+temF*i, 2, temF - 40, 0);
    }
    float temF2te = self.view.bounds.size.width / 2;
    float lblWidthte = temFte - 10;
    _worklistLabel[0].frame = CGRectMake(30, 44, lblWidthte, 0);
    _worklistLabel[1].frame = CGRectMake(30+temF2te, 44, lblWidthte, 0);

    
    
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
#pragma mark - 界面操作
- (void)resetPara{
    if (isOffline) {
        
    } else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否重置参数？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            nowWorklistOtherOperate = WJCWorklistOtherOperateResetPara;
            [self startWorklistOperate:@"正在设定参数..."];
        }];
        UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            
        }];
        [alert addAction:okAlert];
        [alert addAction:cancelAlert];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (void)selfLearn{
    if (isOffline) {
        
    } else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否设定参数DR12为1212？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            nowWorklistOtherOperate = WJCWorklistOtherOperateSelfLearn;
            [self startWorklistOperate:@"正在设定参数..."];
        }];
        UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            
        }];
        [alert addAction:okAlert];
        [alert addAction:cancelAlert];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (void)autoCorrection{
    if (isOffline) {
        
    } else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否设置模拟量自动校正，AN18设为4？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            nowWorklistOtherOperate = WJCWorklistOtherOperateAutoCorrection;
            [self startWorklistOperate:@"正在设定参数..."];
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

- (void)showDriverState{
    //状态栏报警
    if(hiDevice.hiCom.clientSocket.isConnected){
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
    _worklistLabelVal[0] = [NSString stringWithFormat:@"DR12: %@",[_dr12Para showParaDesc:[_dr12Para valHexWithSubindex:0 withArrayIndex:0] descD:_nowDevice.descDealer]];
    _worklistLabelVal[1] = [NSString stringWithFormat:@"AN05: %@",[_an05Para showParaDesc:[_an05Para valHexWithSubindex:0 withArrayIndex:0] descD:_nowDevice.descDealer]];
    for (int i=0; i<2; i++) {
        _worklistLabel[i].text = _worklistLabelVal[i];
    }
}

- (void)changeSoftEnable:(UISwitch*)sender{
    
    if (isOffline) {
        
    } else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认是否切换使能" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            _nowDevice.driverState.toChangeSoftwareEnabled = YES;
        }];
        UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            
        }];
        [alert addAction:okAlert];
        [alert addAction:cancelAlert];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}
/**
 展开／收起驱动器状态灯，按钮
 */
-(void)unfoldAction:(UIButton*)sender{
    
    if (isDriverStateUnfolded) {
        //收起状态灯
        [sender setBackgroundImage:[UIImage imageNamed:@"if_fold"] forState:UIControlStateNormal];
        
        _driverStatepanel.frame = CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50);
        _statusPanel.frame = CGRectMake(0, self.view.bounds.size.height-65, 0, 0);
        _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50);
        
        float temF = self.view.bounds.size.width / 3;
        float btnWidth = temF - 20;
        for (int i=0; i<3; i++) {
            _opButton[i].frame = CGRectMake(temF*i+10, 4, btnWidth, 0);
            [_opButton[i] setTitle:@"" forState:UIControlStateNormal];
//            _statusImageLabels[i].frame = CGRectMake(40+temF*i, 2, temF - 40, 0);
        }
        float temF2 = self.view.bounds.size.width / 2;
        float lblWidth = temF - 10;
        _worklistLabel[0].frame = CGRectMake(30, 44, lblWidth, 0);
        _worklistLabel[1].frame = CGRectMake(30+temF2, 44, lblWidth, 0);
    } else {
        //展开状态灯
        [sender setBackgroundImage:[UIImage imageNamed:@"if_unfold"] forState:UIControlStateNormal];
        _driverStatepanel.frame = CGRectMake(0, self.view.bounds.size.height-50-65, self.view.bounds.size.width, 50);
        _statusPanel.frame = CGRectMake(0, self.view.bounds.size.height-65, self.view.bounds.size.width, 65);
        _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50-65);
        float temF = self.view.bounds.size.width / 3;
        float btnWidth = temF - 20;
        NSArray *buttonTitleA = @[@"参数重置",@"寻零",@"零漂"];
        for (int i=0; i<3; i++) {
            _opButton[i].frame = CGRectMake(temF*i+10, 4, btnWidth, 35);
            [_opButton[i] setTitle:buttonTitleA[i] forState:UIControlStateNormal];
//            _statusImageLabels[i].frame = CGRectMake(40+temF*i, 2, temF - 40, 30);
        }
        float temF2 = self.view.bounds.size.width / 2;
        float lblWidth = temF - 10;
        _worklistLabel[0].frame = CGRectMake(30, 44, lblWidth, 17);
        _worklistLabel[1].frame = CGRectMake(30+temF2, 44, lblWidth, 17);
    }
    isDriverStateUnfolded = ~ isDriverStateUnfolded;
}

- (void)setTable{
//    NSLog(@"%@",[NSThread currentThread]);
    [self.tableView reloadData];
    [self showDriverState];
}

- (void)startWorklistOperate:(NSString *)rOperateInfo{
    [LCLoadingHUD showLoading:rOperateInfo];
}
- (void)startWorklistOperateType1{
    [LCLoadingHUD showLoading:@"正在下载参数至驱动器..."];
}
- (void)startWorklistOperateType2{
    [LCLoadingHUD showLoading:@"正在执行结束动作..."];
}
- (void)endWorklistOperate{
    [LCLoadingHUD hideInKeyWindow];
}
- (void)WorklistOtherOperateSuccess{
    [self popDialogWithTittle:@"提示" message:@"操作成功！"];
}
- (void)WorklistOtherOperateFail{
    [self popDialogWithTittle:@"提示" message:@"操作失败，请重试！"];
}
/**弹出提示框
 */
- (void)popDialogWithTittle:(NSString *)rTittle message:(NSString *)rMessage{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:rTittle message:rMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
    }];
    [alert addAction:okAlert];
    dispatch_async(dispatch_get_main_queue(), ^{
       // UI更新代码
       [self presentViewController:alert animated:YES completion:nil];
    });
    
}
- (void)uploadSuccess{
    [self popDialogWithTittle:@"提示" message:@"上传参数完成"];
}

#pragma mark - 菜单栏内容
- (void)setRightButtons{
    //    UIBarButtonItem *barMenu = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showMenu)];
    UIBarButtonItem *barMenu = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"if_more3"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
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
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        t1 = self.navigationController.navigationBar.frame.size.height;
        t2 = statusBarFrame.size.height;
        t3 = 0;
//        if((t2==40) ||(t2>44))
        if((t2==40))
            t3=20;
        [YCXMenu showMenuInView:self.tableView fromRect:CGRectMake(self.view.frame.size.width - 50, t1+t2-t3, 50, 0) menuItems:self.items selected:^(NSInteger index, YCXMenuItem *item) {
            
            //点击右上角菜单
            switch (index) {
                case 0:{
                    WJCWorklistEditorView *worklistEditor = [[WJCWorklistEditorView alloc] initWithHiPara:_nowDevice.paras withWorklist:_nowWorklist];
                    [self.navigationController pushViewController:worklistEditor animated:YES];
                    
                    break;
                }
                case 1:
                    if (isOffline) {
                        
                    } else{
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定下载参数至驱动器？" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                            nowWorklistOperate = WJCWorklistOperateDownload;
                            [self startWorklistOperate:@"正在下载参数至驱动器..."];
                        }];
                        UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                            
                        }];
                        [alert addAction:okAlert];
                        [alert addAction:cancelAlert];
                        [self presentViewController:alert animated:YES completion:nil];
                    }

                    break;
                case 2:
                    if (isOffline) {
                        
                    } else{
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定从驱动器上传参数？" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                            nowWorklistOperate = WJCWorklistOperateUpload;
                            uploadTimes = 0;
                            [self startWorklistOperate:@"正在从驱动器上传参数..."];
                        }];
                        UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                            
                        }];
                        [alert addAction:okAlert];
                        [alert addAction:cancelAlert];
                        [self presentViewController:alert animated:YES completion:nil];
                    }

                    break;
                case 3:{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请输入要保存的文件名" preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert];
                    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        textField.text = _nowWorklist.name;
                    }];
                    
                    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        //保存文件
                        NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                        NSString *saveName = [NSString stringWithFormat:@"%@%@%@%@",dirPath,@"/",alert.textFields[0].text,@".htnwk"];//alert.textFields[0].text;
                        //                        NSString *savePath = [NSString stringWithFormat:@"%@%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject],@"/AddressListFiles/CFGID98.plst"];
                        NSString *contentStr = [_nowWorklist worklistToString];
                        [contentStr writeToFile:saveName atomically:YES encoding:NSUTF16LittleEndianStringEncoding error:NULL];
                        
                        
                        
                        
                        
                    }];
                    [alert addAction:okAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                        
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                    break;
                }
                case 4:{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请输入要创建的worklist名称" preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert];
                    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        textField.text = _nowWorklist.name;
                    }];
                    
                    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        //修改worklistname
                        _nowWorklist.name = alert.textFields[0].text;
                        self.title = _nowWorklist.name;
                        
                        
                        
                    }];
                    [alert addAction:okAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                        
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                    break;
                }
            }
            
            //            NSLog(@"%@",item);
        }];
    }
}

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
                    [YCXMenuItem menuItem:@"编辑参数"
                                    image:nil
                                      tag:100
                                 userInfo:@{@"title":@"Menu"}],
                    [YCXMenuItem menuItem:@"下载参数"
                                    image:nil
                                      tag:101
                                 userInfo:@{@"title":@"Menu"}],
                    [YCXMenuItem menuItem:@"上传参数"
                                    image:nil
                                      tag:101
                                 userInfo:@{@"title":@"Menu"}],
                    [YCXMenuItem menuItem:@"保存文件"
                                    image:nil
                                      tag:102
                                 userInfo:@{@"title":@"Menu"}],
                    [YCXMenuItem menuItem:@"修改worklist名"
                                    image:nil
                                      tag:102
                                 userInfo:@{@"title":@"Menu"}]
                    ] mutableCopy];
    }
    return _items;
}

- (void)setItems:(NSMutableArray *)items {
    _items = items;
}
#pragma mark-线程操作
- (void)readWorklistData{
//    _an05Para = [rDevice.paras getOneParaWithIndex:609];
//    _dr12Para = [rDevice.paras getOneParaWithIndex:161];
    NSString *readD1 = [_nowDevice.hiCom readData:_dr12Para.index subindex:0];
    [_dr12Para setValHexWithSubindex:0 withArrayIndex:0 val:readD1];
    
    NSString *readD2 = [_nowDevice.hiCom readData:_an05Para.index subindex:0];
    [_an05Para setValHexWithSubindex:0 withArrayIndex:0 val:readD2];
}

- (void)readThread{
    while (1) {
        
        [self readWorklistData];
        //刷新驱动器状态和标幺值
        [hiDevice.perUnitValues uploadPerUnitValues:hiDevice.hiCom];
        [hiDevice.driverState uploadDriverStateWithHiCom:hiDevice.hiCom withDescDealer:hiDevice.descDealer];
        
        for (int i=0; i<_nowWorklist.item.count; i++) {
            [_nowDevice.hiCom readWithPara:_nowWorklist.item[i].nowPara isArrayEnable:YES];
            [NSThread sleepForTimeInterval:0.02f];
            
            if ([[NSThread currentThread] isCancelled]) {
                [NSThread exit];
                
            }
            
        }
        [self otherOperate];
        [self doWorklistOperate];
        if ([[NSThread currentThread] isCancelled]) {
            [NSThread exit];
            
        }
    }
}
#pragma mark - other operate
- (void)otherOperate{
    NSString *writeResult;
    
    switch (nowWorklistOtherOperate) {
        case WJCWorklistOtherOperateNone:{

            break;
        }
        case WJCWorklistOtherOperateResetPara:{
            WJCOneParameter *tempPara = [_nowDevice.paras getOneParaWithIndex:1121];
            writeResult = [_nowDevice.hiCom writeWithIndex:tempPara.index withSubindex:0 withData:@"000A" withDataLen:tempPara.len];
            nowWorklistOtherOperate = WJCWorklistOtherOperateNone;
            if ([writeResult isEqualToString:COMM_SUC]) {
                [self performSelectorOnMainThread:@selector(WorklistOtherOperateSuccess) withObject:nil waitUntilDone:NO];
            } else {
                [self performSelectorOnMainThread:@selector(WorklistOtherOperateFail) withObject:nil waitUntilDone:NO];
            }
            [self performSelectorOnMainThread:@selector(endWorklistOperate) withObject:nil waitUntilDone:YES];
            break;}
        case WJCWorklistOtherOperateSelfLearn:{
            WJCOneParameter *tempPara = [_nowDevice.paras getOneParaWithIndex:161];
            writeResult = [_nowDevice.hiCom writeWithIndex:tempPara.index withSubindex:0 withData:@"04BC" withDataLen:tempPara.len];
            nowWorklistOtherOperate = WJCWorklistOtherOperateNone;
            if ([writeResult isEqualToString:COMM_SUC]) {
                [self performSelectorOnMainThread:@selector(WorklistOtherOperateSuccess) withObject:nil waitUntilDone:NO];
            } else {
                [self performSelectorOnMainThread:@selector(WorklistOtherOperateFail) withObject:nil waitUntilDone:NO];
            }
            [self performSelectorOnMainThread:@selector(endWorklistOperate) withObject:nil waitUntilDone:YES];
            break;}
        case WJCWorklistOtherOperateAutoCorrection:{
            WJCOneParameter *tempPara = [_nowDevice.paras getOneParaWithIndex:623];
            writeResult = [_nowDevice.hiCom writeWithIndex:tempPara.index withSubindex:0 withData:@"0004" withDataLen:tempPara.len];
            nowWorklistOtherOperate = WJCWorklistOtherOperateNone;
            if ([writeResult isEqualToString:COMM_SUC]) {
                [self performSelectorOnMainThread:@selector(WorklistOtherOperateSuccess) withObject:nil waitUntilDone:NO];
            } else {
                [self performSelectorOnMainThread:@selector(WorklistOtherOperateFail) withObject:nil waitUntilDone:NO];
            }
            [self performSelectorOnMainThread:@selector(endWorklistOperate) withObject:nil waitUntilDone:YES];
            break;}
    }
}
#pragma mark-上传下载操作
- (void)doWorklistOperate{
    
    switch (nowWorklistOperate) {
        case WJCWorklistOperateNone:
            
            break;
            
        case WJCWorklistOperateDownload:
            [_nowWorklist downloadSettingVals:_nowDevice.hiCom];
            nowWorklistOperate = WJCWorklistOperateNone;
            [self performSelectorOnMainThread:@selector(endWorklistOperate) withObject:nil waitUntilDone:NO];
            break;
        case WJCWorklistOperateUpload:
            
            [_nowWorklist onlineValsToSettingVals];
            
            if (uploadTimes>1) {
                [self performSelectorOnMainThread:@selector(endWorklistOperate) withObject:nil waitUntilDone:NO];
                [self performSelectorOnMainThread:@selector(uploadSuccess) withObject:nil waitUntilDone:NO];
                nowWorklistOperate = WJCWorklistOperateNone;
            }
            uploadTimes += 1;
            break;
    }
}

- (void)downLoadWorklistResult:(Boolean)rResult failItem:(WJCHiWorklistItem *)rItem failString:(NSString *)rStr{
    [self performSelectorOnMainThread:@selector(endWorklistOperate) withObject:nil waitUntilDone:YES];
    if (rResult) {
        [self popDialogWithTittle:@"提示" message:@"下载参数完成"];
    } else {
        if (rItem == nil) {
            [self popDialogWithTittle:@"提示" message:rStr];
        } else {
            
            [self popDialogWithTittle:@"提示" message:[NSString stringWithFormat:@"%@参数下载失败",rItem.sName]];
        }
    }
}
- (void)downloadWorklistParaFailItem:(WJCHiWorklistItem*)rItem failString:(NSString *)rStr{
    
    [self performSelectorOnMainThread:@selector(endWorklistOperate) withObject:nil waitUntilDone:YES];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"%@参数下载失败",rItem.sName] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *retryAlert = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){

        _nowWorklist.downloadFailStep = WJCWorklistDownloadFailStepRetry;
        [self performSelectorOnMainThread:@selector(startWorklistOperateType1) withObject:nil waitUntilDone:YES];

    }];
    UIAlertAction *ignoreAlert = [UIAlertAction actionWithTitle:@"忽略" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        _nowWorklist.downloadFailStep = WJCWorklistDownloadFailStepIgnore;
        [self performSelectorOnMainThread:@selector(startWorklistOperateType1) withObject:nil waitUntilDone:YES];
    }];
    UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"结束下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        _nowWorklist.downloadFailStep = WJCWorklistDownloadFailStepCancel;
        [self performSelectorOnMainThread:@selector(startWorklistOperateType2) withObject:nil waitUntilDone:YES];
        
    }];
    [alert addAction:retryAlert];
    [alert addAction:ignoreAlert];
    [alert addAction:cancelAlert];
    dispatch_async(dispatch_get_main_queue(), ^{
       // UI更新代码
       [self presentViewController:alert animated:YES completion:nil];
    });
    
    
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    return _nowWorklist.item.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WJCWorklistViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WorklistCell"];
    if (cell == nil) {
        cell = [WJCWorklistViewCell worklistViewCellWithTableView:tableView];
        
        
    }
    [cell loadWorklistItem:_nowWorklist.item[indexPath.row] withDesc:_nowDevice.descDealer];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //cell分隔线
    [cell setSeparatorInset:UIEdgeInsetsZero];
    //    [cell setSeparatorInset:UIEdgeInsetsZero];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WJCHiWorklistItem *tempPara = _nowWorklist.item[indexPath.row];//hiDevice.paras.paras[hiDevice.paras.actualGroup[self->nowGroup].visibleItems[indexPath.row]->index];
    //    NSString *paraName = hiDevice.paras.actualGroup[self->nowGroup].visibleItems[indexPath.row]->abbreviativeName;
    
    if ((tempPara.nowPara.isArray) && (tempPara.nowPara.isDataSet)) {
        WJCWorklistDataSetController *tempDataSetWorklist = [[WJCWorklistDataSetController alloc] initWithWorklistItem:tempPara withHiDevice:_nowDevice];
        [self.navigationController pushViewController:tempDataSetWorklist animated:YES];
        
    } else if ((!tempPara.nowPara.isArray) && (tempPara.nowPara.isDataSet)) {
        
        WJCWorklistDataSetController *tempDataSetWorklist = [[WJCWorklistDataSetController alloc] initWithWorklistItem:tempPara withHiDevice:_nowDevice];
        [self.navigationController pushViewController:tempDataSetWorklist animated:YES];
        
        
    } else if ((tempPara.nowPara.isArray) && (!tempPara.nowPara.isDataSet)) {
        
        WJCArrayParaTable *tempT = [[WJCArrayParaTable alloc] initWithWorklistItem:tempPara withHiDevice:_nowDevice withParaName:tempPara.sName withSubindex:0];
        [self.navigationController pushViewController:tempT animated:YES];
        
    } else if ((!tempPara.nowPara.isArray) && (!tempPara.nowPara.isDataSet)) {
        
        WJCWorkllistParaEditor *tempWorklist = [[WJCWorkllistParaEditor alloc] initWithWorklistItem:tempPara withHiDevice:_nowDevice withSubindex:0 withArrayIndex:0];
        [self.navigationController pushViewController:tempWorklist animated:YES];
        
        
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
