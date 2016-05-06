//
//  MCCMenuBall.h
//  MCCMenuBall
//
//  Created by MrChens on 16/4/30.
//  Copyright © 2016年 TMFuny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCCMenuBall : UIControl

@property (nonatomic, getter=isDraggable) BOOL draggable;///< Default is YES
@property (nonatomic, assign) UIEdgeInsets margin;///< Default is (5, 5, 5, 5)
@property (nonatomic,getter=isMomentary) BOOL momentary;///< Default is YES
@property (nonatomic, getter=isAdsorption) BOOL adsorption;///< Default is YES
@property (nonatomic, assign) CGPoint defaultPosition;///< Default is (0,0)
@property (assign, nonatomic) UIEdgeInsets mTouchEdgeInsets;///< Default is UIEdgeInsetsZero
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (void)show;
- (void)hidden;

@end
