//
//  WJCRemoteViewController.m
//  Hi
//
//  Created by apple on 2018/5/31.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCRemoteViewController.h"
#import "WJCGlobalConstants.h"
#import "WJCCommonFunctions.h"


@interface WJCRemoteViewController ()<WJCRemoteDelegate>{
    NSThread *remoteMainLoop;
    NSInteger remoteMode;
    NSInteger readGroupIndex;
    NSInteger tempGroupIndex;
    Boolean changeGroup;
    
    //是否开启record模式
    Boolean recordMode;
    
    //心跳定时器
    NSTimer *recordHeartBeatTimer;
    
    //手动断开连接
    Boolean isManualDisconnect;
    
    //连接用户信息
    NSString *clientName;
    NSString *pinCode;
    
    //界面刷新定时器
    NSTimer *refreshUiTimer;
    
    //界面状态
    Boolean isMatched;
    NSInteger sendDataSize;
    NSInteger paraSendTimes;
    NSInteger recordSendTimes;
    NSInteger worklistReadTimes;
    NSInteger worklistReadSuccTimes;
    
    
}
@property (weak, nonatomic) IBOutlet UITextField *userNameText;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UITextView *remteLogText;
@property (weak, nonatomic) IBOutlet UITextField *pinText;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *connectLed;
@property (weak, nonatomic) IBOutlet UIImageView *remoteLed;
@property (weak, nonatomic) IBOutlet UILabel *sendDataLabel1;
@property (weak, nonatomic) IBOutlet UILabel *sendDataLabel2;
//@property (weak, nonatomic) IBOutlet UILabel *tcpLabel;
@property (weak, nonatomic) IBOutlet UIImageView *wifiConnected;

@end

