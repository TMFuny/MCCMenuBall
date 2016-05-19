//
//  MCCMenuBall.m
//  MCCMenuBall
//
//  Created by MrChens on 16/4/30.
//  Copyright © 2016年 TMFuny. All rights reserved.
//

#import "MCCMenuBall.h"

@interface MCCMenuBall ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *backGroundImageView;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGAffineTransform rotationTransform;
@property (nonatomic, assign) CGFloat ratioX;
@property (nonatomic, assign)CGFloat ratioY;

@end

static NSString * const kMCCMenuBallMomentaryPosition = @"com.chinanetcenter.uone.widget.menuball.momentaryPosition";

static const float kMCCMenuBallAlpha = 1.0f;
static const float kMCCMenuBallHidenAlpha = 0.0f;
static const float kMCCMenuBallAnimateDuration = 0.3f;

#define wspxUILog     (0) //0:open UILog 1:close UILog
#define wspxFuncTest  (0) //0:open funcTest 1:close funcTest
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
@implementation MCCMenuBall
#pragma mark - ViewLifeCycle
- (void)dealloc {
  [self unregisterForDeviceOrientationChangeNotification];
}
#pragma mark - UIInit

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image {
  self = [super initWithFrame:frame];
  if (self) {
    _draggable = YES;
    _momentary = YES;
    _adsorption = YES;
    _ratioX = self.center.x / [UIScreen mainScreen].bounds.size.width;
    _ratioY = self.center.y / [UIScreen mainScreen].bounds.size.height;
    
    _defaultPosition = CGPointMake(0, 0);
    _margin = UIEdgeInsetsMake(5, 5, 5, 5);
    _mTouchEdgeInsets = UIEdgeInsetsZero;
    _rotationTransform = CGAffineTransformIdentity;
    [self configBackGroundImageView:image];
    [self addDragGestureRecognizer];
    [self registerForDeviceOrientationChangeNotification];
    
  }
  return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
#pragma mark - UIConfig
- (void)configBackGroundImageView:(UIImage *)image {
  _backGroundImageView = [[UIImageView alloc] initWithImage:image];
  _radius = _backGroundImageView.image.size.width/2;
  [self addSubview:_backGroundImageView];
}
#pragma mark - UIUpdate
#pragma mark - AppleDataSource and Delegate
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  if (self.isHidden) {
    return nil;
  }
  CGRect expandedFrame = CGRectMake(0 - _mTouchEdgeInsets.left , 0 - _mTouchEdgeInsets.top , self.frame.size.width + (_mTouchEdgeInsets.left + _mTouchEdgeInsets.right) , self.frame.size.height + (_mTouchEdgeInsets.top + _mTouchEdgeInsets.bottom));
  return (CGRectContainsPoint(expandedFrame, point) == 1) ? self : nil;
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  if (self.isHidden) {
    return NO;
  }
  if (!_draggable) {
    return NO;
  }
  return YES;
}
#pragma mark - ThirdPartyDataSource and Delegate
#pragma mark - CustomDataSource and Delegate
#pragma mark - Target-Action Event
- (void)handleDragGesture:(UIPanGestureRecognizer *)dragGesture {
  CGPoint touchLocation = [dragGesture locationInView:self.superview];
  UIGestureRecognizerState state = dragGesture.state;
  
  switch (state) {
    case UIGestureRecognizerStateBegan:
    {
      
    }
      break;
    case UIGestureRecognizerStateChanged:
    {
      self.center = touchLocation;
    }
      break;
    case UIGestureRecognizerStateEnded:
    {
      if (_adsorption) {
        [self adjustFrameWithAnimate:NO];
      } else if (!CGRectContainsRect(self.superview.bounds, self.frame)) {
        [self adjustFrameWithAnimate:NO];
      }
    }
      break;
    case UIGestureRecognizerStateCancelled:
    {
      [self savePosition];
    }
      break;
    case UIGestureRecognizerStateFailed:
    {
      [self savePosition];
    }
      break;
    case UIGestureRecognizerStatePossible:
    {
      
    }
      break;
    default:
    {
      NSAssert(NO, @"Unknow UIGestureRecognizerState.");
    }
      break;
  }
}
#pragma mark - PublicMethod
- (void)show {
  self.hidden = NO;
  self.userInteractionEnabled = YES;
}

- (void)hidden {
  self.hidden = YES;
  self.userInteractionEnabled = NO;
}

