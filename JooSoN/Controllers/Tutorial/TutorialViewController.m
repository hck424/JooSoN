//
//  TutorialViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/15.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "TutorialViewController.h"
#import "AppDelegate.h"

@interface TutorialViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnSkip;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic, assign) NSInteger curPageIdx;
@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.delegate = self;
}

- (void)hideButton {
    if (_curPageIdx == 2) {
        _btnSkip.hidden = YES;
        _btnNext.hidden = YES;
        _pageControl.hidden = YES;
        _btnStart.hidden = NO;
    }
    else {
        _btnSkip.hidden = NO;
        _btnNext.hidden = NO;
        _pageControl.hidden = NO;
        _btnStart.hidden = YES;
    }
}
- (void)setCurPageIdx:(NSInteger)curPageIdx {
    _curPageIdx = curPageIdx;
    [self hideButton];
}

- (IBAction)pageControllerValueChange:(UIPageControl *)sender {
    self.curPageIdx = sender.currentPage;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGFloat x = self.curPageIdx * self.scrollView.frame.size.width;
        self.scrollView.contentOffset = CGPointMake(x, 0);
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)onClickedButtonAction:(id)sender {
    
    if (sender == _btnSkip
        || sender == _btnStart) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:Tutorial_Once_Show];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[AppDelegate instance] callMainViewController];
    }
    else if (sender == _btnNext) {
        self.curPageIdx = self.curPageIdx + 1;
        [_pageControl setCurrentPage:_curPageIdx];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _curPageIdx = scrollView.contentOffset.x / scrollView.frame.size.width;
    [_pageControl setCurrentPage:_curPageIdx];
    [self hideButton];
}

@end
