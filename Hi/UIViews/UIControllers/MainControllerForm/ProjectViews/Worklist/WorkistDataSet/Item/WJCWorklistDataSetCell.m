//
//  WJCWorklistDataSetCell.m
//  Hi
//
//  Created by apple on 2018/5/22.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCWorklistDataSetCell.h"
@interface WJCWorklistDataSetCell()
@property (weak, nonatomic) IBOutlet UILabel *onlineValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *settingValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *subindexLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageW;

@property (nonatomic,strong)  WJCHiWorklistItem *nowWorklistItem;  //

@end

@implementation WJCWorklistDataSetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (instancetype)worklistDataSetCellWithTableView:(UITableView*)rTableView{
    static NSString *identifier = @"worklist";
    WJCWorklistDataSetCell *cell = [rTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WJCWorklistDataSetCell" owner:nil options:nil] firstObject];
        
    }
    return cell;
}

- (void)loadWithWorklistItem:(WJCHiWorklistItem*)rWorklistItem withDesc:(WJCDescDealer*) rDesc withSubindex:(uint16_t) rSubi{
    _nowWorklistItem = rWorklistItem;
    if (_nowWorklistItem.nowPara.isArray) {
        _onlineValueLabel.text = @"矩阵参数，请点击查看";
        _settingValueLabel.text = @"矩阵参数，请点击查看";
    } else {
        _onlineValueLabel.text = [_nowWorklistItem.nowPara showParaDesc:[_nowWorklistItem.nowPara valHexWithSubindex:rSubi withArrayIndex:0] descD:rDesc];
        _settingValueLabel.text = [_nowWorklistItem offlineStrValWithSubindex:rSubi withArrayIndex:0];
    }

    _subindexLabel.text = [NSString stringWithFormat:@"%d",rSubi];
    if (!_nowWorklistItem.nowPara.isReadonly) {
        self.imageW.image = [UIImage imageNamed:@"if_gear"];
    } else
        self.imageW.image = [UIImage imageNamed:@"if_caution"];
}
@end