@implementation WJCRemoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor =[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
//    self.remteLogText.editable = NO;
//    self.remteLogText.layer.borderColor = [[UIColor blackColor] CGColor];
//    self.remteLogText.layer.borderWidth = 2.0;
    self.remteLogText.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    self.title = @"远程控制";
//    self.navigationController.title = @"远程控制";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(exitUi)];
    
    //生成随机pin码
    NSString *randomPin = [NSString stringWithFormat:@"%d%d%d%d",(arc4random() % 9),(arc4random() % 9),(arc4random() % 9),(arc4random() % 9)];
    self.pinText.text = randomPin;
    
//    if(@available(iOS 11.0,*)){
//       self.automaticallyAdjustsScrollViewInsets = YES;
//    } else {
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }

    
    
    //读取存入的数组 打印
    
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"mutableArr"];
    if (arr == nil) {
        self.userNameText.text = @"HiDevice";//[NSString stringWithFormat:@"HiDevice%d-%@",((arc4random() % 100) +1),randomPin];
    } else {
//        NSLog(@"%@",arr);
        NSString *savedUserName = arr[0];
        if ([savedUserName isEqualToString:@""]) {
            self.userNameText.text = @"HiDevice";
        } else {
            self.userNameText.text = savedUserName;
        }
    }

    
    [self.userNameText addTarget:self action:@selector(userNameTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    
    //error长按动作
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(connectImageLongP:)];
    longPress.minimumPressDuration = 0.8;
    [_wifiConnected addGestureRecognizer:longPress];
    [_wifiConnected setUserInteractionEnabled:YES];

}
//监听textfield输入动作
- (void)userNameTextDidChange: (UITextField *)rTextField{
    NSMutableArray *mutArr = [[NSMutableArray alloc]initWithObjects:rTextField.text, nil];
    
    //存入数组并同步
    
    [[NSUserDefaults standardUserDefaults] setObject:mutArr forKey:@"mutableArr"];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    isMatched = NO;
    refreshUiTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(refreshUiAction) userInfo:nil repeats:YES];
    [refreshUiTimer setFireDate:[NSDate distantPast]];
}
- (void)viewDidDisappear:(BOOL)animated{
    [refreshUiTimer setFireDate:[NSDate distantFuture]];
    [refreshUiTimer invalidate];
    refreshUiTimer = nil;
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
-(void)connectImageLongP:(UILongPressGestureRecognizer*)gestureRecognizer{
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
#pragma mark - 初始化
- (instancetype)initWithHiDevice:(WJCDevice *)rDevice{
    if (self = [super init]) {
        _nowDevice = rDevice;
        
        _nowRemoteController = [[WJCRemoteClass alloc] initWithDelegate:self];
        
        remoteMode = 0;
        readGroupIndex = 0;
        tempGroupIndex = 0;
        recordMode = NO;
        changeGroup = NO;
        isManualDisconnect = NO;
        
        paraSendTimes = 0;
        recordSendTimes = 0;
        worklistReadSuccTimes = 0;
        worklistReadTimes = 0;
        
    }
    return self;
}

#pragma mark - 连接断开动作
- (IBAction)connectBtn:(id)sender {
    Boolean isConnect = _nowRemoteController.remoteConnected;
    clientName = [NSString stringWithFormat:@"%@-%@",self.userNameText.text,self.pinText.text];//self.userNameText.text;
    pinCode = self.pinText.text;
    if (isConnect) {
        isManualDisconnect = YES;
        [self disconnectRemote];
    } else {
        isMatched = NO;
        [self connectRemoteWithClientName:clientName withIsPositive:NO withIsReconnect:NO withClientVer:@"1.00" withPinCode:pinCode withHeartBeatSec:20];
    }
    
}

- (IBAction)diconnectBtn:(id)sender {
    [_nowRemoteController diconnect];
    [remoteMainLoop cancel];
    [self disenableTimer];
    [self addLogWithString:@"断开连接"];
    [self connectFailInit];
}


#pragma mark - 界面相关动作
/**弹出提示框
 */
- (void)popDialogWithTittle:(NSString *)rTittle message:(NSString *)rMessage{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:rTittle message:rMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
    }];
    [alert addAction:okAlert];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)refreshUiAction{
    NSArray *remoteModeName = @[@"   ",@"参数组刷新",@"worklist刷新",@"曲线采集"];

    if (_nowDevice.hiCom.clientSocket.isConnected) {
        _wifiConnected.image = [UIImage imageNamed:@"green1"];
    }else {
        _wifiConnected.image = [UIImage imageNamed:@"gray1"];

    }
    _modeLabel.text = remoteModeName[remoteMode];
    if (_nowRemoteController.remoteConnected) {
        _connectLed.image = [UIImage imageNamed:@"green1"];//green1gray1
        if (isMatched) {
            _remoteLed.image = [UIImage imageNamed:@"green1"];
        } else {
            _remoteLed.image = [UIImage imageNamed:@"gray1"];
        }
    } else {
        _connectLed.image = [UIImage imageNamed:@"gray1"];//green1gray1
        _remoteLed.image = [UIImage imageNamed:@"gray1"];
    }
    
    switch (remoteMode) {
        case 0:
            _sendDataLabel1.text = @"0";
            _sendDataLabel2.text = @"0";
            break;
            
        case 1:
            _sendDataLabel1.text = [NSString stringWithFormat:@"%ld",paraSendTimes];
            _sendDataLabel2.text = [NSString stringWithFormat:@"%ld",sendDataSize];
            break;
        case 2:
            _sendDataLabel1.text = [NSString stringWithFormat:@"%ld",worklistReadTimes];
            _sendDataLabel2.text = [NSString stringWithFormat:@"%ld",worklistReadSuccTimes];
            
            break;
        case 3:
            _sendDataLabel1.text = [NSString stringWithFormat:@"%ld",recordSendTimes];
            _sendDataLabel2.text = [NSString stringWithFormat:@"%ld",sendDataSize];
            break;
    }
    
}

