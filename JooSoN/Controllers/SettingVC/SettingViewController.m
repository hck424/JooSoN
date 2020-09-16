//
//  SettingViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "SettingViewController.h"
#import "MainViewController.h"
#import "UIViewController+LGSideMenuController.h"
#import "SettingCell.h"
#import "UIView+Toast.h"
#import "AppDelegate.h"

@interface SettingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (nonatomic, strong) NSString *selectedMapId;
@property (nonatomic, strong) NSMutableArray *arrData;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrData = [NSMutableArray array];
    [self makeData];
    _tblView.tableFooterView = _footerView;
    _tblView.estimatedRowHeight = 70;
    _tblView.rowHeight = UITableViewAutomaticDimension;
    
    
    _selectedMapId = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId];
    
    [self.tblView reloadData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)onClickedButtonAction:(id)sender {
    if (sender == _btnBack) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (void)makeData {
    NSMutableArray *arrSection = [NSMutableArray array];
    NSDictionary *itemDic = [NSDictionary dictionaryWithObjectsAndKeys:@"네이버 Map", @"mapName", MapIdNaver, @"mapId",  nil];
    [arrSection addObject:itemDic];
    
    itemDic = [NSDictionary dictionaryWithObjectsAndKeys:@"구글 Map", @"mapName", MapIdGoogle, @"mapId",  nil];
    [arrSection addObject:itemDic];
    
    itemDic = [NSDictionary dictionaryWithObjectsAndKeys:@"카카오 Map", @"mapName", MapIdKakao, @"mapId",  nil];
    [arrSection addObject:itemDic];
    
//    itemDic = [NSDictionary dictionaryWithObjectsAndKeys:@"T Map", @"mapName", MapIdTmap, @"mapId",  nil];
//    [arrSection addObject:itemDic];
    
    [_arrData addObject:arrSection];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _arrData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_arrData objectAtIndex:section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:nil options:nil].firstObject;
    }
    
    NSDictionary *itemDic = [[_arrData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([_selectedMapId isEqualToString:[itemDic objectForKey:@"mapId"]]) {
        cell.ivIcon.image = [UIImage imageNamed:@"chk_select_c"];
    }
    else {
        cell.ivIcon.image = [UIImage imageNamed:@"chk_select_b"];
    }
    
    cell.lbTitle.text = [itemDic objectForKey:@"mapName"];

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tblView.frame.size.width, 50)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *lbSecTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, headerView.frame.size.height - 25, headerView.frame.size.width - 15, 25)];
    lbSecTitle.textColor = RGB(38, 38, 38);
    lbSecTitle.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    
    [headerView addSubview:lbSecTitle];
    
    if (section == 0) {
        lbSecTitle.text = @"맵 설정";
    }
    
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *itemDic = [[_arrData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *newMapId = [itemDic objectForKey:@"mapId"];
    if ([_selectedMapId isEqualToString:newMapId] == NO) {
        if ([newMapId isEqualToString:MapIdTmap]) {
            [self.view makeToast:@"서비스 준비중입니다." duration:1.0 position:CSToastPositionTop];
        }
        else {
            self.selectedMapId = newMapId;
            [[NSUserDefaults standardUserDefaults] setObject:_selectedMapId forKey:SelectedMapId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            AppDelegate.instance.selMapId = _selectedMapId;
            [[NSNotificationCenter defaultCenter] postNotificationName:NotiChangeMapId object:nil];
        }
    }
    [self.tblView reloadData];
}

@end
