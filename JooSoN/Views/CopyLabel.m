//
//  CopyLabel.m
//  JooSoN
//
//  Created by 김학철 on 2020/10/07.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "CopyLabel.h"

@implementation CopyLabel

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if(action == @selector(copy:)) {
        if (self.text.length > 0) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else if (action == @selector(paste:)) {
        return YES;
    }
    else {
        return [super canPerformAction:action withSender:sender];
    }
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    if([super becomeFirstResponder]) {
        self.highlighted = YES;
        return YES;
    }
    return NO;
}


- (void)copy:(id)sender {
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    [board setString:self.text];
    self.highlighted = NO;
    [self resignFirstResponder];
}

- (void)paste:(id)sender {
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    self.text = board.string;
    [self resignFirstResponder];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if([self isFirstResponder]) {
        self.highlighted = NO;
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu showMenuFromView:self rect:self.bounds];
        [menu update];
        [self resignFirstResponder];
    }
    else if([self becomeFirstResponder]) {
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu showMenuFromView:self rect:self.bounds];
    }
}

@end
