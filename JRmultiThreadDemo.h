//
//  JRmultiThreadDemo.h
//  JRKit
//
//  Created by lujianrong on 16/5/30.
//  Copyright © 2016年 lujianrong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface JRMultiThreadDemo : NSObject
/**
 *  线程间通讯
 */
- (void)threadDownImageBlock:(void (^)(UIImage *image))block;
/**
 *  开启后台线程
 */
- (void)operationQueueBlock:(void (^)(UIImage *image))block;
/**
 *  线程依赖
 */
+ (void)queueDependencyTest;
/**
 *  dispatch_async 异步线程
 */
+ (void)asyncDownImageBlock:(void (^)(UIImage *image))block;
/**
 *  dispatch_group_async的使用
     dispatch_group_async可以实现监听一组任务是否完成
 */
+ (void)global_queue_test;
/**
 *  dispatch_barrier_async的使用
 *  dispatch_barrier_async是在前面的任务执行结束后它才执行 而且它后面的任务等它执行完成之后才会执行
 */
+ (void)barrier_async_test;

/**
 *  重复执行多少次
 */
+ (void)apply_test;

/**
 *  + (void)global_queue_test; 差不多, 只不过无法监听都执行完了
 */
+ (void)blockOperation_test;
@end
