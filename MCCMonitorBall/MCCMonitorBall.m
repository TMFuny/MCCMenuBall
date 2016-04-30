//
//  MCCMonitorBall.m
//  MCCMenuBall
//
//  Created by MrChens on 16/4/30.
//  Copyright © 2016年 TMFuny. All rights reserved.
//

#import "MCCMonitorBall.h"
#import "NSString+MCCCategory.h"
#import "UIView+WSUtility.h"

#define uiTest (0)
#define UIColorFromHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static const float kMCCMonitorBallAlpha = 0.80;
static const float kMCCMonitorBallHidenAlpha = 0.015;
@interface MCCMonitorBall ()
@property (nonatomic, readwrite) NSString *currentTitle;
@property (nonatomic, strong) UIColor *currentBackGroundColor;
@property (nonatomic, strong) UIColor *currentTitleColor;
@property (nonatomic, assign) CGFloat currentAlpha;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation MCCMonitorBall{
  CAShapeLayer *_maskLayer;
}

#pragma mark - ViewLifeCycle
#pragma mark - UIInit
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title {
  self = [super initWithFrame:frame];
  
  if (self) {
    title = title?title:@"";
    _isAutoLayoutMode = NO;
    [self commonInit];
    [self addSubview:({
      _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(frame)+_leading, 0, CGRectGetWidth(frame)-_leading - _trailing, CGRectGetHeight(frame))];
      _titleLabel.text = title;
      _titleLabel.backgroundColor = [UIColor clearColor];
      _titleLabel.textColor = _currentTitleColor;
      _titleLabel.font = [UIFont systemFontOfSize:_fontSize];
      [_titleLabel sizeToFit];
      _titleLabel;
    })];
  }
  return self;
}

- (instancetype)initWithTitle:(NSString *)title {
  self = [super init];
  
  if (self) {
    title = title?title:@"";
    _isAutoLayoutMode = YES;
    [self commonInit];
    _titleLabel = [[UILabel alloc] init];
    [self addSubview:_titleLabel];
    
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self newConstraints];
    
    
    _titleLabel.text = title;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = _currentTitleColor;
    _titleLabel.font = [UIFont systemFontOfSize:_fontSize];
    
  }
  return self;
}

- (void)commonInit {
  _hightBackGroundColor = UIColorFromHex(0x000000);
  _currentBackGroundColor = UIColorFromHex(0x000000);
  _currentTitleColor = UIColorFromHex(0xffffff);
  _leading = 8;
  _trailing = 8;
  _fontSize = 14;
  _highlighAlpha = 0.1;
  self.translatesAutoresizingMaskIntoConstraints = NO;
  self.backgroundColor = _currentBackGroundColor;
  self.alpha = kMCCMonitorBallAlpha;
  
  _currentAlpha = kMCCMonitorBallAlpha;
  
  
  _maskLayer = [[CAShapeLayer alloc] init];
  _maskLayer.masksToBounds = YES;
  self.layer.mask = _maskLayer;
}
#pragma mark - UIConfig
#pragma mark - UIUpdate
- (void)layoutSubviews {
  [super layoutSubviews];
  
  if (!CGRectEqualToRect(_maskLayer.frame, self.bounds)) {
    _maskLayer.frame = self.bounds;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(11.5, 11.5)];
    _maskLayer.path = bezierPath.CGPath;
  }
}
#pragma mark - AppleDataSource and Delegate
#pragma mark - ThirdPartyDataSource and Delegate
#pragma mark - CustomDataSource and Delegate
#pragma mark - Target-Action Event
- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  
  if (highlighted) {
    self.backgroundColor = _hightBackGroundColor;
    self.alpha =  _highlighAlpha;
  } else {
    self.backgroundColor = _currentBackGroundColor;
    self.alpha = _currentAlpha;
  }
}

-(void)setLeading:(CGFloat)leading {
  _leading = leading;
  if (_isAutoLayoutMode) {
    [self newConstraints];
  }
}
- (void)setTrailing:(CGFloat)trailing {
  _trailing = trailing;
  if (_isAutoLayoutMode) {
    [self newConstraints];
  }
}

#pragma mark - PublicMethod
- (NSString *)currentTitle {
  if (_titleLabel.text && _titleLabel.text.length != 0) {
    return _titleLabel.text;
  }
  return @"";
}

- (void)updateTitle:(NSString *)title backGroundColorString:(NSString *)backgroundColorString titleColorString:(NSString *)fontColorString {
  if (!title || title.length == 0) {
    _titleLabel.text = title;
    [self hidden];
    return;
  }
  
  if (!fontColorString || fontColorString.length == 0) {
    fontColorString = @"ffffff";
  }
  if (!backgroundColorString || backgroundColorString.length == 0) {
    backgroundColorString = @"000000";
  }
  
  [self updateTitle:title];
  [self updateBackGroundColor:UIColorFromHex([backgroundColorString getHexValue]) titleColor:UIColorFromHex([fontColorString getHexValue])];
}

