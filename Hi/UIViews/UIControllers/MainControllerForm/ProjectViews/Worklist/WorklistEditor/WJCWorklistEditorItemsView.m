//
//  WJCWorklistEditorItemsView.m
//  twoTableViews
//
//  Created by apple on 2018/5/17.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCWorklistEditorItemsView.h"


@interface WJCWorklistEditorItemsView ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic, strong)UITableView *worklistItemTable;
@property (nonatomic,strong)  WJCParameters *hiParas;  //
@property(nonatomic, assign)BOOL isScrollUp;//是否是向上滚动
@property(nonatomic, assign)CGFloat lastOffsetY;//滚动即将结束时scrollView的偏移量

@property (nonatomic,strong)  WJCHiWorklist *nowWorklist;  //

//临时组内容
@property (nonatomic,strong)  NSMutableArray<WJCOneGroup *> *tempGroups;  //

@property (nonatomic,strong)  WJCHiWorklist *tempHiWorklist;  //
@end

@implementation WJCWorklistEditorItemsView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isScrollUp = false;
    _lastOffsetY = 0;
    [self setTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithHiPara:(WJCParameters *)rHiPara withActualWorklist:(WJCHiWorklist*)rWorklist withTempWorklist:(WJCHiWorklist*)rTempWorklist{
    if (self = [super init]) {
        _hiParas = rHiPara;
        _nowWorklist = rWorklist;
        _tempHiWorklist = rTempWorklist;
        
        [self initGroupItems];
        
        [self setWorklistToVisibleGroup];
    }
    return self;
}

- (void)initGroupItems{
    for (int i=0; i<_hiParas.groupsCount; i++) {
        for (int j=0; j<_hiParas.actualGroup[i].visibleItemsCount; j++) {
            _hiParas.actualGroup[i].visibleItems[j].isSelect = NO;
            _hiParas.actualGroup[i].visibleItems[j].settingVal = _hiParas.paras[_hiParas.actualGroup[i].visibleItems[j]->index].defStrNew;
        }
    }
}


- (void)setTempWorklistFromGroup{
    [_tempHiWorklist.item removeAllObjects];
    for (int i=0; i<_hiParas.groupsCount; i++) {
        for (int j=0; j<_hiParas.actualGroup[i].visibleItemsCount; j++) {
            if (_hiParas.actualGroup[i].visibleItems[j].isSelect) {
                WJCHiWorklistItem *tempItem = [WJCHiWorklistItem hiWorklistItemWithIndex:_hiParas.actualGroup[i].visibleItems[j]->index withSname:_hiParas.actualGroup[i].visibleItems[j]->abbreviativeName withHiPara:_hiParas];
                tempItem->offlineVal = _hiParas.actualGroup[i].visibleItems[j].settingVal;
                [_tempHiWorklist.item addObject:tempItem];
            }
            
        }
    }
}

- (void)setWorklistToVisibleGroup{
    for (int i=0; i<_hiParas.groupsCount; i++) {
        for (int j=0; j<_hiParas.actualGroup[i].visibleItemsCount; j++) {
            for (int k=0; k<_nowWorklist.item.count; k++) {

                if ((_hiParas.actualGroup[i].visibleItems[j]->index == _nowWorklist.item[k].index) && ([_hiParas.actualGroup[i].visibleItems[j]->abbreviativeName isEqualToString:_nowWorklist.item[k].sName])) {

                    _hiParas.actualGroup[i].visibleItems[j].isSelect = YES;
                    _hiParas.actualGroup[i].visibleItems[j].settingVal = _nowWorklist.item[k]->offlineVal;
                    break;
                } else
                    _hiParas.actualGroup[i].visibleItems[j].isSelect = NO;
            }
            
            
        }
    }
}
//根据短名称 从worklist中获取当前参数index的索引值
- (NSInteger)getIndexFromWorklistWithSName:(NSString *)rSname{
    for (int i=0; i<_nowWorklist.item.count; i++) {
        if ([_nowWorklist.item[i].sName isEqualToString:rSname]) {
            return i;
        }
    }
    return -1;
}

#pragma mark- 界面搭建
- (void)setTable{
    float tempHe = 0;
    if ([[UIApplication sharedApplication] statusBarFrame].size.height >44) {
        tempHe = 20;
    }
    self.view = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.3, self.navigationController.navigationBar.bounds.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height-tempHe, self.view.frame.size.width * 0.7, self.view.frame.size.height-(self.navigationController.navigationBar.bounds.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height-tempHe))];
    
    self.worklistItemTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.worklistItemTable.delegate = self;
    self.worklistItemTable.dataSource = self;
    self.worklistItemTable.showsVerticalScrollIndicator = false;
    
    self.worklistItemTable.layer.borderWidth = 0.2;
    self.worklistItemTable.layer.borderColor = [[UIColor blackColor] CGColor];
    [self.view addSubview:self.worklistItemTable];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark- tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _hiParas.actualGroup.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _hiParas.actualGroup[section].visibleItemsCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return _hiParas.actualGroup[section].abbreviativeName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    if (_hiParas.actualGroup[indexPath.section].visibleItems[indexPath.row].isSelect) {
        cell.imageView.image = [UIImage imageNamed:@"radio_btn_on"];
    } else
        cell.imageView.image = [UIImage imageNamed:@"radio_btn_off"];
    
    
    cell.textLabel.text = _hiParas.actualGroup[indexPath.section].visibleItems[indexPath.row]->abbreviativeName;
    cell.detailTextLabel.text =[NSString stringWithFormat:@"%d %@",_hiParas.actualGroup[indexPath.section].visibleItems[indexPath.row]->index,_hiParas.paras[_hiParas.actualGroup[indexPath.section].visibleItems[indexPath.row]->index].lDescribe] ;
    //cell图片尺寸适当
    CGSize itemSize = CGSizeMake(20, 20);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0, 0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //cell分隔线
    [cell setSeparatorInset:UIEdgeInsetsZero];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(willDisplayHeaderView:)] && (_isScrollUp) &&_worklistItemTable.isDecelerating) {
        [self.delegate willDisplayHeaderView:section];
    }
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didEndDisplayingHeaderView:)] && !_isScrollUp &&_worklistItemTable.isDecelerating) {
        [self.delegate didEndDisplayingHeaderView:section];
    }
