//
//  InstantPanGestureRecognizer.m
//  Pangesture
//
//  Created by 김학철 on 2020/01/09.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "InstantPanGestureRecognizer.h"

@implementation InstantPanGestureRecognizer
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    if (self.state == UIGestureRecognizerStateBegan) {
//        return;
//    }
    
    [super touchesBegan:touches withEvent:event];
//    self.state = UIGestureRecognizerStateBegan;
}
@end
