//
//  JRGCDDemo.h
//  JRKit
//
//  Created by lujianrong on 16/5/30.
//  Copyright © 2016年 lujianrong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JRGCDDemo : NSObject
/**
 *  全局队列:全局并发队列
 */
+ (void)get_global_queue_test;
/**
 *  主队列是应用程序启动时，由系统预先创建的，与主线程相关联的队列。
  我们只能通过系统API来获取主队列，不能手动创建它
 */
+ (void)get_main_queue_test;
/**
 *  创建串行队列
 *  创建串行队列传：DISPATCH_QUEUE_SERIAL（也就是NULL）
 */
+ (void)queue_serial_test;
/**
 * 创建并发队列 
 * 创建并发队列传：DISPATCH_QUEUE_CONCURRENT
 */
+ (void)queue_concurrent_test;

@end
