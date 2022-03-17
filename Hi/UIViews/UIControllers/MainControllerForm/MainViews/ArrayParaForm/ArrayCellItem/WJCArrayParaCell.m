//
//  WJCArrayParaCell.m
//  Hi
//
//  Created by apple on 2018/4/3.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCArrayParaCell.h"


@interface WJCArrayParaCell(){
    WJCOneParameter *nowPara;  //当前参数
    WJCDescDealer *descDealer;  //参数描述
    NSInteger row;
    int paraSubindex;
    id<WJCArrayParaClickDelegate> theDelegate;
    
    WJCHiWorklistItem *nowWorklistItem;
}
@property (strong, nonatomic) IBOutlet UIButton *btn1;
@property (strong, nonatomic) IBOutlet UIButton *btn2;
@property (strong, nonatomic) IBOutlet UIButton *btn3;
@property (strong, nonatomic) IBOutlet UIButton *btn4;
@property (strong, nonatomic) IBOutlet UIButton *btn5;

@property (nonatomic,strong)  NSMutableArray<UIButton *> *btnArray;    //
@end

@implementation WJCArrayParaCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (instancetype)arrayParaWithTableView:(UITableView *)tableView{
    static NSString *identifier = @"onePara";
    WJCArrayParaCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WJCArrayParaCell" owner:nil options:nil] firstObject];
    }
    return cell;
}

- (void)loadCellInfoWithPara:(WJCOneParameter *) rPara withRow:(NSInteger)rRow withSubindex:(int)rSub withDesc:(WJCDescDealer*) desc withDelegate:(id)rDelegate{
    
    row = rRow;
    nowPara = rPara;
    descDealer = desc;
    paraSubindex = rSub;
    theDelegate = rDelegate;
    
    _btnArray = [[NSMutableArray alloc] initWithCapacity:5];
    [_btnArray addObject:_btn1];
    [_btnArray addObject:_btn2];
    [_btnArray addObject:_btn3];
    [_btnArray addObject:_btn4];
    [_btnArray addObject:_btn5];
    
    if (row == 0) {
        _btnArray[0].hidden = YES;
        for (int i=1; i<nowPara->arrayWidth+1; i++) {
//            _btnArray[i].titleLabel.text = [NSString stringWithFormat:@"列%d",i-1];
            [_btnArray[i] setTitle:[NSString stringWithFormat:@"列%d",i-1] forState:UIControlStateNormal];
            [_btnArray[i].layer setCornerRadius:7.0];
            [_btnArray[i].layer setBorderWidth:1.0];
            _btnArray[i].layer.borderColor = [UIColor grayColor].CGColor;
        }
        int temb = nowPara->arrayWidth;
        for (int i=temb+1; i<5; i++) {
            _btnArray[i].hidden = YES;
        }
//        UIView *view = [[UIView alloc] init];
//        for (int i=0; i<nowPara->arrayWidth; i++) {
//            UIButton *tempB = [[UIButton alloc] initWithFrame:CGRectMake((38+8+8*i), 2, 50, 40)];
//            tempB.titleLabel.text = [NSString stringWithFormat:@"列%d",i];
//
//            [view addSubview:tempB];
//        }
//
//        [self addSubview:view];
        
    } else {
        
        [_btnArray[0] setTitle:[NSString stringWithFormat:@"行%d",row-1] forState:UIControlStateNormal];
        [_btnArray[0].layer setCornerRadius:7.0];
        [_btnArray[0].layer setBorderWidth:1.0];
        _btnArray[0].layer.borderColor = [UIColor grayColor].CGColor;
        
        for (int i=1; i<nowPara->arrayWidth+1; i++) {
            //            _btnArray[i].titleLabel.text = [NSString stringWithFormat:@"列%d",i-1];
            NSInteger arrI = nowPara->arrayWidth * (row - 1) + i - 1;
            [_btnArray[i] setTitle:[nowPara showParaDesc:[nowPara valHexWithSubindex:paraSubindex withArrayIndex:arrI] descD:descDealer] forState:UIControlStateNormal];
            [_btnArray[i] setBackgroundColor:[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0]];
            [_btnArray[i].layer setCornerRadius:7.0];
            [_btnArray[i].layer setBorderWidth:1.0];
            _btnArray[i].layer.borderColor = [UIColor grayColor].CGColor;
        }
        int temb = nowPara->arrayWidth;
        for (int i=temb+1; i<5; i++) {
            _btnArray[i].hidden = YES;
        }
        
//        UIView *view = [[UIView alloc] init];
//
//        UIButton *tempB = [[UIButton alloc] initWithFrame:CGRectMake(8, 2, 50, 40)];
//        tempB.titleLabel.text = [NSString stringWithFormat:@"行%ld",row-1];
//
//        [view addSubview:tempB];
//
//        for (int i=0; i<nowPara->arrayWidth; i++) {
//            UIButton *tempB = [[UIButton alloc] initWithFrame:CGRectMake((38+8+8*i), 2, 50, 40)];
//
//            NSInteger arrI = nowPara->arrayWidth * (row - 1) + i;
//            tempB.titleLabel.text = [nowPara showParaDesc:[nowPara valHexWithSubindex:paraSubindex withArrayIndex:arrI] descD:descDealer];
//
//            [view addSubview:tempB];
//        }
//        [self addSubview:view];
        
    }
}