- (void)connectRemoteWithClientName:(NSString *)rClientName withIsPositive:(Boolean)rIsPositive withIsReconnect:(Boolean)rIsReconnect withClientVer:(NSString *)rClientVer withPinCode:(NSString *)rPinCode withHeartBeatSec:(NSInteger)rHeartBeatSec{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSInteger a = [_nowRemoteController registerToServerWithClientName:rClientName withIsPositive:rIsPositive withIsReconnect:rIsReconnect withClientVer:rClientVer withPinCode:rPinCode withHeartBeatSec:rHeartBeatSec];
        
        switch (a) {
            case -1:{
                [self performSelectorOnMainThread:@selector(connectFailInit) withObject:nil waitUntilDone:NO];
                [self addLogWithString:[NSString stringWithFormat:@"连接失败,服务器内部错误(错误代码:%ld)",a]];
                break;
            }
            case -2:{
                [self performSelectorOnMainThread:@selector(connectFailInit) withObject:nil waitUntilDone:NO];
                [self addLogWithString:[NSString stringWithFormat:@"连接失败，注册无返回，请检查网络(错误代码:%ld)",a]];
                break;
            }
            case -3:{
                [self performSelectorOnMainThread:@selector(connectFailInit) withObject:nil waitUntilDone:NO];
                [self addLogWithString:[NSString stringWithFormat:@"连接失败，连接服务器失败(错误代码:%ld)",a]];
                break;
            }
            case 2:{
                [self performSelectorOnMainThread:@selector(connectFailInit) withObject:nil waitUntilDone:NO];
                [self addLogWithString:[NSString stringWithFormat:@"连接失败，用户名重复(错误代码:%ld)",a]];
                break;
            }
            case 5:{
                [self performSelectorOnMainThread:@selector(connectFailInit) withObject:nil waitUntilDone:NO];
                [self addLogWithString:[NSString stringWithFormat:@"连接失败，版本禁止(错误代码:%ld)",a]];
                break;
            }
            case 1:{
                [self performSelectorOnMainThread:@selector(connectSuccessInit) withObject:nil waitUntilDone:NO];
                [self addLogWithString:@"连接成功"];
                break;
            }
            case 3:{
                [self performSelectorOnMainThread:@selector(connectSuccessInit) withObject:nil waitUntilDone:NO];
                [self addLogWithString:@"重连成功"];
                break;
            }
            case 4:{
                [self performSelectorOnMainThread:@selector(connectSuccessInit) withObject:nil waitUntilDone:NO];
                [self addLogWithString:@"重连转首次连接成功"];
                break;
            }
        }
        
    });
}


- (void)connectRemoteWithIsReconnect:(Boolean)rIsReconnect{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSInteger a = [_nowRemoteController registerToServerWithClientName:@"NewIphoneTest" withIsPositive:NO withIsReconnect:rIsReconnect withClientVer:@"1.00" withPinCode:@"1234" withHeartBeatSec:30];
        
        switch (a) {
            case -1:{
                [self performSelectorOnMainThread:@selector(connectFailInit) withObject:nil waitUntilDone:NO];
                [self addLogWithString:[NSString stringWithFormat:@"连接失败,服务器内部错误(错误代码:%ld)",a]];
                break;
            }
            case -2:{
                [self performSelectorOnMainThread:@selector(connectFailInit) withObject:nil waitUntilDone:NO];
                [self addLogWithString:[NSString stringWithFormat:@"连接失败，注册无返回，请检查网络(错误代码:%ld)",a]];
                break;
            }
            case -3:{
                [self performSelectorOnMainThread:@selector(connectFailInit) withObject:nil waitUntilDone:NO];
                [self addLogWithString:[NSString stringWithFormat:@"连接失败，连接服务器失败(错误代码:%ld)",a]];
                break;
            }
            case 2:{
                [self performSelectorOnMainThread:@selector(connectFailInit) withObject:nil waitUntilDone:NO];
                [self addLogWithString:[NSString stringWithFormat:@"连接失败，用户名重复(错误代码:%ld)",a]];
                break;
            }
            case 5:{
                [self performSelectorOnMainThread:@selector(connectFailInit) withObject:nil waitUntilDone:NO];
                [self addLogWithString:[NSString stringWithFormat:@"连接失败，版本禁止(错误代码:%ld)",a]];
                break;
            }
            case 1:{
                [self performSelectorOnMainThread:@selector(connectSuccessInit) withObject:nil waitUntilDone:NO];
                [self addLogWithString:@"连接成功"];
                break;
            }
            case 3:{
                [self performSelectorOnMainThread:@selector(connectSuccessInit) withObject:nil waitUntilDone:NO];
                [self addLogWithString:@"重连成功"];
                break;
            }
            case 4:{
                [self performSelectorOnMainThread:@selector(connectSuccessInit) withObject:nil waitUntilDone:NO];
                [self addLogWithString:@"重连转首次连接成功"];
                break;
            }
        }
        
    });
}
- (void)disconnectRemote{
    [_nowRemoteController diconnect];
    [remoteMainLoop cancel];
    [self disenableTimer];
    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
//
//    NSString *nowDateStr = [formatter stringFromDate:[NSDate date]];
//    NSString *logStr = [NSString stringWithFormat:@"%@ %@",nowDateStr,@"断开连接"];
//    self.remteLogText.text = [NSString stringWithFormat:@"%@\n%@",logStr,self.remteLogText.text];
    [self addLogWithString:@"断开连接"];
    [self connectFailInit];
}