- (void)setMomentary:(BOOL)momentary {
  _momentary = momentary;
  if (momentary) {
    if (!CGPointEqualToPoint([self getPosition], _defaultPosition)) {
      [self adjustCenter:[self getPosition]];
    }
  }
}
#pragma mark - PrivateMethod
- (void)savePosition {
  NSString *selfPosition = NSStringFromCGPoint(self.center);
#if  wspxUILog
  NSLog(@"savePosition:%@", selfPosition);
#endif
  [[NSUserDefaults standardUserDefaults] setObject:selfPosition forKey:kMCCMenuBallMomentaryPosition];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CGPoint)getPosition {
  NSString *positionString = [[NSUserDefaults standardUserDefaults] objectForKey:kMCCMenuBallMomentaryPosition];
  CGPoint position = CGPointFromString(positionString);
  if (CGPointEqualToPoint(position, CGPointZero)) {
    position = _defaultPosition;
  }
  return position;
}

- (void)adjustCenter:(CGPoint)center {
  self.center = center;
}

- (void)adjustFrameWithAnimate:(BOOL)animate {
  CGFloat radiu = _backGroundImageView.image.size.width/2;
  CGSize superViewSize = self.superview.bounds.size;
  UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
  if (UIDeviceOrientationIsLandscape(orientation)) {
    superViewSize.width = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    superViewSize.height = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
  }
  if (UIDeviceOrientationIsPortrait(orientation)) {
    superViewSize.width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    superViewSize.height = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
  }
  
  CGRect newFrame = self.frame;
  
  if (self.center.x < radiu) {
    newFrame.origin.x = 0 + _margin.left;
#if  wspxUILog
    NSLog(@"over left edge");
#endif
  }
  
  if (self.center.x>superViewSize.width-radiu) {
    newFrame.origin.x = superViewSize.width-2*radiu - _margin.right;
#if  wspxUILog
    NSLog(@"over right edge");
#endif
  }
  
  if (_adsorption) {
    CGPoint superViewCenter = self.superview.center;
    CGFloat trailingCriticalValue = superViewSize.width - radiu - _margin.right;
    CGFloat leadingCriticalValue = radiu + _margin.left;
    
    if (self.center.x > leadingCriticalValue && self.center.x < trailingCriticalValue) {
      
      CGFloat newX = self.center.x - superViewCenter.x>0?(superViewSize.width - 2*radiu - _margin.right):_margin.left;
      newFrame.origin.x = newX;
#if  wspxUILog
      NSLog(@"in the middle");
#endif
    }
  }
  
  if (self.center.y < radiu) {
    newFrame.origin.y = 0 + _margin.top;
#if  wspxUILog
    NSLog(@"over top edge");
#endif
  }
  
  if (self.center.y > superViewSize.height - radiu) {
    newFrame.origin.y = superViewSize.height - 2*radiu - _margin.bottom;
#if  wspxUILog
    NSLog(@"over bottom edge");
#endif
  }
  
  if (CGPointEqualToPoint(newFrame.origin, self.frame.origin)) {
    return;
  }
  
  if (animate) {
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:kMCCMenuBallAnimateDuration animations:^{
      self.alpha = kMCCMenuBallHidenAlpha;
    } completion:^(BOOL finished) {
      self.frame = newFrame;
      [weakSelf savePosition];
      [UIView animateWithDuration:kMCCMenuBallAnimateDuration animations:^{
        self.alpha = kMCCMenuBallAlpha;
      }];
    }];
    
    return;
  }
  self.frame = newFrame;
  [self savePosition];
}

- (void)setCenter:(CGPoint)center {
  [super setCenter:center];
  CGFloat width = [UIScreen mainScreen].bounds.size.width;
  CGFloat height = [UIScreen mainScreen].bounds.size.height;
  
  UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
  if (UIDeviceOrientationIsLandscape(orientation)) {
    width = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    height = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
  }
  if (UIDeviceOrientationIsPortrait(orientation)) {
    width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    height = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
  }
  
  _ratioX = self.center.x / width;
  _ratioY = self.center.y / height;
}

- (void)addDragGestureRecognizer {
  UIPanGestureRecognizer *dragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragGesture:)];
  [self addGestureRecognizer:dragGesture];
}

- (void)registerForDeviceOrientationChangeNotification {
#if !wspxFuncTest
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
#else
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logForDeviceOrientationchangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logForStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logForStatusBarFrameNotification:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
#endif
}

- (void)unregisterForDeviceOrientationChangeNotification {
#if !wspxFuncTest
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
#else
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
#endif
}

