//
//  DynamicItem.m
//  Compose
//
//  Created by Jiang on 2021/2/3.
//

#import "JFDynamicItem.h"

@interface JFDynamicItem ()

@end

NSArray *_imgNames;
NSArray *_itemSizeArray;
NSArray *_integrateImgs;
@implementation JFDynamicItem

+ (void)initialize{
    _imgNames = @[@"mangosteen", @"cherry", @"orange", @"lemon", @"kiwi", @"tomato", @"peach", @"coconut", @"watermelon", @"watermelonInter"];
    _itemSizeArray = @[@30, @50, @70, @80, @100, @120, @140, @160, @200, @200];
    _integrateImgs = @[@"juicepurple", @"juicepink", @"juiceorange", @"juiceyellow", @"juicegreen", @"juicepink", @"juiceyellow", @"juicewhite", @"juicepink", @"juicepink"];
}

#pragma mark - system call
- (UIDynamicItemCollisionBoundsType)collisionBoundsType{
    return UIDynamicItemCollisionBoundsTypeEllipse;
}

#pragma mark - initialize
- (instancetype)initWithType:(JFDynamicItemType)type
{
    self = [super init];
    if (self) {
        self.type = type;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews{
    if (self.type == JFDynamicItemNone || self.type > _imgNames.count){
        self.type = JFDynamicItemMangosteen;
    }
    self.clipsToBounds = YES;
    CGFloat width = [_itemSizeArray[self.type-1] floatValue];
    self.frame = CGRectMake(0, 0, width, width);
    self.layer.cornerRadius = width/2.0;
    self.image = [UIImage imageNamed:_imgNames[self.type-1]];
}

#pragma mark - foundation

- (CGFloat)width{
    return self.bounds.size.width;
}

- (void)setOrigin:(CGPoint)origin{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)setPosition:(CGPoint)position{
    CGRect frame = self.frame;
    frame.origin = CGPointMake(position.x - self.width/2.0, position.y - self.width/2.0);
    self.frame = frame;
}

- (void)setPositionX:(CGFloat)positionX{
    CGRect frame = self.frame;
    frame.origin.x = positionX - self.width/2.0;
    self.frame = frame;
}

@end
