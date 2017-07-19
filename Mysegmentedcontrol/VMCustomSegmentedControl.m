//
//  VMCustomSegmentedControl.m
//  Mysegmentedcontrol
//
//  Created by zsy on 2017/6/29.
//  Copyright © 2017年 zsy. All rights reserved.
//

#import "VMCustomSegmentedControl.h"

typedef NS_ENUM(NSInteger, MoveDirection) {
    MoveDirectionRight,
    MoveDirectionLeft
};
@interface VMCustomSegmentedControl ()
@property (nonatomic, strong) NSMutableArray<NSString *> *items;
@property (nonatomic, assign) CGFloat eachItemWidth;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *moveView;
@property (nonatomic, strong) NSMutableArray<UIButton *> *normalBtns;
@property (nonatomic, strong) NSMutableArray<UIButton *> *selectBtns;
@property (nonatomic, assign) BOOL delegateDidResponds;

@property (nonatomic, assign) MoveDirection direction;
@property (nonatomic, assign) NSInteger currentSelectIndex;
@property (nonatomic, copy) DidMoveToItem didMoveToItem;
@end
@implementation VMCustomSegmentedControl

#pragma mark - init
+ (VMCustomSegmentedControl *)segmentedControlForItems:(NSArray<NSString *> *)items widthForEachItem:(CGFloat)width {
    if (!items.count || width <= 0) {
        return nil;
    }
    CGRect frame = CGRectMake(0, 0, items.count * width, VMCustomSegmentedControlHeight);
    VMCustomSegmentedControl *control = [[self alloc] initWithFrame:frame items:items];
    return control;
}
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray<NSString *> *)items {
    if (self = [super initWithFrame:frame]) {
        [self.items addObjectsFromArray:items];
        _eachItemWidth = frame.size.width / items.count;
        _moveViewColor = [UIColor whiteColor];
        _normalColor = [UIColor whiteColor];
        _selectColor = [UIColor redColor];
        [self creatControlSubviews];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray<NSString *> *)items didMoveToItem:(DidMoveToItem)didMoveToItem {
    if ([self initWithFrame:frame items:items]) {
        self.didMoveToItem = didMoveToItem;
    }
    return self;
}
- (void)creatControlSubviews {
    for (int i = 0; i < self.items.count; i++) {
        UIButton *button = [self buttonForControlByTitle:self.items[i] titleColor:_normalColor];
        button.frame = CGRectMake(i * self.eachItemWidth, 0, self.eachItemWidth, VMCustomSegmentedControlHeight);
        [button addTarget:self action:@selector(controlItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.normalBtns addObject:button];
        [self addSubview:button];
    }
    _moveView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.eachItemWidth, VMCustomSegmentedControlHeight)];
    _moveView.backgroundColor = self.moveViewColor;
    _moveView.clipsToBounds = YES;
    _moveView.layer.cornerRadius = VMCustomSegmentedControlHeight / 2.0;
    _moveView.layer.masksToBounds = YES;
    [self addSubview:_moveView];
    _topView = [[UIView alloc] initWithFrame:self.bounds];
    for (int i = 0; i < self.items.count; i++) {
        UIButton *button = [self buttonForControlByTitle:self.items[i] titleColor:_selectColor];
        button.frame = CGRectMake(i * self.eachItemWidth, 0, self.eachItemWidth, VMCustomSegmentedControlHeight);
        [self.selectBtns addObject:button];
        [_topView addSubview:button];
    }
    [_moveView addSubview:_topView];
    
    //pan手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [_moveView addGestureRecognizer:pan];
}

/**
 工厂

 @param title <#title description#>
 @param titleColor <#titleColor description#>
 @return <#return value description#>
 */
