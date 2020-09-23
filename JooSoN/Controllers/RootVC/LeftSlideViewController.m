//
//  LeftSlideViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "LeftSlideViewController.h"
#import "MainViewController.h"
#import "UIViewController+LGSideMenuController.h"
#import "SettingViewController.h"
#import "SettingCell.h"

@interface LeftSlideViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSString *selectedMapId;
@end

@implementation LeftSlideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"logo_back"]];
    self.view.backgroundColor = color;
    self.arrData = [NSMutableArray array];
    [self makeLeftMenuData];
    _tblView.tableHeaderView = _headerView;
    _tblView.tableFooterView = _footerView;
    _tblView.bounces = NO;
    _tblView.estimatedRowHeight = 70;
    _tblView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tblView reloadData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)makeLeftMenuData {
    NSDictionary *itemDic = [NSDictionary dictionaryWithObjectsAndKeys:@"사용방법", @"title",
                             @"icon_star_filled", @"img_name",
                             @"https://jooso-n.com/#", @"link", nil];
    [_arrData addObject:itemDic];
    
    NSDictionary *itemDic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"설정", @"title",
                              @"icon_setting", @"img_name",
                              @"", @"link", nil];
    
    [_arrData addObject:itemDic1];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:nil options:nil].firstObject;
    }
    
    NSDictionary *itemDic = [_arrData objectAtIndex:indexPath.row];
    NSString *imgName = [itemDic objectForKey:@"img_name"];
    NSString *title = [itemDic objectForKey:@"title"];
    cell.ivIcon.image = [UIImage imageNamed:imgName];
    cell.lbTitle.text = title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSDictionary *itemDic = [_arrData objectAtIndex:indexPath.row];
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    if (indexPath.row == 0) {
        NSURL *url = [NSURL URLWithString:[itemDic objectForKey:@"link"]];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
        [mainViewController hideLeftViewAnimated:YES delay:0.0 completionHandler:nil];
    }
    else if (indexPath.row == 1) {
        UINavigationController *navigation = (UINavigationController*)mainViewController.rootViewController;
        SettingViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
        [navigation pushViewController:vc animated:NO];
        [mainViewController hideLeftViewAnimated:YES delay:0.0 completionHandler:nil];
    }
}

@end
