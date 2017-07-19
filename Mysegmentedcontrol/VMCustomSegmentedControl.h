//
//  VMCustomSegmentedControl.h
//  Mysegmentedcontrol
//
//  Created by zsy on 2017/6/29.
//  Copyright © 2017年 zsy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VMCustomSegmentedControl;
@protocol VMCustomSegmentedControlDelegate <NSObject>
@optional
- (void)segementedControl:(VMCustomSegmentedControl *)control didMoveToItem:(NSInteger)index;
@end

typedef void(^DidMoveToItem)(VMCustomSegmentedControl *control, NSInteger index);
static CGFloat VMCustomSegmentedControlHeight = 32;

@interface VMCustomSegmentedControl : UIView

@property (nonatomic, strong) UIColor *moveViewColor;//!<默认 whiteColor
@property (nonatomic, strong) UIColor *selectColor;//!<默认 redColor
@property (nonatomic, strong) UIColor *normalColor;//!<默认 whiteColor
@property (nonatomic, weak) id<VMCustomSegmentedControlDelegate> delegate;
/**
 便利构造器

 @param items 标题数组
 @param width 每个item的宽
 @return <#return value description#>
 */
+ (VMCustomSegmentedControl *)segmentedControlForItems:(NSArray<NSString *> *)items widthForEachItem:(CGFloat)width;

/**
 init  每个item宽=frame.size.width / items.count

 @param frame <#frame description#>
 @param items <#items description#>
 @return <#return value description#>
 */
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray<NSString *> *)items;

/**
 block回调方式

 @param frame <#frame description#>
 @param items <#items description#>
 @param didMoveToItem <#didMoveToItem description#>
 @return <#return value description#>
 */
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray<NSString *> *)items didMoveToItem:(DidMoveToItem)didMoveToItem;
/**
 插入一个item 执行完毕会调用代理方法 - segementedControl: didMoveToItem: 一次

 @param title <#title description#>
 @param index <#index description#>
 */
- (void)insertItem:(NSString *)title atIndex:(NSInteger)index;

/**
 删除一个item 执行完毕会调用代理方法 - segementedControl: didMoveToItem: 一次

 @param index <#index description#>
 */
- (void)removeItemAtIndex:(NSInteger)index;

/**
 改变某个item标题

 @param title <#title description#>
 @param index <#index description#>
 */
- (void)setTitle:(NSString *)title forItemAtIndex:(NSInteger)index;
/**
 选中某个item
 
 @param index <#index description#>
 */
- (void)setSelectIndex:(NSInteger)index;
@end
