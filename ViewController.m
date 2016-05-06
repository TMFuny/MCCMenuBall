//
//  ViewController.m
//  MCCMenuBall
//
//  Created by MrChens on 16/4/30.
//  Copyright © 2016年 TMFuny. All rights reserved.
//

#import "ViewController.h"
#import "SCNewtonsCradleView.h"
#import "MCCMenuBall.h"
#import "MCCMonitorBall.h"

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UICollisionBehaviorDelegate>
@property (nonatomic, strong)UIView *square;
@property (nonatomic, strong)UIDynamicAnimator *animator;
@property (nonatomic, strong)UIGravityBehavior *gravity;
@property (nonatomic, strong)UICollisionBehavior *collision;
@property (nonatomic, strong)UIView *barrier;
@property (nonatomic, assign)BOOL firstContact;
@property (nonatomic, strong)UIPushBehavior *userDragBehavior;
@property (nonatomic, strong)SCNewtonsCradleView *newtonsCradle;
@end

@implementation ViewController {
  MCCMonitorBall *_monitorBall;
  MCCMenuBall    *_menuBall;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blueColor];
  //  _newtonsCradle = [[SCNewtonsCradleView alloc] initWithFrame:self.view.bounds];
  //  [self.view addSubview:_newtonsCradle];
//  [self showDynamic1];
//  [self initMonitorBall];
  [self initMenuBall];
  // Do any additional setup after loading the view, typically from a nib.
}
- (void)initMenuBall {
  _menuBall = [[MCCMenuBall alloc] initWithFrame:CGRectMake(kScreenWidth-12-40, kScreenHeight-67-40, 40, 40) image:[UIImage imageNamed:@"wv_fullScreen"]];
  _menuBall.momentary = NO;
  [_menuBall addTarget:self action:@selector(onTouchMenuBall:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:_menuBall];
}

- (void) initMonitorBall {

  _monitorBall = [[MCCMonitorBall alloc] initWithTitle:@"This is a test string"];
  _monitorBall.leading = 5;
  _monitorBall.trailing = 30;
  [self.view addSubview:_monitorBall];
  _monitorBall.translatesAutoresizingMaskIntoConstraints = NO;
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_monitorBall
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1 constant:0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_monitorBall
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1 constant:23]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_monitorBall
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1 constant:-60]];

  
  [_monitorBall addTarget:self action:@selector(onTouchMonitorBall:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onTouchMonitorBall:(MCCMonitorBall *)monitorBall {
  NSLog(@"touch MonitorBall");
}

- (void)onTouchMenuBall:(MCCMenuBall *)menuBall {
  NSLog(@"touch MenuBall");
}
- (void)showDynamic1 {
  [self addSquareView];
  //  [self addBarrierView];
  [self addAnimator];
  [self addGravity];
  [self addCollision];
  [self addDynamicItem];
}

- (void)addSquareView {
  _square = [[UIView alloc] initWithFrame:CGRectMake(100, 20, 50, 50)];
  _square.backgroundColor = [UIColor greenColor];
  UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
  [_square addGestureRecognizer:panGesture];
  [self.view addSubview:_square];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
  UIGestureRecognizerState state = pan.state;
  CGPoint location = [pan locationInView:self.view];
  switch (state) {
    case UIGestureRecognizerStateChanged:
    {
      
      _square.center = location;
    }
      break;
    case UIGestureRecognizerStateEnded:
    {
      _square.center = [pan locationInView:self.view];
      if (_square.center.x<=25) {
        _square.center = CGPointMake(25, [pan locationInView:self.view].y);
      }
    }
      break;
      
    default:
      break;
  }
}

- (void)addBarrierView {
  _barrier = [[UIView alloc] initWithFrame:CGRectMake(0, 230, 105, 10)];
  _barrier.backgroundColor = [UIColor yellowColor];
  [self.view addSubview:_barrier];
}
- (void)addDynamicItem {
  UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[_square]];
  itemBehaviour.elasticity = 0;//弹力
  itemBehaviour.friction = 0;//摩擦力
  itemBehaviour.resistance = 0;//粘滞阻尼
  itemBehaviour.angularResistance = 0;//角速度阻尼
  itemBehaviour.density = 0;//密度
  itemBehaviour.allowsRotation = YES;
  [_animator addBehavior:itemBehaviour];
}
- (void)addAnimator {
  _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
  
}

- (void)addGravity {
  _gravity = [[UIGravityBehavior alloc] initWithItems:@[_square]];
  [_animator addBehavior:_gravity];
}

- (void)addCollision {
  _collision = [[UICollisionBehavior alloc] initWithItems:@[_square]];
  _collision.translatesReferenceBoundsIntoBoundary = YES;
  _collision.collisionDelegate = self;
  CGPoint rightEdge = CGPointMake(_barrier.frame.origin.x+_barrier.frame.size.width, _barrier.frame.origin.y);
  __weak __typeof(self) weakSelf = self;
  [_collision addBoundaryWithIdentifier:@"collisionBarrier" fromPoint:_barrier.frame.origin toPoint:rightEdge];
  _collision.action = ^{
    NSLog(@"%@, %@", NSStringFromCGAffineTransform(weakSelf.square.transform), NSStringFromCGPoint(weakSelf.square.center));
  };
  [_animator addBehavior:_collision];
}
#pragma mark - ViewLifeCycle
#pragma mark - UIInit
#pragma mark - UIConfig
#pragma mark - UIUpdate
#pragma mark - AppleDataSource and Delegate
- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {
  UIView *view = (UIView*)item;
  view.backgroundColor = [UIColor yellowColor];
  [UIView animateWithDuration:0.3 animations:^{
    view.backgroundColor = [UIColor grayColor];
  }];
  
  if (!_firstContact) {
    _firstContact = YES;
    
    //    UIView *square = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    //    square.backgroundColor = [UIColor grayColor];
    //    [self.view addSubview:square];
    
    //    [_collision addItem:square];
    //    [_gravity addItem:square];
    
    //    UIAttachmentBehavior *attach = [[UIAttachmentBehavior alloc] initWithItem:view attachedToItem:square];
    //    [_animator addBehavior:attach];
  }
  /*
   NSLog(@"Boundary contact occurred - %@", identifier);
   UIView *view = (UIView*)item;
   view.backgroundColor = [UIColor yellowColor];
   [UIView animateWithDuration:0.3 animations:^{
   view.backgroundColor = [UIColor grayColor];
   }];*/
}
#pragma mark - ThirdPartyDataSource and Delegate
#pragma mark - CustomDataSource and Delegate
#pragma mark - Target-Action Event
#pragma mark - PublicMethod
#pragma mark - PrivateMethod

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