- (void)updateTitle:(NSString *)title backGroundColor:(UIColor *)backgroundColor titleColor:(UIColor *)titleColor {
  if (!title || title.length == 0) {
    _titleLabel.text = title;
    [self hidden];
    return;
  }
  
  [self updateTitle:title];
  [self updateBackGroundColor:backgroundColor titleColor:titleColor];
}

- (void)updateBackGroundColor:(UIColor *)backgroundColor titleColor:(UIColor *)titleColor {
  _currentBackGroundColor = backgroundColor;
  _currentTitleColor = titleColor;
  
  self.backgroundColor = _currentBackGroundColor;
  _titleLabel.textColor = _currentTitleColor;
  _maskLayer.fillColor = _currentBackGroundColor.CGColor;
  
  [self show];
}

- (void)updateTitle:(NSString *)title {
  _titleLabel.text = title;
  if (_isAutoLayoutMode) {
    return;
  }
  [_titleLabel sizeToFit];
  [_titleLabel resizeToHeight:self.bounds.size.height];
  [_titleLabel moveToX:_leading];
}

- (void)fadeWithAlpha:(CGFloat)alpha {
  _currentAlpha = alpha;
  if (_currentAlpha>kMCCMonitorBallAlpha) {
    _currentAlpha = kMCCMonitorBallAlpha;
  }
  self.alpha = _currentAlpha;
  
  if (_currentAlpha < kMCCMonitorBallHidenAlpha ) {
    [self hidden];
  } else {
    [self show];
  }
}

- (void)show {
  if (![self currentTitle] || [self currentTitle].length == 0) {
    [self hidden];
    return;
  }
  if (!self.isHidden) {
    return;
  }
  self.hidden = NO;
  self.userInteractionEnabled = YES;
  self.alpha = 0;
  
  [UIView animateWithDuration:0.3 delay:1.0 options:UIViewAnimationOptionTransitionNone animations:^{
    self.alpha = 0;
  } completion:^(BOOL finished) {
    self.alpha = _currentAlpha;
  }];
}

- (void)hidden {
  if (self.isHidden) {
    return;
  }
  self.hidden = YES;
  self.userInteractionEnabled = NO;
}

- (CGFloat)getMonitorBallWidth {
  return _titleLabel.bounds.size.width + self.leading + self.trailing;
}
#pragma mark - PrivateMethod
- (void)newConstraints {
  
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
    [self constraintGreaterThanIOS8];
    return;
  }
  [self constraintLessThanIOS8];
}

- (void)constraintLessThanIOS8 {
  [self removeConstraints:self.constraints];
  
  [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                   attribute:NSLayoutAttributeLeading
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeLeading
                                                  multiplier:1 constant:_leading]];
  
  [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                   attribute:NSLayoutAttributeTrailing
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeTrailing
                                                  multiplier:1 constant:-_trailing]];
  
  [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                   attribute:NSLayoutAttributeTop
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeTop
                                                  multiplier:1 constant:5]];
  
  [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                   attribute:NSLayoutAttributeBottom
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeBottom
                                                  multiplier:1 constant:-5]];
}

- (void)constraintGreaterThanIOS8 {
  [NSLayoutConstraint deactivateConstraints:self.constraints];
  
  NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeLeading
                                                                      multiplier:1 constant:_leading];
  
  NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeTrailing
                                                                       multiplier:1 constant:-_trailing];
  
  NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1 constant:5];
  
  NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1 constant:-5];
  [NSLayoutConstraint activateConstraints:@[leadingConstraint, trailingConstraint, topConstraint, bottomConstraint]];
}
//- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
//  [super sendAction:@selector(handleAction:) to:self forEvent:event];
//}
//
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//  return CGRectContainsPoint(self.bounds, point);
//}
//
//- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
//  [super beginTrackingWithTouch:touch withEvent:event];
//  NSLog(@"Begin Track:%d", self.tracking);
//  return YES;
//}
//
//- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
//  [super continueTrackingWithTouch:touch withEvent:event];
//  NSLog(@"Continue Track:%d %@", self.tracking, (self.touchInside ? @"YES": @"NO"));
//  return YES;
//}
//
//- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
//  [super endTrackingWithTouch:touch withEvent:event];
//  CGPoint position = [touch locationInView:self];
//
//  if (CGRectContainsPoint(self.bounds, position)) {
//    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
//  }
//
//  NSLog(@"End Track:%d", self.tracking);
//}
//
//- (void)cancelTrackingWithEvent:(UIEvent *)event {
//  [super cancelTrackingWithEvent:event];
//  NSLog(@"Cancel Track");
//}
//
//- (void)handleAction:(id)sender {
//  NSLog(@"handle Action");
//  NSLog(@"target-action: %@", self.allTargets);
//}

@end
