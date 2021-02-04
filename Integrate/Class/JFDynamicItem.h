//
//  DynamicItem.h
//  Compose
//
//  Created by Jiang on 2021/2/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JFDynamicItemType){
    JFDynamicItemNone = 0,
    JFDynamicItemMangosteen,
    JFDynamicItemCherry,
    JFDynamicItemOrange,
    JFDynamicItemLemon,
    JFDynamicItemKiwi,
    JFDynamicItemTomato,
    JFDynamicItemPeach,
    JFDynamicItemCoconut,
    JFDynamicItemWaterMelon,
    JFDynamicItemWaterMelonInter,
};

extern NSArray *_integrateImgs;
extern NSArray *_itemSizeArray;

@interface JFDynamicItem : UIImageView

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) JFDynamicItemType type;

- (instancetype)initWithType:(JFDynamicItemType)type;

- (void)setOrigin:(CGPoint)origin;
- (void)setPosition:(CGPoint)position;
- (void)setPositionX:(CGFloat)positionX;

@end

NS_ASSUME_NONNULL_END