- (void)loadCellInfoWithWorklistItem:(WJCHiWorklistItem *) rWorklistItem withRow:(NSInteger)rRow withSubindex:(int)rSub withDesc:(WJCDescDealer*) desc withDelegate:(id)rDelegate{
    
    nowWorklistItem = rWorklistItem;
    row = rRow;
    nowPara = rWorklistItem.nowPara;
    descDealer = desc;
    paraSubindex = rSub;
    theDelegate = rDelegate;
    
    
    _btnArray = [[NSMutableArray alloc] initWithCapacity:5];
    [_btnArray addObject:_btn1];
    [_btnArray addObject:_btn2];
    [_btnArray addObject:_btn3];
    [_btnArray addObject:_btn4];
    [_btnArray addObject:_btn5];
    
    if (row == 0) {
        _btnArray[0].hidden = YES;
        for (int i=1; i<nowPara->arrayWidth+1; i++) {
            //            _btnArray[i].titleLabel.text = [NSString stringWithFormat:@"列%d",i-1];
            [_btnArray[i] setTitle:[NSString stringWithFormat:@"列%d",i-1] forState:UIControlStateNormal];
            [_btnArray[i].layer setCornerRadius:7.0];
            [_btnArray[i].layer setBorderWidth:1.0];
            _btnArray[i].layer.borderColor = [UIColor grayColor].CGColor;
        }
        int temb = nowPara->arrayWidth;
        for (int i=temb+1; i<5; i++) {
            _btnArray[i].hidden = YES;
        }

        
    } else {
        
        [_btnArray[0] setTitle:[NSString stringWithFormat:@"行%d",row-1] forState:UIControlStateNormal];
        [_btnArray[0].layer setCornerRadius:7.0];
        [_btnArray[0].layer setBorderWidth:1.0];
        _btnArray[0].layer.borderColor = [UIColor grayColor].CGColor;
        
        for (int i=1; i<nowPara->arrayWidth+1; i++) {
            //            _btnArray[i].titleLabel.text = [NSString stringWithFormat:@"列%d",i-1];
            NSInteger arrI = nowPara->arrayWidth * (row - 1) + i - 1;
            [_btnArray[i] setTitle:[NSString stringWithFormat:@"%@| %@",[nowPara showParaDesc:[nowPara valHexWithSubindex:paraSubindex withArrayIndex:arrI] descD:descDealer], [rWorklistItem offlineStrValWithSubindex:paraSubindex withArrayIndex:arrI]] forState:UIControlStateNormal];
            [_btnArray[i] setBackgroundColor:[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0]];
            [_btnArray[i].layer setCornerRadius:7.0];
            [_btnArray[i].layer setBorderWidth:1.0];
            _btnArray[i].layer.borderColor = [UIColor grayColor].CGColor;
        }
        int temb = nowPara->arrayWidth;
        for (int i=temb+1; i<5; i++) {
            _btnArray[i].hidden = YES;
        }
        
        
    }
}

- (IBAction)btn0:(id)sender {
    
    if (row>0) {
        if ([theDelegate respondsToSelector:@selector(clickWithRow:withIndex:)])
        {
            NSInteger didSection = ((UIButton*)sender).tag;
            NSInteger arrI = nowPara->arrayWidth * (row - 1) + didSection;
            [theDelegate clickWithRow:row withIndex:arrI];
            
        }
    }

}

@end