- (UIButton *)buttonForControlByTitle:(NSString *)title titleColor:(UIColor *)titleColor {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    return button;
}
#pragma mark - action
- (void)controlItemAction:(UIButton *)button {
    CGPoint moveViewCenter = self.moveView.center;
    if (CGPointEqualToPoint(moveViewCenter, button.center)) {
        return;
    }
    CGPoint topViewCenter = self.topView.center;
    topViewCenter.x -= (button.center.x - moveViewCenter.x);
    [UIView animateWithDuration:0.2 animations:^{
        self.moveView.center = button.center;
        self.topView.center = topViewCenter;
    } completion:^(BOOL finished) {
        NSInteger index = [self.normalBtns indexOfObject:button];
        [self delegateDoSomthing:index];
    }];
}
- (void)panAction:(UIPanGestureRecognizer *)pan {
    CGPoint moveViewCenter = self.moveView.center;
    CGPoint topViewCenter = self.topView.center;
    if (pan.state == UIGestureRecognizerStateEnded) {
        for (UIButton *btn in self.normalBtns) {
            //找到差值小于等于item宽 1/2的(即距离滑动的view.center最近的按钮) 就是松手后要停留的按钮 (有个小问题,如果正好移动到两个item的中间 就会有两个差值最小的btn 但是总是去停留在第一个遍历到的,可以根据移动方向再优化下,向右移动就正向遍历,向左移动就倒序遍历)
            CGFloat difference = fabs(moveViewCenter.x - btn.center.x);
            if (difference <= self.eachItemWidth / 2.0) {
                topViewCenter.x -= (btn.center.x - moveViewCenter.x);
                [UIView animateWithDuration:0.1 animations:^{
                    self.moveView.center = btn.center;
                    self.topView.center = topViewCenter;
                } completion:^(BOOL finished) {
                    NSInteger index = [self.normalBtns indexOfObject:btn];
                    [self delegateDoSomthing:index];
                }];
                return;
            }
        }
    }else {
        CGPoint currentPoint = [pan translationInView:pan.view];
        //判断滑动方向
        if (currentPoint.x > 0) {
            _direction = MoveDirectionRight;
        }else {
            _direction = MoveDirectionLeft;
        }
        moveViewCenter.x += currentPoint.x;
        topViewCenter.x -= currentPoint.x;
        //防止超出边界
        if (moveViewCenter.x >= self.eachItemWidth / 2 && moveViewCenter.x <= self.bounds.size.width - (self.eachItemWidth / 2)) {
            self.moveView.center = moveViewCenter;
            self.topView.center = topViewCenter;
            [pan setTranslation:CGPointZero inView:pan.view];
        }
    }
}
- (void)delegateDoSomthing:(NSInteger)index {
    //不必每次去判断是否响应
    self.currentSelectIndex = index;
    if (self.delegateDidResponds) {
        [self.delegate segementedControl:self didMoveToItem:index];
    }else {
        if ([self.delegate respondsToSelector:@selector(segementedControl:didMoveToItem:)]) {
            self.delegateDidResponds = YES;
            [self.delegate segementedControl:self didMoveToItem:index];
        }
    }
    
    //block回调
    if (self.didMoveToItem) {
        self.didMoveToItem(self, index);
    }
}

