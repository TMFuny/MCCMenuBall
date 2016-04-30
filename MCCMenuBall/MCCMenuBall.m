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
    _ratioX = self.center.x / [UIScreen mainScreen].bounds.size.width;
    _ratioY = self.center.y / [UIScreen mainScreen].bounds.size.height;
    
    _defaultPosition = CGPointMake(0, 0);
    _margin = UIEdgeInsetsMake(5, 5, 5, 5);
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

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
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
      if (!CGRectContainsRect(self.superview.bounds, self.frame)) {
        [self adjustFrameWithAnimate:NO];
      }
      [self savePosition];
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
  CGRect newFrame = self.frame;
  
  if (self.center.x < radiu) {
    newFrame.origin.x = 0 + _margin.left;
  }
  if (self.center.x>superViewSize.width-radiu) {
    newFrame.origin.x = superViewSize.width-2*radiu - _margin.right;
  }
  if (self.center.y < radiu) {
    newFrame.origin.y = 0 + _margin.top;
  }
  if (self.center.y > superViewSize.height - radiu) {
    newFrame.origin.y = superViewSize.height - 2*radiu - _margin.bottom;
  }
  if (animate) {
    
    [UIView animateWithDuration:kMCCMenuBallAnimateDuration animations:^{
      self.alpha = kMCCMenuBallHidenAlpha;
    } completion:^(BOOL finished) {
      self.frame = newFrame;
      [UIView animateWithDuration:kMCCMenuBallAnimateDuration animations:^{
        self.alpha = kMCCMenuBallAlpha;
      }];
    }];
    return;
  }
  self.frame = newFrame;
}

- (void)setCenter:(CGPoint)center {
  [super setCenter:center];
  _ratioX = self.center.x / [UIScreen mainScreen].bounds.size.width;
  _ratioY = self.center.y / [UIScreen mainScreen].bounds.size.height;
}

- (void)addDragGestureRecognizer {
  UIPanGestureRecognizer *dragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragGesture:)];
  [self addGestureRecognizer:dragGesture];
}

- (void)registerForDeviceOrientationChangeNotification {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)unregisterForDeviceOrientationChangeNotification {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
  UIView *superview = self.superview;
  if (!superview) {
    return;
  } else {
    NSLog(@"%s, OrientationChanged", __PRETTY_FUNCTION__);
    CGPoint newCenter = CGPointMake(_ratioX*[UIScreen mainScreen].bounds.size.width, _ratioY*[UIScreen mainScreen].bounds.size.height);
    self.center = newCenter;
    if (!CGRectContainsRect(self.superview.bounds, self.frame)) {
      [self adjustFrameWithAnimate:YES];
    }
  }
}
//- (void)saveMomentaryRatio {
//  NSString *ratio = NSStringFromCGPoint(CGPointMake(_ratioX, _ratioY));
//  [[NSUserDefaults standardUserDefaults] setObject:ratio forKey:kMCCMenuBallMomentaryRatio];
//  [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//- (CGPoint)getMomentaryRatio {
//  NSString *ratioString = [[NSUserDefaults standardUserDefaults] objectForKey:kMCCMenuBallMomentaryRatio];
//  CGPoint ratio = CGPointFromString(ratioString);
//  return ratio;
//}

@end