//log显示
- (void)addLogWithString:(NSString *)rContextStr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSString *nowDateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logStr = [NSString stringWithFormat:@"%@  %@",nowDateStr,rContextStr];
//    self.remteLogText.text = [NSString stringWithFormat:@"%@\n%@",logStr,self.remteLogText.text];
    [self performSelectorOnMainThread:@selector(addRemoteLogTextWithString:) withObject:logStr waitUntilDone:NO];
}
- (void)addRemoteLogTextWithString:(NSString *)rStr{
    self.remteLogText.text = [NSString stringWithFormat:@"%@\n%@",rStr,self.remteLogText.text];//[NSString stringWithFormat:@"%@\n%@",logStr,self.remteLogText.text];
}

//退出本页
- (void)exitUi{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定退出远程?" preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert];
    
    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [_nowRemoteController diconnect];
        [remoteMainLoop cancel];
        [self disenableTimer];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2] animated:YES];
        
    }];
    [alert addAction:okAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }]];
    
    
    [self presentViewController:alert animated:YES completion:nil];
//    [_nowRemoteController diconnect];
//    [remoteMainLoop cancel];
//    [self disenableTimer];
//    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2] animated:YES];
}
//首次连接初始化成功
- (void)connectSuccessInit{
    remoteMode = 0;
    readGroupIndex = 0;
    tempGroupIndex = 0;
    recordMode = NO;
    changeGroup = NO;
    [self.connectBtn setBackgroundImage:[UIImage imageNamed:@"if_Power_Off"] forState:UIControlStateNormal];
}
//首次连接初始化失败
- (void)connectFailInit{
    [self.connectBtn setBackgroundImage:[UIImage imageNamed:@"if_Power_On"] forState:UIControlStateNormal];
}
#pragma mark - 打包上传内容
//打包某个参数
- (NSData *)packOneParaWithParaIndex:(int)rIndex withParaReadHex:(NSString *)rReadHex{
    
    NSMutableData *tempOneData = [[NSMutableData alloc] init];
    
//    int indexD =tpGroup.visibleItems[i]->index;
    Byte indexByte[8];
    for (int j=0; j<4; j++) {
        indexByte[j] = ((Byte *)&rIndex)[j];
    }
    for (int j=4; j<8; j++) {
        indexByte[j] = 0;
    }
    NSData *startData = [[NSData alloc] initWithBytes:indexByte length:8];
    
    //readhex
//    NSString *contentStr = hiDevice.paras.paras[tpGroup.visibleItems[i]->index].usedReadHex;
    //打包内容
    NSData *contentData = [rReadHex dataUsingEncoding:NSUTF8StringEncoding];
    
    int tempLen = contentData.length;
    Byte lenbyte[4];
    for (int j=0; j<4; j++) {
        lenbyte[j] = ((Byte *)&tempLen)[j];
    }
    //打包长度
    NSData *lenData = [[NSData alloc] initWithBytes:lenbyte length:4];
    
    [tempOneData appendData:startData];
    [tempOneData appendData:lenData];
    [tempOneData appendData:contentData];
    
    return tempOneData;
    
}