#pragma - mark public method
- (void)insertItem:(NSString *)title atIndex:(NSInteger)index {
    if (index > self.items.count) {
        return;
    }
    self.currentSelectIndex = self.currentSelectIndex >= index ? self.currentSelectIndex + 1 : self.currentSelectIndex;
    [self.items insertObject:title atIndex:index];
    CGRect frameSelf = self.frame;
    frameSelf.size.width += self.eachItemWidth;
    self.frame = frameSelf;
    CGRect frameTopView = self.topView.frame;
    frameTopView.size.width += self.eachItemWidth;
    self.topView.frame = frameTopView;
    //改变index之后的btn的frame
    for (NSInteger i = index; i < self.normalBtns.count; i++) {
        UIButton *normalBtn = self.normalBtns[i];
        CGRect normalFrame = normalBtn.frame;
        normalFrame.origin.x += self.eachItemWidth;
        normalBtn.frame = normalFrame;
        
        UIButton *selectBtn = self.selectBtns[i];
        CGRect selectFrame = selectBtn.frame;
        selectFrame.origin.x += self.eachItemWidth;
        selectBtn.frame = selectFrame;
    }
    UIButton *newNormalBtn = [self buttonForControlByTitle:title titleColor:_normalColor];
    newNormalBtn.frame = CGRectMake(index * self.eachItemWidth, 0, self.eachItemWidth, VMCustomSegmentedControlHeight);
    [newNormalBtn addTarget:self action:@selector(controlItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.normalBtns insertObject:newNormalBtn atIndex:index];
    [self insertSubview:newNormalBtn belowSubview:self.moveView];
    
    UIButton *newSelectBtn = [self buttonForControlByTitle:title titleColor:_selectColor];
    newSelectBtn.frame = CGRectMake(index * self.eachItemWidth, 0, self.eachItemWidth, VMCustomSegmentedControlHeight);
    [self.selectBtns insertObject:newSelectBtn atIndex:index];
    [self.topView addSubview:newSelectBtn];
    
    __weak typeof(self) weakSelf = self;
    [self setSelectIndex:self.currentSelectIndex completion:^{
        [weakSelf delegateDoSomthing:weakSelf.currentSelectIndex];
    }];
}
- (void)removeItemAtIndex:(NSInteger)index {
    if (index >= self.items.count) {
        return;
    }
    if (self.currentSelectIndex == index) {
        self.currentSelectIndex = 0;
    }else {
        self.currentSelectIndex = self.currentSelectIndex < index ? self.currentSelectIndex : self.currentSelectIndex - 1;
    }
    [self.items removeObjectAtIndex:index];
    CGRect frameSelf = self.frame;
    frameSelf.size.width -= self.eachItemWidth;
    self.frame = frameSelf;
    CGRect frameTopView = self.topView.frame;
    frameTopView.size.width -= self.eachItemWidth;
    self.topView.frame = frameTopView;
   
    for (NSInteger i = index; i < self.normalBtns.count; i++) {
        UIButton *normalBtn = self.normalBtns[i];
        UIButton *selectBtn = self.selectBtns[i];
        if (i == index) {
            [normalBtn removeFromSuperview];
            [selectBtn removeFromSuperview];
        }else {
            CGRect normalFrame = normalBtn.frame;
            normalFrame.origin.x -= self.eachItemWidth;
            normalBtn.frame = normalFrame;
            
            CGRect selectFrame = selectBtn.frame;
            selectFrame.origin.x -= self.eachItemWidth;
            selectBtn.frame = selectFrame;
        }
    }
    [self.normalBtns removeObjectAtIndex:index];
    [self.selectBtns removeObjectAtIndex:index];
    __weak typeof(self) weakSelf = self;
    [self setSelectIndex:self.currentSelectIndex completion:^{
        [weakSelf delegateDoSomthing:weakSelf.currentSelectIndex];
    }];
}
- (void)setTitle:(NSString *)title forItemAtIndex:(NSInteger)index {
    if (index >= self.items.count) {
        return;
    }
    UIButton *normalBtn = [self.normalBtns objectAtIndex:index];
    [normalBtn setTitle:title forState:UIControlStateNormal];
    UIButton *selectBtn = [self.selectBtns objectAtIndex:index];
    [selectBtn setTitle:title forState:UIControlStateNormal];
}
- (void)setSelectIndex:(NSInteger)index {
    [self setSelectIndex:index completion:nil];
}
- (void)setSelectIndex:(NSInteger)index completion:(void(^)())completion {
    if (index >= self.items.count) {
        return;
    }
    self.currentSelectIndex = index;
    UIButton *button = [self.normalBtns objectAtIndex:index];
    CGPoint moveViewCenter = self.moveView.center;
    CGPoint topViewCenter = self.topView.center;
    topViewCenter.x -= (button.center.x - moveViewCenter.x);
    [UIView animateWithDuration:0.2 animations:^{
        self.moveView.center = button.center;
        self.topView.center = topViewCenter;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}
#pragma - mark getter
- (NSMutableArray<NSString *> *)items {
    if (!_items) {
        _items = [NSMutableArray arrayWithCapacity:1];
    }
    return _items;
}
- (NSMutableArray<UIButton *> *)normalBtns {
    if (!_normalBtns) {
        _normalBtns = [NSMutableArray arrayWithCapacity:self.items.count];
    }
    return _normalBtns;
}
- (NSMutableArray<UIButton *> *)selectBtns {
    if (!_selectBtns) {
        _selectBtns = [NSMutableArray arrayWithCapacity:self.items.count];
    }
    return _selectBtns;
}
#pragma mark - setter
- (void)setMoveViewColor:(UIColor *)moveViewColor {
    _moveViewColor = moveViewColor;
    self.moveView.backgroundColor = moveViewColor;
}
- (void)setNormalColor:(UIColor *)normalColor {
    _normalColor = normalColor;
    for (UIButton *btn in self.normalBtns) {
        [btn setTitleColor:normalColor forState:UIControlStateNormal];
    }
}
- (void)setSelectColor:(UIColor *)selectColor {
    _selectColor = selectColor;
    for (UIButton *btn in self.selectBtns) {
        [btn setTitleColor:selectColor forState:UIControlStateNormal];
    }
}
@end
