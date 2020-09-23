//
//  MapSearchResultListController.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/07.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "MapSearchResultListController.h"
#import "MapSearchResultCell.h"
#import "UIView+Utility.h"
#import "AddJooSoViewController.h"
#import "AppDelegate.h"
#import "NfcViewController.h"
#import "MapAddressSaveViewController.h"

@interface MapSearchResultListController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UIView *headerview;
@property (weak, nonatomic) IBOutlet UILabel *lbSearchResult;
@property (weak, nonatomic) IBOutlet UILabel *lbCurrentAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbSearchQuery;

@property (nonatomic, strong) PlaceInfo *selPlaceInfo;
@end

@implementation MapSearchResultListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tblView.tableHeaderView = _headerview;
    _tblView.estimatedRowHeight = 120;
    _tblView.rowHeight = UITableViewAutomaticDimension;
    
    _lbSearchResult.text = [NSString stringWithFormat:@"총 %ld건의 검색결고가 있습니다.", _arrData.count];
    _lbCurrentAddress.text = _curPlaceInfo.jibun_address;
    _lbSearchQuery.text = _searchQuery;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (IBAction)onClickedButtonActions:(id)sender {
    if (sender == _btnBack) {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MapSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MapSearchResultCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MapSearchResultCell" owner:self options:0].firstObject;
    }
    
    PlaceInfo *info = [_arrData objectAtIndex:indexPath.row];
    [cell configurationData:info];
    
    [cell setOnTouchUpInSideAction:^(MapCellAction action, PlaceInfo *data) {
        self.selPlaceInfo = data;

        if (action == MapCellActionSave) {
            AddJooSoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddJooSoViewController"];
            vc.viewType = ViewTypeAdd;
            vc.placeInfo = self.selPlaceInfo;
            [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
        }
        else if (action == MapCellActionNfc) {
            NfcViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NfcViewController"];
            vc.passPlaceInfo = self.selPlaceInfo;
            [[AppDelegate instance].rootNavigationController pushViewController:vc animated:NO];
        }
        else if (action == MapCellActionNavi) {
            NSString *url = nil;
            NSString *selMapId = AppDelegate.instance.selMapId;
            if ([selMapId isEqualToString:MapIdNaver]) {
                url = [NSString stringWithFormat:@"nmap://place?lat=%f&lng=%lf&name=%@&appname=%@", self.selPlaceInfo.y, self.selPlaceInfo.x, self.selPlaceInfo.jibun_address, [[NSBundle mainBundle] bundleIdentifier]];
                url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
            }
            else if ([selMapId isEqualToString:MapIdGoogle]) {
                url = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@&sll=%lf,%lf", self.selPlaceInfo.jibun_address, self.selPlaceInfo.y, self.selPlaceInfo.x];
                url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
            }

            if (url.length > 0) {
                [[AppDelegate instance] openSchemeUrl:url];
            }
        }
        else if (action == MapCellActionShare) {
            
        }
        
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.selPlaceInfo = [_arrData objectAtIndex:indexPath.row];
    
    MapAddressSaveViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapAddressSaveViewController"];
    vc.passPlaceInfo = _selPlaceInfo;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
