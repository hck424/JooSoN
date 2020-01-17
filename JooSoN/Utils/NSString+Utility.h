//
//  NSString+Utility.h
//  JooSoN
//
//  Created by 김학철 on 2019/12/17.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Utility)
- (NSString *)addNumberFormater;
- (NSString *)delNumberFormater;
- (NSString *)delPhoneFormater;
- (NSString *)addPoneFormater;
- (NSComparisonResult)sortForCharactor:(NSString*)comp;
- (NSString *)alphabetHangul;
- (BOOL)isNumeric;
- (BOOL)isNull;
- (NSString *)convertEmptyStringToNull;
@end
