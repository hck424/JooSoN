//
//  GroupJoosoListViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/19.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "GroupListViewController.h"
#import "TableHeaderView.h"
#import "DBManager.h"
#import "JooSoCell.h"
#import "AppDelegate.h"
#import "NSString+Utility.h"
#import "CallkitController.h"
#import "UIView+Toast.h"
#import "InfoJooSoViewController.h"

@interface GroupListViewController () <CallkitControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *lbEmpty;
@property (nonatomic, strong) NSMutableArray *arrOrigin;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) JooSo *selJooso;
@property (nonatomic, strong) CallkitController *callkitController;

@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSMutableArray *arrGroupName;
@end

@implementation GroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tblView.tableFooterView = _footerView;
    self.arrOrigin = [NSMutableArray array];
    self.arrData = [NSMutableArray array];
    self.arrGroupName = [NSMutableArray array];
    
    self.callkitController = [[CallkitController alloc] init];
    _callkitController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestGroupList];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {

}

- (void)requestGroupList {
    [[DBManager instance] getAllGroupName:^(NSArray *arrData) {
        if (arrData.count > 0) {
            [self.arrGroupName setArray:arrData];
        }
        else {
            [self.view makeToast:@"그룹이 리스트가 없습니다./n그룹 관리에서 그룹을 추가해 주세요." duration:1.0 position:CSToastPositionTop];
        }
    } fail:^(NSError *error) {
        NSLog(@"error: group all list > %@", error);
    }];
}
- (void)reloadData {
    self.groupName = [[NSUserDefaults standardUserDefaults] objectForKey:EntityApointGroupName];
    __weak typeof(self) weakSelf = self;
    [[DBManager instance] getGroupNameJooSoList:_groupName success:^(NSArray *arrData) {
        if (arrData.count > 0) {
            self.tblView.hidden = NO;
            self.lbEmpty.hidden = YES;
            [self.arrOrigin setArray:arrData];
            [weakSelf makeSectionData:self.arrOrigin];
        }
        else {
            self.tblView.hidden = YES;
            self.lbEmpty.hidden = NO;
        }
    } fail:^(NSError *error) {
        NSLog(@"error: group jooso list > %@", error);
    }];
    
}

- (void)makeSectionData:(NSMutableArray *)arrData {
    
    [_arrData removeAllObjects];
    
    for (GroupName *group in _arrGroupName) {
        
        NSMutableArray *secArray = [NSMutableArray array];
        for (JooSo *js in arrData) {
            if ([js.groupName isEqualToString:group.name]) {
                [secArray addObject:js];
            }
        }
        
        if (secArray.count > 0) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:group.name forKey:@"sec_title"];
            [dic setObject:secArray forKey:@"sec_list"];
            [_arrData addObject:dic];
        }
    
    }
    
    [self.tblView reloadData];
}

- (void)setSearchText:(NSString *)searchTxt {
    NSLog(@"%@", searchTxt);
    NSMutableArray *arrSeach = [NSMutableArray array];

    if ([searchTxt isNumeric]) {
        for (JooSo *jooso in _arrOrigin) {
            if ([[jooso getMainPhone] containsString:searchTxt]) {
                [arrSeach addObject:jooso];
            }
        }
    }
    else {
        for (JooSo *jooso in _arrOrigin) {
            NSString *name = jooso.name;
            if ([name containsString:searchTxt]) {
                [arrSeach addObject:jooso];
            }
        }
    }
    
    if (searchTxt.length == 0) {
        [self makeSectionData:_arrOrigin];
    }
    else {
        [self makeSectionData:arrSeach];
    }
}


#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _arrData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_arrData objectAtIndex:section] objectForKey:@"sec_list"] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JooSoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JooSoCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"JooSoCell" owner:self options:nil].firstObject;
        cell.cellType = CellTypeDefault;
    }
    
    JooSo *jooso = [[[_arrData objectAtIndex:indexPath.section] objectForKey:@"sec_list"] objectAtIndex:indexPath.row];
    
    [cell configurationData:jooso];
    
    [cell setOnBtnTouchUpInside:^(CellActionType actionType, JooSo *jooso, id data) {
        NSString *url = @"";
        if (actionType == CellActionCall) {
            url = [NSString stringWithFormat:@"tel://%@", [jooso getMainPhone]];
        }
        else if (actionType == CellActionSms) {
            url = [NSString stringWithFormat:@"sms://%@", [jooso getMainPhone]];
        }
        self.selJooso = jooso;
        [[AppDelegate instance] openSchemeUrl:url];
    }];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    TableHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:self options:nil].firstObject;
    NSString *titleStr = [[_arrData objectAtIndex:section] objectForKey:@"sec_title"];
    headerView.lbTitle.text = titleStr;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JooSo *jooso = [[[_arrData objectAtIndex:indexPath.section] objectForKey:@"sec_list"] objectAtIndex:indexPath.row];
    InfoJooSoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoJooSoViewController"];
    vc.passJooso = jooso;
    [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
}

#pragma mark - CallkitControllerDelegate
- (void)callkitControllerState:(NSString *)state {
    NSLog(@"GroupJoosolistViewCon %@", state);
    if ([state isEqualToString:CALLING_STATE_DISCONNECTED]) {
        
    }
    else if ([state isEqualToString:CALLING_STATE_DAILING]) {
        
    }
    else if ([state isEqualToString:CALLING_STATE_INCOMING]) {
        
    }
    else if ([state isEqualToString:CALLING_STATE_CONNECTED]) {
        
    }
}
@end
