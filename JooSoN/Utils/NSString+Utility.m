//
//  NSString+Utility.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/17.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "NSString+Utility.h"

@implementation NSString (Utility)

- (NSString *)delPhoneFormater {
    NSString *mobileNumber = self;
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    return mobileNumber;
}
- (NSString *)addPoneFormater {
    NSString *mobileNumber = self;
    if (mobileNumber.length > 0) {
        if ([mobileNumber hasPrefix:@"02"]) {
            if (mobileNumber.length == 2) {
                
            }
        }
        else {
            
        }
    }
    return mobileNumber;
}
- (BOOL)isNumeric {
    NSScanner *scanner = [NSScanner scannerWithString:self];
    return [scanner scanInteger:NULL] && [scanner isAtEnd];
}

- (BOOL)isNull {
    if ([self isEqual:[NSNull null]] || self == nil) {
        return YES;
    }
    return NO;
}

- (NSString *)convertEmptyStringToNull {
    if ([self isNull]) {
        return @"";
    }
    return self;
}
- (NSComparisonResult)sortForCharactor:(NSString*)comp {
    // 기본 localizedCaseInsensitiveCompare는 숫자, 영문(대소무시), 한글 순 정렬
    // 한글 > 영문(대소구분 없음) > 숫자 > $
    // 그외 특수문자는 전부 무시한채 인덱싱
    // $는 예외
    
    // self 가 @"ㄱ" 보다 작고 (한글이 아니고) , comp 가 @"ㄱ"보다 같거나 클때 - 무조건 크다
    // 비교하면 -1 0 1 이 작다, 같다, 크다 순이므로 +1 을 하면 한글일때 YES 아니면 NO 가 된다.
    // self 가 한글이고 comp 가 한글이 아닐때 무조건 작다인 조건과
    // self 가 글자(한/영)이 아니고 comp가 글자(한/영)일떄 무조건 크다인 조건을 반영한다.
    NSString* left = [NSString stringWithFormat:@"%@%@",
                      [self localizedCaseInsensitiveCompare:@"ㄱ"]+1 ? @"0" :
                      !([self localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" :
                      @"1", self];
    
    NSString* right = [NSString stringWithFormat:@"%@%@",
                       [comp localizedCaseInsensitiveCompare:@"ㄱ"]+1 ? @"0" :
                       !([comp localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" :
                       @"1", comp];
    return [left localizedCaseInsensitiveCompare:right];
}

- (NSString *)alphabetHangul {
    if ([self isEqual:[NSNull null]]
        || self.length == 0
        || self == nil) {
        return nil;
    }
    unichar charactor = [self characterAtIndex:0];
    NSString *result = nil;
    if (charactor >= 0xAC00  && charactor < 0xB098) {
        result = @"ㄱ";
    }
    else if (charactor >= 0xB098 && charactor < 0xB2E4) {
        result = @"ㄴ";
    }
    else if (charactor >= 0xB2E4 && charactor < 0xB77C) {
        result = @"ㄷ";
    }
    else if (charactor >= 0xB77C && charactor < 0xB9C8) {
        result = @"ㄹ";
    }
    else if (charactor >= 0xB9C8 && charactor < 0xBC14) {
        result = @"ㅁ";
    }
    else if (charactor >= 0xBC14 && charactor < 0xC0AC) {
        result = @"ㅂ";
    }
    else if (charactor >= 0xC0AC && charactor < 0xC544) {
        result = @"ㅅ";
    }
    else if (charactor >= 0xC544 && charactor < 0xC790) {
        result = @"ㅇ";
    }
    else if (charactor >= 0xC790 && charactor < 0xCC28) {
        result = @"ㅈ";
    }
    else if (charactor >= 0xCC28 && charactor < 0xCE74) {
        result = @"ㅊ";
    }
    else if (charactor >= 0xCE74 && charactor < 0xD0C0) {
        result = @"ㅋ";
    }
    else if (charactor >= 0xD0C0 && charactor < 0xD30C) {
        result = @"ㅌ";
    }
    else if (charactor >= 0xD30C && charactor < 0xD558) {
        result = @"ㅍ";
    }
    else if (charactor >= 0xD558 && charactor < 0xD7AF) {
        result = @"ㅎ";
    }
    else if (charactor == 'a' || charactor == 'A') {
        result = @"A";
    }
    else if (charactor == 'b' || charactor == 'B') {
        result = @"B";
    }
    else if (charactor == 'c' || charactor == 'C') {
        result = @"C";
    }
    else if (charactor == 'd' || charactor == 'D') {
        result = @"D";
    }
    else if (charactor == 'e' || charactor == 'E') {
        result = @"E";
    }
    else if (charactor == 'f' || charactor == 'F') {
        result = @"F";
    }
    else if (charactor == 'g' || charactor == 'G') {
        result = @"G";
    }
    else if (charactor == 'h' || charactor == 'H') {
        result = @"H";
    }
    else if (charactor == 'i' || charactor == 'I') {
        result = @"I";
    }
    else if (charactor == 'j' || charactor == 'J') {
        result = @"J";
    }
    else if (charactor == 'k' || charactor == 'K') {
        result = @"K";
    }
    else if (charactor == 'l' || charactor == 'L') {
        result = @"L";
    }
    else if (charactor == 'm' || charactor == 'M') {
        result = @"M";
    }
    else if (charactor == 'n' || charactor == 'N') {
        result = @"N";
    }
    else if (charactor == 'o' || charactor == 'O') {
        result = @"O";
    }
    else if (charactor == 'p' || charactor == 'P') {
        result = @"P";
    }
    else if (charactor == 'q' || charactor == 'Q') {
        result = @"Q";
    }
    else if (charactor == 'r' || charactor == 'R') {
        result = @"R";
    }
    else if (charactor == 's' || charactor == 'S') {
        result = @"S";
    }
    else if (charactor == 't' || charactor == 'T') {
        result = @"T";
    }
    else if (charactor == 'u' || charactor == 'U') {
        result = @"U";
    }
    else if (charactor == 'v' || charactor == 'V') {
        result = @"V";
    }
    else if (charactor == 'w' || charactor == 'W') {
        result = @"W";
    }
    else if (charactor == 'x' || charactor == 'X') {
        result = @"X";
    }
    else if (charactor == 'y' || charactor == 'Y') {
        result = @"Y";
    }
    else if (charactor == 'z' || charactor == 'Z') {
        result = @"Z";
    }
    else if (charactor >= '0' && charactor <= '9') {
        result = @"#";
    }
    return result;
}

- (NSString *)addNumberFormater {
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSString *result = [formatter stringFromNumber:[NSNumber numberWithDouble:[self doubleValue]]];
    return result;
}

- (NSString *)delNumberFormater {
    NSString *retVal = @"";
    
    if ([self isEqualToString:@""]) {
        return retVal;
    }
    
    retVal = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"," withString:@""];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"." withString:@""];
    return retVal;
}

@end
