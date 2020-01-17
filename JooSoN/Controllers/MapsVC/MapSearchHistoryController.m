//
//  MapSearchHistoryController.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/07.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "MapSearchHistoryController.h"
#import "DBManager.h"
#import "TableHeaderView.h"

@interface MapSearchHistoryController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UITableView *tblView;

@end

@implementation MapSearchHistoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrData = [NSMutableArray array];
    
    _tblView.tableFooterView = _footerView;
    _tblView.estimatedRowHeight = 45;
    _tblView.rowHeight = UITableViewAutomaticDimension;
}

- (void)reloadData {
    [self.tblView reloadData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MapSearchHistoryCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MapSearchHistoryCell"];
    }
    
    MapSearchHistory *history = [_arrData objectAtIndex:indexPath.row];
    cell.textLabel.text = history.text;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TableHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:self options:nil].firstObject;
    headerView.lbTitle.text = @"최근 검색어";
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0f;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MapSearchHistory *history = [_arrData objectAtIndex:indexPath.row];
        [[DBManager instance] deleteMapSearchHistory:history success:nil fail:nil];
        [_arrData removeObject:history];
        
        if (_arrData.count == 0 && [self.delegate respondsToSelector:@selector(mapSearchHistoryHiden:)]) {
            [_delegate mapSearchHistoryHiden:YES];
        }
        else {
            [self reloadData];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(mapSearchHistorySelItem:)]) {
        MapSearchHistory *history = [_arrData objectAtIndex:indexPath.row];
        [_delegate mapSearchHistorySelItem:history];
    }
}
@end
