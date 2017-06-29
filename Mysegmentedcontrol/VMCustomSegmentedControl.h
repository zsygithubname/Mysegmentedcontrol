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


static CGFloat VMCustomSegmentedControlHeight = 32;
@interface VMCustomSegmentedControl : UIView

@property (nonatomic, strong) UIColor *moveViewColor;
@property (nonatomic, strong) UIColor *selectColor;
@property (nonatomic, strong) UIColor *normalColor;

@property (nonatomic, assign) BOOL delegateDidResponds;
@property (nonatomic, weak) id<VMCustomSegmentedControlDelegate> delegate;
/**
 便利构造器

 @param items 标题数组
 @param width 每个item的宽
 @return <#return value description#>
 */
+ (VMCustomSegmentedControl *)segmentedControlForItems:(NSArray<NSString *> *)items widthForEachItem:(CGFloat)width;

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
