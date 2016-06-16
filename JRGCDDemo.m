//
//  JRGCDDemo.m
//  JRKit
//
//  Created by lujianrong on 16/5/30.
//  Copyright © 2016年 lujianrong. All rights reserved.
//

#import "JRGCDDemo.h"

@implementation JRGCDDemo
/**
 *  我们在并发队列中添加了三个任务，其中任务1是直接执行，任务2是在异步执行过程中被睡眠2秒，任务3在异步执行过程中被睡眠1秒，结果任务3先于任务2执行完成。说明并发执行任务并不需要等待其他任务先执行完。对于这三个任务，是互不干扰的！
 */
+ (void)get_global_queue_test {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"global 1");
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 睡眠2秒
        sleep(2);
        NSLog(@"global 2");
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 睡眠3秒
        sleep(1);
        NSLog(@"global 3");
    });
}
/**
 *  从打印结果可看到执行的顺序是按入队的顺序来执行的。虽然让任务1睡眠2秒再执行，其他任务也只能等待任务1完成，才能继承执行任务2，在任务2执行完成，才能执行任务3。
 
 从打印结果可以看到线程号是固定的，说明都在同一个线程中执行，而这个线程就是主线程。任务只能一个一个地执行。
 */
+ (void)get_main_queue_test {
    dispatch_async(dispatch_get_main_queue(), ^{
        sleep(2);
        NSLog(@"main 1");
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"main 2");
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        sleep(1);
        NSLog(@"main 3");
    });
}
/**
 *  从打印结果可以看出来，任务全在同一个线程中执行，但是并不是在主线程，而是在子线程执行。不过任务执行只有顺序地执行，任务没有执行完毕之前，下一个任务是不能开始的。
 */
+ (void)queue_serial_test {
    dispatch_queue_t serialQueue = dispatch_queue_create("jr.serial-queue", DISPATCH_QUEUE_SERIAL);
    
        dispatch_async(serialQueue, ^{
        NSLog(@"serial 1");
    });
    dispatch_async(serialQueue, ^{
        sleep(2);
        NSLog(@"serial 2");
    });
    dispatch_async(serialQueue, ^{
        sleep(1);
        NSLog(@"serial 3");
    });
}
/**
 *  从打印结果可以看出来，任务在三个子线程中执行，且互不干扰，不需要等待其他任务完成，就可以并发地分别去执行！
 */
+ (void)queue_concurrent_test {
    dispatch_queue_t concurrencyQueue = dispatch_queue_create("jr.concurrency-queue",DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(concurrencyQueue, ^{
        NSLog(@"concurrent 1");
    });
    dispatch_async(concurrencyQueue, ^{
        sleep(2);
        NSLog(@"concurrent 2");
    });
    dispatch_async(concurrencyQueue, ^{
        sleep(1);
        NSLog(@"concurrent 3");
    });
}
@end
