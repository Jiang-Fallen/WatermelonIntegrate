//
//  ViewController.m
//  Compose
//
//  Created by Jiang on 2021/2/3.
//

#import "ViewController.h"
#import "JFDynamicItem.h"

@interface ViewController () <UICollisionBehaviorDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBeahvior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;

@property (nonatomic, weak) JFDynamicItem *lastTempItem;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWorld];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self generateCollisionInOriginal];
    });
}

- (void)initWorld{
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.contentView];
    // 初始化 gravity
    self.gravityBeahvior = [[UIGravityBehavior alloc] initWithItems:@[]];
    [self.animator addBehavior:self.gravityBeahvior];
    // 初始化 behavior
    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[]];
    self.collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    self.collisionBehavior.collisionDelegate = self;
    [self.animator addBehavior:self.collisionBehavior];
}

#pragma mark - generate
- (void)generateCollisionInOriginal{
    if ([self gameoverChecker]) return;
    NSInteger typeId = 7 - floor(log2f(arc4random()% 128));
    JFDynamicItem *view = [[JFDynamicItem alloc] initWithType:typeId];
    self.lastTempItem = view;
    
    [view setPositionX:self.contentView.layer.position.x];
    [self.contentView addSubview:view];
}

- (void)generateCollisionByHit:(JFDynamicItemType)type inPosition:(CGPoint)position{
    [self showIntegrateAnimateForType:type-1 position:position];
    
    JFDynamicItem *view = [[JFDynamicItem alloc] initWithType:type];
    [view setPosition:position];
    [self.contentView addSubview:view];
    [self.collisionBehavior addItem:view];
    [self.gravityBeahvior addItem:view];
}

- (void)generateCollisionByHit:(NSDictionary *)params{
    JFDynamicItemType type = [params[@"type"] integerValue];
    CGPoint point = [params[@"point"] CGPointValue];
    [self generateCollisionByHit:type inPosition:point];
}

#pragma mark - animate
- (void)showIntegrateAnimateForType:(JFDynamicItemType)type position:(CGPoint)position{
    UIImage *image = [UIImage imageNamed:_integrateImgs[type-1]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    CGFloat width = [_itemSizeArray[type] floatValue] * 1.5;
    imageView.frame = CGRectMake(position.x - width/2.0, position.y - width/1.5, width, width);
    [self.contentView insertSubview:imageView atIndex:0];
    [UIView animateWithDuration:0.25 animations:^{
        imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
}

#pragma mark - check
- (BOOL)gameoverChecker{
    for (UIView *view in self.contentView.subviews) {
        if (view != self.contentView.subviews.lastObject && view.frame.origin.y < 100) {
            [self gameover];
            return YES;
        }
    }
    return NO;
}

- (void)gameover{
    self.scoreLabel.text = @"0";
    self.playButton.hidden = NO;
    self.contentView.userInteractionEnabled = NO;
}

- (IBAction)playButtonAction:(id)sender {
    self.playButton.hidden = YES;
    for (JFDynamicItem *item in self.contentView.subviews) {
        [self removeItem:item];
    }
    [self generateCollisionInOriginal];
}

#pragma mark - foundation
- (CGFloat)getQualifiedX:(CGFloat)position_x width:(CGFloat)width{
    CGFloat originX = MIN(position_x, self.contentView.frame.size.width - width/2.0);
    originX = MAX(width/2.0, originX);
    return originX;
}

- (void)moveLastTempItemWithTouch:(UITouch *)touch{
    CGFloat positionX = [self getQualifiedX:[touch locationInView:self.contentView].x width:self.lastTempItem.width];
    [self.lastTempItem setPositionX:positionX];
}

- (void)updateScoreWithType:(JFDynamicItemType)type multiplet:(NSInteger)mult{
    NSInteger score = [_itemSizeArray[type - 1] integerValue];
    score = floor(score/20.0 * mult) + self.scoreLabel.text.integerValue;
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)score];
}

- (void)removeItem:(JFDynamicItem *)item{
    [self.collisionBehavior removeItem:item];
    [self.gravityBeahvior removeItem:item];
    [item removeFromSuperview];
}

#pragma mark - gesture
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self moveLastTempItemWithTouch:[touches anyObject]];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self moveLastTempItemWithTouch:[touches anyObject]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.lastTempItem) return;
    [self.collisionBehavior addItem:self.lastTempItem];
    [self.gravityBeahvior addItem:self.lastTempItem];
    [self updateScoreWithType:self.lastTempItem.type multiplet:1];
    self.lastTempItem = nil;
    [self performSelector:@selector(generateCollisionInOriginal) withObject:nil afterDelay:1];
}

#pragma mark - dynamic delegate
- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(JFDynamicItem *)item1 withItem:(JFDynamicItem *)item2 atPoint:(CGPoint)p{
    if (item1.type == item2.type){
        [self removeItem:item1];
        [self removeItem:item2];
        if (item1.type < JFDynamicItemWaterMelonInter) {
            // 增加延迟合并时间，避免失去多次连续合并时的效果
            [self updateScoreWithType:item1.type multiplet:3];
            JFDynamicItem *item = item1.center.y > item2.center.y? item1: item2;
            [self performSelector:@selector(generateCollisionByHit:) withObject:@{@"type": @(item1.type+1), @"point": @(item.center)} afterDelay:0.1];
        }else {
            [self updateScoreWithType:self.lastTempItem.type multiplet:10];
        }
    }
}

@end