//打包某组参数
- (NSData *)packGroupParasWithDevice:(WJCDevice *)rDevice withGroupIndex:(int)rGroupI{
    
    NSMutableData *allData = [[NSMutableData alloc] init];
    WJCOneGroup *tpGroup = _nowDevice.paras.actualGroup[rGroupI];
    
    int tempLen = tpGroup.visibleItems.count + 7;   //组的参数 + 标幺值 + 驱动器状态值
    Byte lenbyte[4];
    for (int j=0; j<4; j++) {
        lenbyte[j] = ((Byte *)&tempLen)[j];
    }
    [allData appendBytes:lenbyte length:4];
    
    //添加组信息
    for (int i = 0; i<tpGroup.visibleItems.count; i++)
    {
        NSData *onePara = [self packOneParaWithParaIndex:tpGroup.visibleItems[i]->index withParaReadHex:hiDevice.paras.paras[tpGroup.visibleItems[i]->index].usedReadHex];
        [allData appendData:onePara];
    }
    //添加标幺值
    NSData *maxSpeedData = [self packOneParaWithParaIndex:_nowDevice.perUnitValues->maxSpeed.index withParaReadHex:_nowDevice.perUnitValues->maxSpeed.usedReadHex];
    [allData appendData:maxSpeedData];
    
    NSData *maxCurrentData = [self packOneParaWithParaIndex:_nowDevice.perUnitValues->maxCurrent.index withParaReadHex:_nowDevice.perUnitValues->maxCurrent.usedReadHex];
    [allData appendData:maxCurrentData];
    
    NSData *ratedVoltageData = [self packOneParaWithParaIndex:_nowDevice.perUnitValues->ratedVoltage.index withParaReadHex:_nowDevice.perUnitValues->ratedVoltage.usedReadHex];
    [allData appendData:ratedVoltageData];
    
    //添加状态
    NSData *driverStatusData = [self packOneParaWithParaIndex:_nowDevice.driverState->driverStatus.index withParaReadHex:_nowDevice.driverState->driverStatus.usedReadHex];
    [allData appendData:driverStatusData];

    NSData *driverErrorData = [self packOneParaWithParaIndex:_nowDevice.driverState->driverError.index withParaReadHex:_nowDevice.driverState->driverError.usedReadHex];
    [allData appendData:driverErrorData];
    
    NSData *driverWarningData = [self packOneParaWithParaIndex:_nowDevice.driverState->driverWarning.index withParaReadHex:_nowDevice.driverState->driverWarning.usedReadHex];
    [allData appendData:driverWarningData];
    
    NSData *softwareEnabledData = [self packOneParaWithParaIndex:_nowDevice.driverState->softwareEnabled.index withParaReadHex:_nowDevice.driverState->softwareEnabled.usedReadHex];
    [allData appendData:softwareEnabledData];
    
    return allData;
}
#pragma mark - 定时器发送record心跳
- (void)heartBeatAction{

    [_nowDevice.hiCom recordHeartBeat];

}

