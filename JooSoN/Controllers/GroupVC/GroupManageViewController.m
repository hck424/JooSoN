//
//  GroupManageViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/26.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "GroupManageViewController.h"
#import "DBManager.h"
#import "GroupCell.h"
#import "HAlertView.h"
#import "AddGroupViewController.h"

@interface GroupManageViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdd;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (nonatomic, strong) GroupName *selGroupName;
@property (nonatomic, strong) NSMutableArray *arrData;
@end

@implementation GroupManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrData = [NSMutableArray array];
    
    _tblView.estimatedRowHeight = 50;
    _tblView.rowHeight = UITableViewAutomaticDimension;
    
    _tblView.tableFooterView = _footerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData {
    
    [[DBManager instance] getAllGroupName:^(NSArray *arrData) {
        [self.arrData removeAllObjects];
        if (arrData.count > 0) {
            [self.arrData setArray:arrData];
            self.tblView.hidden = NO;
            [self.tblView reloadData];
            
            
        }
        else {
            self.tblView.hidden = YES;
        }
        
    } fail:^(NSError *error) {
        
    }];
    
}

- (IBAction)onClickedButtonAction:(id)sender {
    if (sender == _btnBack) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (sender == _btnAdd) {
        AddGroupViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddGroupViewController"];
        vc.type = AddGroupTypeNew;
        vc.title = @"새 그룹";
        [self.navigationController pushViewController:vc animated:NO];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"GroupCell" owner:self options:nil].firstObject;
        
    }
    
    GroupName *data = [_arrData objectAtIndex:indexPath.row];
    
    [cell configurationData:data];
    [cell setTouchUpInsideAction:^(NSInteger btnIndex, id  _Nonnull data) {
        if (btnIndex == 0) {
            self.selGroupName = data;
            NSString *title = [NSString stringWithFormat:@"%@ 그룹", self.selGroupName.name];
            __weak typeof(self) weakSelf = self;
            [HAlertView alertShowWithTitle:title message:@"정말 삭제하시겠습니까?" btnTitles:@[@"확인", @"취소"] alertBlock:^(NSInteger index) {
                if (index == 0) {
                    [[DBManager instance] deleteGroupName:self.selGroupName success:^{
                        [self.arrData removeObject:self.selGroupName];
                        [weakSelf deleteJoosoGroupName:self.selGroupName.name];
                        self.selGroupName = nil;
                        [self.tblView reloadData];
                    } fail:^(NSError *error) {
                        NSLog(@"error: delete group name > %@", error);
                    }];
                }
            }];
        }
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selGroupName = [_arrData objectAtIndex:indexPath.row];
    
    AddGroupViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddGroupViewController"];
    vc.type = AddGroupTypeDefault;
    vc.passGroup = _selGroupName;
    vc.title = [NSString stringWithFormat:@"%@ 그룹", _selGroupName.name];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)deleteJoosoGroupName:(NSString *)delGrupName {
    NSString *delName = [NSString stringWithFormat:@"%@", delGrupName];
    [[DBManager instance] getGroupNameJooSoList:delName success:^(NSArray *arrData) {
        for (JooSo *js in arrData) {
            js.groupName = @"";
            [[DBManager instance] updateWidthJooSo:js success:nil fail:nil];
        }
        
    } fail:^(NSError *error) {
        
    }];
}
@end
