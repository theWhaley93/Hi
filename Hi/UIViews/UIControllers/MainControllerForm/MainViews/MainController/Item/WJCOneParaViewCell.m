
//  WJCTableViewCell.m
//  Hi
//
//  Created by apple on 2018/1/26.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCOneParaViewCell.h"
#import "WJCGlobalVariable.h"

@interface WJCOneParaViewCell(){
    NSString * cellName;
}
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageW;
@property (weak, nonatomic) IBOutlet UILabel *valLabel;
@property (weak, nonatomic) IBOutlet UILabel *snameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lnameLabel;

@end

@implementation WJCOneParaViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setOnePara:(WJCOneParameter *)onePara{
    _onePara = onePara;
    if (!onePara.isReadonly) {
//        self.imageW.image = [UIImage imageNamed:@"if_gear"];
        self.imageW.image = [UIImage imageNamed:@"if_hand_writable"];
    } else
        self.imageW.image = [UIImage imageNamed:@"if_hand_readonly"];
//        self.imageW.image = [UIImage imageNamed:@"if_caution"];
    
    //互斥锁
//    @synchronized(globelMutexTest){
//        self.valLabel.text = onePara->readHex;//[onePara valStr:0 arrayIndex:0];//[[onePara valStr:0 arrayIndex:0] stringByAppendingString:[NSString stringWithFormat:@" %@",onePara.symbol]];
//    }
//    self.valLabel.text = onePara->readHex;
    if (onePara.isArray) {
        self.valLabel.text = @"矩阵参数,请点击查看";
    } else
        self.valLabel.text = [onePara showParaDesc:[onePara valHexWithSubindex:0 withArrayIndex:0] descD:self.descDealer];//[onePara showParaDesc:[onePara valStr:0 arrayIndex:0] descD:self.descDealer];//[[onePara valStr:0 arrayIndex:0] stringByAppendingString:[NSString stringWithFormat:@" %@",onePara.symbol]];
    self.snameLabel.text = cellName;
    self.lnameLabel.text = onePara.lDescribe;
    self.indexLabel.text = [NSString stringWithFormat:@"(%d)",onePara.index];
//    WJCBasedType temp = onePara.basedType;
//    NSLog(@"%d%d",onePara.index,temp);
}

+ (instancetype)oneParaViewCellWithTableView:(UITableView *)tableView{
    static NSString *identifier = @"onePara";
    WJCOneParaViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WJCViewCell" owner:nil options:nil] firstObject];
        
    }
    return cell;
}
- (void)loadCellInfoWithPara:(WJCOneParameter *) para withParaName:(NSString*)name withDesc:(WJCDescDealer*) desc{
    cellName = name;
    _descDealer = desc;
    self.onePara = para;
}
@end