- (void)enableTimer{
    recordHeartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(heartBeatAction) userInfo:nil repeats:YES];
    [recordHeartBeatTimer setFireDate:[NSDate distantPast]];
}
- (void)disenableTimer{
    [recordHeartBeatTimer setFireDate:[NSDate distantFuture]];
    [recordHeartBeatTimer invalidate];
    recordHeartBeatTimer = nil;
}
#pragma mark - remote main loop 线程
- (void)remoteMainLoopAction{
    while (1) {
        
        switch (remoteMode) {
            case 0://无模式
                
                break;
                
            case 1:{//参数刷新
                
                WJCOneGroup *tpGroup = _nowDevice.paras.actualGroup[tempGroupIndex];
                NSDate *startTim = [NSDate date];
                
                //刷新驱动器状态和标幺值
                [_nowDevice.perUnitValues uploadPerUnitValues:_nowDevice.hiCom];
                [_nowDevice.driverState uploadDriverStateWithHiCom:_nowDevice.hiCom withDescDealer:_nowDevice.descDealer];
                //刷新组参数
                for (int i = 0; i<tpGroup.visibleItems.count; i++)
                {
                    WJCOneParameter *nowOnePara = hiDevice.paras.paras[tpGroup.visibleItems[i]->index];
                    [hiDevice.hiCom readWithPara:nowOnePara isArrayEnable:YES];
//                    [NSThread sleepForTimeInterval:0.001f];
                    if ([[NSThread currentThread] isCancelled]) {
                        [NSThread exit];
                    }
                }
                NSDate *end1Tim = [NSDate date];
                NSLog(@"read loop time: %f",[end1Tim timeIntervalSinceDate:startTim]);
                /*
                NSMutableData *allData = [[NSMutableData alloc] init];
                int tempLen = tpGroup.visibleItems.count;
                Byte lenbyte[4];
                for (int j=0; j<4; j++) {
                    lenbyte[j] = ((Byte *)&tempLen)[j];
                }
                [allData appendBytes:lenbyte length:4];
                
                for (int i = 0; i<tpGroup.visibleItems.count; i++)
                {
                    NSMutableData *tempOneData = [[NSMutableData alloc] init];
                    
                    int indexD =tpGroup.visibleItems[i]->index;
                    Byte indexByte[8];
                    for (int j=0; j<4; j++) {
                        indexByte[j] = ((Byte *)&indexD)[j];
                    }
                    for (int j=4; j<8; j++) {
                        indexByte[j] = 0;
                    }
                    NSData *startData = [[NSData alloc] initWithBytes:indexByte length:8];
                    
                    //readhex
                    NSString *contentStr = hiDevice.paras.paras[tpGroup.visibleItems[i]->index].usedReadHex;
                    //打包内容
                    NSData *contentData = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
                    
                    int tempLen = contentData.length;
                    Byte lenbyte[4];
                    for (int j=0; j<4; j++) {
                        lenbyte[j] = ((Byte *)&tempLen)[j];
                    }
                    //打包长度
                    NSData *lenData = [[NSData alloc] initWithBytes:lenbyte length:4];
                    
                    [tempOneData appendData:startData];
                    [tempOneData appendData:lenData];
                    [tempOneData appendData:contentData];
                    [allData appendData:tempOneData];
                }
                 */
                NSData *allData = [self packGroupParasWithDevice:_nowDevice withGroupIndex:tempGroupIndex];
                NSData *sendDatas = [_nowRemoteController packSendBytes:0x08 withCmd2:0x01 withContentData:allData];
                if (_nowRemoteController.remoteConnected) {
                    [_nowRemoteController.tcpClient writeData:sendDatas withTimeout:-1 tag:1];
                    sendDataSize = sendDatas.length;
                    paraSendTimes += 1;
                }

                if (changeGroup) {
                    tempGroupIndex = readGroupIndex;
                    changeGroup = NO;
                }
                [NSThread sleepForTimeInterval:0.02f];
                break;}
            case 2://无worklist
                
                break;
            case 3:{//record
                if (recordMode) {
                    NSData *sendRecord = [_nowDevice.hiCom readRemoteRecordChannelDatas];
                    if (sendRecord != nil) {
                        NSData *sendDatas = [_nowRemoteController packSendBytes:0x08 withCmd2:0x02 withContentData:sendRecord];
                        if (_nowRemoteController.remoteConnected) {
                        [_nowRemoteController.tcpClient writeData:sendDatas withTimeout:-1 tag:1];
                            sendDataSize = sendDatas.length;
                            recordSendTimes += 1;
                        }
                    }
                }
                break;
            }
        }
        
        if ([[NSThread currentThread] isCancelled]) {
            [NSThread exit];
        }
        [NSThread sleepForTimeInterval:0.001f];
    }
}
#pragma mark - remote Delegate
//匹配断掉线
- (void)remoteNoticeWhenOppsiteDisconnect{
    //    [self popDialogWithTittle:@"提示" message:@"匹配端掉线"];
    isMatched = NO;
    NSLog(@"匹配端掉线");
    [self addLogWithString:@"匹配段掉线"];
}
//重新被匹配
- (void)remoteNoticeWhenRematchedWithOppsiteName:(NSString *)rOppsiteName{
    //    [self popDialogWithTittle:@"提示" message:[NSString stringWithFormat:@"被%@重匹配",rOppsiteName]];
    NSLog(@"被%@重匹配",rOppsiteName);
    isMatched = YES;
    [self addLogWithString:[NSString stringWithFormat:@"被%@重匹配",rOppsiteName]];
}
//被断开匹配
- (void)remoteNoticeWhenDismatched{
    //    [self popDialogWithTittle:@"提示" message:@"被断开匹配"];
    NSLog(@"被断开匹配");
    isMatched = NO;
    [remoteMainLoop cancel];
    [self addLogWithString:@"被断开匹配"];
}
//被匹配
- (void)remoteNoticeWhenMatchedWithOppsiteName:(NSString *)rOppsiteName{
    
    //    [self popDialogWithTittle:@"提示" message:[NSString stringWithFormat:@"被%@匹配",rOppsiteName]];
    NSLog(@"被%@匹配",rOppsiteName);
    isMatched = YES;
    [self addLogWithString:[NSString stringWithFormat:@"被%@匹配",rOppsiteName]];
    paraSendTimes = 0;
    recordSendTimes = 0;
    worklistReadSuccTimes = 0;
    worklistReadTimes = 0;
    
    remoteMode = 0;
    readGroupIndex = 0;
    changeGroup = YES;
    remoteMainLoop = [[NSThread alloc] initWithTarget:self selector:@selector(remoteMainLoopAction) object:nil];
    [remoteMainLoop start];
}

