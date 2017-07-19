//
//  ViewController.m
//  Mysegmentedcontrol
//
//  Created by zsy on 2017/6/29.
//  Copyright © 2017年 zsy. All rights reserved.
//

#import "ViewController.h"
#import "VMCustomSegmentedControl.h"
@interface ViewController ()<VMCustomSegmentedControlDelegate>
@property (nonatomic, strong) VMCustomSegmentedControl *control;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
    [add setTitle:@"增加一个" forState:UIControlStateNormal];
    [add setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    add.frame = CGRectMake(10, 80, 80, 22);
    [add addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:add];
    UIButton *remove = [UIButton buttonWithType:UIButtonTypeCustom];
    [remove setTitle:@"删掉一个" forState:UIControlStateNormal];
    [add setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    remove.frame = CGRectMake(120, 80, 80, 22);
    [remove addTarget:self action:@selector(removeAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:remove];
    
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *items = @[@"附近",@"发现",@"我的",@"他的"];
    
//    VMCustomSegmentedControl *control = [[VMCustomSegmentedControl alloc] initWithFrame:CGRectMake(20, 150, 200, VMCustomSegmentedControlHeight) items:items didMoveToItem:^(VMCustomSegmentedControl *control, NSInteger index) {
//        NSLog(@"%ld",index);
//    }];
    
    VMCustomSegmentedControl *control = [VMCustomSegmentedControl segmentedControlForItems:items widthForEachItem:50];
    _control = control;
    control.delegate = self;
    CGRect frame = control.frame;
    frame.origin.x = 20;
    frame.origin.y = 150;
    control.frame = frame;
    control.layer.cornerRadius = VMCustomSegmentedControlHeight / 2.0;
    control.layer.masksToBounds = YES;
    control.layer.borderColor = [UIColor whiteColor].CGColor;
    control.layer.borderWidth = 1;
    [self.view addSubview:control];
}

- (void)segementedControl:(VMCustomSegmentedControl *)control didMoveToItem:(NSInteger)index {
    NSLog(@"%ld",index);
}
- (void)addAction:(UIButton *)btn {
    [self.control insertItem:@"新增" atIndex:1];
}
- (void)removeAction:(UIButton *)btn {
    [self.control removeItemAtIndex:1];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