//        if ([self.delegate respondsToSelector:@selector(didEndDisplayingHeaderView:)] ) {
//            [self.delegate didEndDisplayingHeaderView:section];
//        }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WJCGroupItem *tempGItem = _hiParas.actualGroup[indexPath.section].visibleItems[indexPath.row];
//    if (tempGItem.isSelect) {
//        NSInteger tempIndex = [self getIndexFromWorklistWithSName:tempGItem->abbreviativeName] ;
//        if (tempIndex >= 0) {
//            [_nowWorklist.item removeObjectAtIndex:tempIndex];
//
//        }
//
//    } else {
//        WJCHiWorklistItem *tempWItem = [WJCHiWorklistItem hiWorklistItemWithIndex:tempGItem->index withSname:tempGItem->abbreviativeName withHiPara:_hiParas];
//        [_nowWorklist.item addObject:tempWItem];
//    }
    _hiParas.actualGroup[indexPath.section].visibleItems[indexPath.row].isSelect = !_hiParas.actualGroup[indexPath.section].visibleItems[indexPath.row].isSelect;

    [_worklistItemTable reloadData];
    [_worklistItemTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self setTempWorklistFromGroup];
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSLog(@"_lastOffsetY : %f,scrollView.contentOffset.y : %f", _lastOffsetY, scrollView.contentOffset.y);
    _isScrollUp = _lastOffsetY < scrollView.contentOffset.y;
    _lastOffsetY = scrollView.contentOffset.y;
    NSLog(@"______lastOffsetY: %f", _lastOffsetY);
}

#pragma mark - 一级tableView滚动时 实现当前类tableView的联动
- (void)scrollToSelectedIndexPath:(NSIndexPath *)indexPath {
    
    [self.worklistItemTable selectRowAtIndexPath:([NSIndexPath indexPathForRow:0 inSection:indexPath.row]) animated:YES scrollPosition:UITableViewScrollPositionTop];
}

@end