- (void)remoteNotNeedAnswerDirectWrite:(int)rIndex withSubindex:(int)rSubindex withArrayIndex:(int)rArrInd withValue:(NSString *)rVal withCycleByte:(Byte)rCycleByte{
    NSLog(@"direct write para -index:%d subindex:%d arrayIndex:%d value:%@",rIndex,rSubindex,rArrInd,rVal);
    [self addLogWithString:[NSString stringWithFormat:@"给索引为%d 子索引为%d的参数写入%@",rIndex,rSubindex,rVal]];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        WJCOneParameter *tempPara = [_nowDevice.paras getOneParaWithIndex:rIndex];
        [_nowDevice.hiCom writeDirWithIndex:rIndex withSubindex:rSubindex withData:rVal withDataLen:tempPara.len];
//        recString = [_nowDevice.hiCom writeWithPara:tempPara withindex:rIndex withSubindex:rSubindex withArrayIndex:rArrInd withValue:rVal];
        
    });
}

//切换读取组
- (void)remoteNeedReturnChangeGroupWithGroupIndex:(int)rGroupIndex withCycleByte:(Byte)rCycleByte{
    NSLog(@"change group--%d",rGroupIndex);
    [self addLogWithString:[NSString stringWithFormat:@"切换组%d",rGroupIndex]];
    readGroupIndex = rGroupIndex;
    changeGroup = YES;
    [_nowRemoteController responseChangeGroupWithIsSuccess:YES withCycleByte:rCycleByte];
}

//读取参数
- (void)remoteNeedReturnReadParaWithIndex:(int)rIndex withSubindex:(int)rSubindex withArrayIndex:(int)rArrInd withCycleByte:(Byte)rCycleByte{
    NSLog(@"read para -index:%d subindex:%d arrayIndex:%d",rIndex,rSubindex,rArrInd);
    if (remoteMode ==2) {
        worklistReadTimes += 1;
    } else {
//        [self addLogWithString:[NSString stringWithFormat:@"读取索引为%d的参数",rIndex]];     
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *recString = COMM_TIMEOUT;
        WJCOneParameter *tempPara = [_nowDevice.paras getOneParaWithIndex:rIndex];
        if (tempPara.isDataSet) {
            if (tempPara.isArray) {
                recString = [_nowDevice.hiCom readWithPara:tempPara withindex:rIndex withSubindex:rSubindex withArrayIndex:rArrInd];
            } else {
                NSString *str1 = [_nowDevice.hiCom readWithPara:tempPara withindex:rIndex withSubindex:0 withArrayIndex:rArrInd];
                NSString *str2 = [_nowDevice.hiCom readWithPara:tempPara withindex:rIndex withSubindex:1 withArrayIndex:rArrInd];
                recString = [NSString stringWithFormat:@"%@|%@",str1,str2];
            }

        } else {
            recString = [_nowDevice.hiCom readWithPara:tempPara withindex:rIndex withSubindex:rSubindex withArrayIndex:rArrInd];
        }


        [_nowRemoteController responseReadParaWithIsSuccess:(!isErr(recString)) withValue:recString withCycleByte:rCycleByte];
        if ((!isErr(recString)) && (remoteMode ==2)) {
            worklistReadSuccTimes += 1;
        }
    });
//    [_testRemote responseReadParaWithIsSuccess:YES withValue:@"0062" withCycleByte:rCycleByte];
}

