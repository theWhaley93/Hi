//
//  WJCWorklistViewCell.m
//  Hi
//
//  Created by apple on 2018/5/2.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCWorklistViewCell.h"


@interface WJCWorklistViewCell()

@property (nonatomic,strong)  WJCHiWorklistItem *nowParaItem;  //当前的worklist item
@property (weak, nonatomic) IBOutlet UIImageView *imageW;
@property (nonatomic,strong)  WJCDescDealer *descDealer;  //

@property (weak, nonatomic) IBOutlet UILabel *valLabel;
@property (weak, nonatomic) IBOutlet UILabel *offlineValLabel;
@property (weak, nonatomic) IBOutlet UILabel *snameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;

@end

@implementation WJCWorklistViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)worklistViewCellWithTableView:(UITableView *)tableView{
    
    static NSString *identifier = @"worklistItem";
    WJCWorklistViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WJCWorklistViewCell" owner:nil options:nil] firstObject];
        
    }
    return cell;
}

- (void)loadWorklistItem:(WJCHiWorklistItem*)rWorklistItem withDesc:(WJCDescDealer*) rDesc{
    _nowParaItem = rWorklistItem;
    _descDealer = rDesc;

    if (!_nowParaItem.nowPara.isReadonly) {
//        self.imageW.image = [UIImage imageNamed:@"if_gear"];
        self.imageW.image = [UIImage imageNamed:@"if_hand_writable"];
    } else
        self.imageW.image = [UIImage imageNamed:@"if_hand_readonly"];
//        self.imageW.image = [UIImage imageNamed:@"if_caution"];
    

    if (_nowParaItem.nowPara.isArray) {
        self.valLabel.text = @"矩阵参数,请点击查看";
        self.offlineValLabel.text = @"矩阵参数,请点击查看";
    } else {

        self.valLabel.text = [_nowParaItem.nowPara showParaDesc:[_nowParaItem.nowPara valHexWithSubindex:0 withArrayIndex:0] descD:self.descDealer];
        self.offlineValLabel.text = [_nowParaItem offlineStrValWithSubindex:0 withArrayIndex:0];
//        if ([[_nowParaItem offlineStrValWithSubindex:0 withArrayIndex:0] isEqualToString:hexToDisp(<#NSString *valStr#>, _nowParaItem.nowPara)]) {
//            <#statements#>
//        }
        if ((![[_nowParaItem offlineStrValWithSubindex:0 withArrayIndex:0] isEqualToString:hexToDisp([_nowParaItem.nowPara valHexWithSubindex:0 withArrayIndex:0], _nowParaItem.nowPara)]) && (![dispToHex([_nowParaItem offlineStrValWithSubindex:0 withArrayIndex:0], _nowParaItem.nowPara) isEqualToString:[_nowParaItem.nowPara valHexWithSubindex:0 withArrayIndex:0]])) {
            NSString *str1 = [_nowParaItem offlineStrValWithSubindex:0 withArrayIndex:0];
            NSString *str2 = hexToDisp([_nowParaItem.nowPara valHexWithSubindex:0 withArrayIndex:0], _nowParaItem.nowPara);
            self.backgroundColor = [UIColor yellowColor];
        } else {
            self.backgroundColor = [UIColor whiteColor];
        }
    }
    self.snameLabel.text = _nowParaItem.sName;
    self.lnameLabel.text = _nowParaItem.nowPara.lDescribe;
    self.indexLabel.text = [NSString stringWithFormat:@"(%d)",_nowParaItem.index];

}


@end
