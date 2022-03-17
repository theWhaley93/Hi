//
//  WJCCfgFilesItem.m
//  Hi
//
//  Created by apple on 2018/3/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCCfgFilesItem.h"

@interface WJCCfgFilesItem(){
    WJCCfgFileModel *cfgFile;
}

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *localImage;
@property (weak, nonatomic) IBOutlet UIImageView *cloudImage;
@property (weak, nonatomic) IBOutlet UIImageView *fileImage;
@property (weak, nonatomic) IBOutlet UILabel *dspVersionLabel;

@end

@implementation WJCCfgFilesItem

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)loadWithCfgFileModel:(WJCCfgFileModel *)rCfgModel{
    cfgFile = rCfgModel;
    self.fileNameLabel.text = cfgFile.fileName;
    self.dspVersionLabel.text = cfgFile.DSPVersion;
    
//    self.fileImage.image = [UIImage imageNamed:@"if_document"];
    self.fileImage.image = [UIImage imageNamed:@"if_hand_cfgfile"];
    
    if (cfgFile->localExist) {
        self.localImage.image = [UIImage imageNamed:@"green1"];
    } else {
        self.localImage.image = [UIImage imageNamed:@"gray1"];
    }
    
    if (cfgFile->cloudExist) {
        self.cloudImage.image = [UIImage imageNamed:@"green1"];
    } else {
        self.cloudImage.image = [UIImage imageNamed:@"gray1"];
    }
    
}

+ (instancetype)cfgFilesItemWithTableView:(UITableView *)rTableView{

    static NSString *identifier = @"onePara";
    WJCCfgFilesItem *cell = [rTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WJCCfgFilesItem" owner:nil options:nil] firstObject];
    }
    return cell;
    
}

@end
