//
//  MCCMonitorBall.h
//  MCCMenuBall
//
//  Created by MrChens on 16/4/30.
//  Copyright © 2016年 TMFuny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCCMonitorBall : UIControl
@property (nonatomic, readonly) NSString *currentTitle;
@property (nonatomic, assign, readonly, getter=isAutoLayoutMode)BOOL isAutoLayoutMode;///< Default is NO
@property (nonatomic, assign) CGFloat leading;///< Default is 8
@property (nonatomic, assign) CGFloat trailing;///< Default is 8
@property (nonatomic, assign) CGFloat fontSize;///< Default is 14
@property (nonatomic, assign) CGFloat highlighAlpha;///< Default is 0.1
@property (nonatomic, strong) UIColor *hightBackGroundColor;///< Default is 0x000000
/**
 *使用绝对布局来初始化监控球
 *
 *return 监控球实例
 **/
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;
/**
 *使用自动布局来初始化监控球
 *
 *return 监控球实例
 **/
- (instancetype)initWithTitle:(NSString *)title;

- (void)updateTitle:(NSString *)title backGroundColorString:(NSString *)backgroundColorString titleColorString:(NSString *)fontColorString;
- (void)updateTitle:(NSString *)title backGroundColor:(UIColor *)backgroundColor titleColor:(UIColor *)fontColor;

- (void)updateTitle:(NSString *)title;
- (void)fadeWithAlpha:(CGFloat)alpha;
- (void)show;
- (void)hidden;

- (CGFloat)getMonitorBallWidth;

@end