- (void)logForDeviceOrientationchangeNotification:(NSNotification *)notification {
  NSLog(@"%s ", __PRETTY_FUNCTION__);
  NSLog(@"------>");
  [self logForOrientation];
  NSLog(@"<------");
}
- (void)logForStatusBarOrientationNotification:(NSNotification *)notification {
  NSLog(@"%s ", __PRETTY_FUNCTION__);
  NSLog(@"------>");
  [self logForOrientation];
  NSLog(@"<------");
}
- (void)logForStatusBarFrameNotification:(NSNotification *)notification {
  NSLog(@"%s ", __PRETTY_FUNCTION__);
  NSLog(@"------>");
  [self logForOrientation];
  NSLog(@"<------");
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
  if (self.isHidden) {
    return;
  }
  UIView *superview = self.superview;
  if (!superview) {
    return;
  } else {
    
    [self logForOrientation];
#if wspxUILog
    NSLog(@"center beforeChange: %@" , NSStringFromCGPoint(self.center));
    NSLog(@"---------->\n sFrame:%@ sBounds:%@ \n mBounds:%@ \nwFrame:%@ wBounds:%@ \n frame:%@ bounds:%@ \n%s\n<---------", NSStringFromCGRect(self.superview.frame), NSStringFromCGRect(self.superview.bounds),
          NSStringFromCGRect([UIScreen mainScreen].bounds),
          NSStringFromCGRect([UIApplication sharedApplication].keyWindow.frame), NSStringFromCGRect([UIApplication sharedApplication].keyWindow.bounds),
          NSStringFromCGRect(self.frame), NSStringFromCGRect(self.bounds), __PRETTY_FUNCTION__);
#endif
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(orientation)) {
      width = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
      height = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    if (UIDeviceOrientationIsPortrait(orientation)) {
      width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
      height = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    
    CGPoint newCenter = CGPointMake(_ratioX*width, _ratioY*height);
    self.center = newCenter;
#if wspxUILog
    NSLog(@"@@@@@@@@@@@@@@@@@");
    NSLog(@"Width:%lf Height:%lf", width, height);
    NSLog(@"ratioX:%lf ratioY:%lf", _ratioX, _ratioY);
    NSLog(@"center afterChange: %@" , NSStringFromCGPoint(self.center));
    NSLog(@"Width:%lf Height:%lf", width, height);
    NSLog(@"ratioX:%lf ratioY:%lf", _ratioX, _ratioY);
    NSLog(@"@@@@@@@@@@@@@@@@@");
#endif
    if (_adsorption) {
      [self adjustFrameWithAnimate:NO];
    }
    if (!CGRectContainsRect(self.superview.bounds, self.frame)) {
      [self adjustFrameWithAnimate:YES];
    }
    NSLog(@"center destion: %@" , NSStringFromCGPoint(self.center));
  }
}

- (void)logForOrientation {
  
  NSLog(@"sFrame:%@ sBounds:%@ sCenter:%@\n frame:%@ bounds:%@ %s", NSStringFromCGRect(self.superview.frame), NSStringFromCGRect(self.superview.bounds), NSStringFromCGPoint(self.superview.center), NSStringFromCGRect(self.frame), NSStringFromCGRect(self.bounds), __PRETTY_FUNCTION__);
  UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
  switch (orientation) {
    case UIDeviceOrientationUnknown:
    {
      
    }
      break;
    case UIDeviceOrientationPortrait:
    {
      NSLog(@"home button on the bottom");
    }
      break;
    case UIDeviceOrientationLandscapeRight:
    {
      NSLog(@"home button on the left");
    }
      break;
    case UIDeviceOrientationLandscapeLeft:
    {
      NSLog(@"home button on the right");
    }
      break;
    case UIDeviceOrientationPortraitUpsideDown:
    {
      NSLog(@"home button on the top");
    }
      break;
    case UIDeviceOrientationFaceUp:
    {
      NSLog(@"face up");
    }
      break;
    case UIDeviceOrientationFaceDown:
    {
      NSLog(@"face down");
    }
      break;
    default:
    {
      NSLog(@"Are U kidd me?");
    }
      break;
  }
}
//- (void)saveMomentaryRatio {
//  NSString *ratio = NSStringFromCGPoint(CGPointMake(_ratioX, _ratioY));
//  [[NSUserDefaults standardUserDefaults] setObject:ratio forKey:kWSPXMenuBallMomentaryRatio];
//  [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//- (CGPoint)getMomentaryRatio {
//  NSString *ratioString = [[NSUserDefaults standardUserDefaults] objectForKey:kWSPXMenuBallMomentaryRatio];
//  CGPoint ratio = CGPointFromString(ratioString);
//  return ratio;
//}
@end
