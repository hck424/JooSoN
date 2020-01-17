//
//  NSObject+Utility.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/04.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "NSObject+Utility.h"

@implementation NSObject (Utility)

- (BOOL)isNotEmpty {
    return !(self == nil
             || [self isKindOfClass:[NSNull class]]
             || ([self respondsToSelector:@selector(length)]
                 && [(NSData *)self length] == 0)
             || ([self respondsToSelector:@selector(count)]
                 && [(NSArray *)self count] == 0));
    
};
@end
