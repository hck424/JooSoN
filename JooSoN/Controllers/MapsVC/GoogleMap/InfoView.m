//
//  InfoView.m
//  JooSoN
//
//  Created by 김학철 on 2020/09/18.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "InfoView.h"

@implementation InfoView
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius = 8.0;
    self.clipsToBounds = YES;
    self.layer.borderColor = RGB(233, 233, 233).CGColor;
    self.layer.borderWidth = 1.0f;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
