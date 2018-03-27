//
//  ViewController.m
//  TestUnite
//
//  Created by mmstrong on 2018/3/9.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
NSInteger ticketSurplusCount;
}
@property (nonatomic,strong)NSLock *lock;
@end
@implementation ViewController
#pragma mark - life cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    //NSInvocationOperation 对象
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 5;
   NSBlockOperation *operation = [NSBlockOperation  blockOperationWithBlock:^{
       for (int i = 0; i < 5; i++) {
        // 模拟耗时操作
            NSLog(@"4%@^^%i",[NSThread currentThread],i); // 打印当前线程
       }
       }];
    //[operation waitUntilFinished];
    NSBlockOperation *operaOne = [NSBlockOperation  blockOperationWithBlock:^{
        NSLog(@"5%@",[NSThread currentThread]);
    }];
    [operaOne addDependency:operation];
    [queue addOperation:operation];
    [queue addOperation:operaOne];
    [queue addOperationWithBlock:^{
        NSLog(@"1%@",[NSThread currentThread]);
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"2%@",[NSThread currentThread]);
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"3%@",[NSThread currentThread]);
    }];
    [queue waitUntilAllOperationsAreFinished];
    NSLog(@"123");
    [self initTicketStatusNotSave];
}

#pragma mark - response Events
/**
 * 非线程安全：不使用 NSLock
 * 初始化火车票数量、卖票窗口(非线程安全)、并开始卖票
 */
- (void)initTicketStatusNotSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]); // 打印当前线程
    
    ticketSurplusCount = 50;
    
    // 1.创建 queue1,queue1 代表北京火车票售卖窗口
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;
    
    // 2.创建 queue2,queue2 代表上海火车票售卖窗口
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;
    
    // 3.创建卖票操作 op1
    __weak typeof(self) weakSelf = self;
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketNotSafe];
    }];
    
    // 4.创建卖票操作 op2
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketNotSafe];
    }];
    
    // 5.添加操作，开始卖票
    [queue1 addOperation:op1];
    [queue2 addOperation:op2];
}

/**
 * 售卖火车票(非线程安全)
 */
- (void)saleTicketNotSafe {
    NSLog(@"123");
    while (1) {
        
        // 加锁
        [self.lock lock];
        
        if (ticketSurplusCount > 0) {
            //如果还有票，继续售卖
            ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%ld 窗口:%@", (long)ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }
        
        // 解锁
        [self.lock unlock];
        
        if (ticketSurplusCount <= 0) {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}
#pragma mark - getter and setter
- (NSLock*)lock{
    if (!_lock) {
        _lock = [[NSLock alloc]init];
    }
    return _lock;
}
@end