//写参数
- (void)remoteNeedReturnWriteParaWithIndex:(int)rIndex withSubindex:(int)rSubindex withArrayIndex:(int)rArrInd withValue:(NSString *)rVal withCycleByte:(Byte)rCycleByte{
    NSLog(@"write para -index:%d subindex:%d arrayIndex:%d value:%@",rIndex,rSubindex,rArrInd,rVal);
    [self addLogWithString:[NSString stringWithFormat:@"给索引为%d 子索引为%d的参数写入%@",rIndex,rSubindex,rVal]];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *recString = COMM_TIMEOUT;
        WJCOneParameter *tempPara = [_nowDevice.paras getOneParaWithIndex:rIndex];
        if (rIndex == 34) {
            int ssss;
            ssss = 1;
        }
        recString = [_nowDevice.hiCom writeWithPara:tempPara withindex:rIndex withSubindex:rSubindex withArrayIndex:rArrInd withValue:rVal];
        if (isErr(recString)) {
            [self addLogWithString:recString];
        }
        
        [_nowRemoteController responseWriteParaWithIsSuccess:(!isErr(recString)) withCycleByte:rCycleByte];
    });
//    [_testRemote responseWriteParaWithIsSuccess:YES withCycleByte:rCycleByte];
}
//切换模式
- (void)remoteNeedReturnChangeModeWithModeIndex:(int)rModeIndex withCycleByte:(Byte)rCycleByte{
    NSLog(@"change mode %d",rModeIndex);
    [self addLogWithString:[NSString stringWithFormat:@"切换远程模式为%D",rModeIndex]];
    remoteMode = rModeIndex;
    [_nowRemoteController responseChangeModeWithIsSuccess:YES withCycleByte:rCycleByte];
    //    NSLog(@"read para -index:%d subindex:%d arrayIndex:%d",rIndex,rSubindex,rArrInd);
}
//离线读取
- (void)remoteNeedReturnReadOfflineChannelWithChannelIndex:(int)rChannelIndex withCycleByte:(Byte)rCycleByte{
    //    NSLog(@"read para -index:%d subindex:%d arrayIndex:%d",rIndex,rSubindex,rArrInd);
    NSLog(@"read channel index:%d ",rChannelIndex);
    [self addLogWithString:[NSString stringWithFormat:@"读取通道为%d的离线曲线",rChannelIndex]];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *recString = COMM_TIMEOUT;
        NSData * tempData = [[NSMutableData alloc] init];
        recString = [_nowDevice.hiCom readOfflineChannelWithChannelIndex:rChannelIndex pDataByte:&tempData];
        NSLog(@"%@",recString);
        [_nowRemoteController responseReadOfflineChannelWithChannelData:tempData withCycleByte:rCycleByte];
    });
}
- (void)remoteNeedReturnRecordActionWithCommandByte:(Byte)rCommandByte withCycleByte:(Byte)rCycleByte{
    //    NSLog(@"read para -index:%d subindex:%d arrayIndex:%d",rIndex,rSubindex,rArrInd);
    NSLog(@"record action:%d ",rCommandByte);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *recString = @"";
        if (rCommandByte == 0x00) {
            [self addLogWithString:@"停止采集record曲线"];
            recString = [_nowDevice.hiCom recordModeOff];
            if (notErr(recString)) {
                recordMode = NO;
                [self performSelectorOnMainThread:@selector(disenableTimer) withObject:nil waitUntilDone:YES];
            }
            
        } else if (rCommandByte == 0x01)  {
            [self addLogWithString:@"开始采集record曲线"];
            recString = [_nowDevice.hiCom recordModeOn];
            if (notErr(recString)) {
                recordMode = YES;
                [self performSelectorOnMainThread:@selector(enableTimer) withObject:nil waitUntilDone:YES];
            }
        }
        Byte sendByte = 0x00;
        if (isErr(recString)) {
            sendByte = 0x01;
        }

        NSLog(@"%@",recString);
        [_nowRemoteController responseRecordActionWithIsSuccess:sendByte withCycleByte:rCycleByte];
    });
}
- (void)socketDisconnect{
    [remoteMainLoop cancel];
    [self performSelectorOnMainThread:@selector(disenableTimer) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(connectFailInit) withObject:nil waitUntilDone:NO];
    if (isManualDisconnect) {
        isManualDisconnect = NO;
    } else {
        [self addLogWithString:@"手机端已断开连接"];
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
