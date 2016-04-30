//
//  NSString+MCCCategory.m
//  MCCMenuBall
//
//  Created by MrChens on 16/4/30.
//  Copyright © 2016年 TMFuny. All rights reserved.
//

#import "NSString+MCCCategory.h"

@implementation NSString (MCCCategory)
- (unsigned int)getHexValue {
  unsigned result = 0;
  NSScanner *scanner = [NSScanner scannerWithString:self];
  NSUInteger scannerStartLocation = 0;
  if ([self containsString:@"0x"]) {
    scannerStartLocation = 2;
  } else if ([self containsString:@"#"]) {
    scannerStartLocation = 1;
  }
  [scanner setScanLocation:scannerStartLocation];
  [scanner scanHexInt:&result];
  return result;
}
@end
