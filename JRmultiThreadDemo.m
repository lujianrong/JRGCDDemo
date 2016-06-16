//
//  JRmultiThreadDemo.m
//  JRKit
//
//  Created by lujianrong on 16/5/30.
//  Copyright © 2016年 lujianrong. All rights reserved.
//

#import "JRMultiThreadDemo.h"

#define kURL [[NSBundle mainBundle] pathForResource:@"IMG_test" ofType:@".jpg"]

@interface JRMultiThreadDemo()
@property (nonatomic,   copy) void (^kImageBlock) (UIImage *image);
@end

@implementation JRMultiThreadDemo

- (void)threadDownImageBlock:(void (^)(UIImage *image))block{
    self.kImageBlock =  [block copy];
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(downloadImage:) object:kURL];
    [thread start];
}

- (void)downloadImage:(NSString *) url{
    NSData *data = [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:url]];
    UIImage *image = [[UIImage alloc]initWithData:data];
    if(image == nil) {
        //xxxxxxxxxxxx
        }else{
            //downloadImage 方法处理 的逻辑。下载完成后用performSelectorOnMainThread执行主线程updateUI方法。
            //updateUI 并把下载的图片显示到图片控件中。
            [self performSelectorOnMainThread:@selector(updateUI:) withObject:image waitUntilDone:YES];
        }
}

- (void )updateUI:(UIImage*) image{
    if (self.kImageBlock)  self.kImageBlock (image);
}

- (void)operationQueueBlock:(void (^)(UIImage *image))block{
    self.kImageBlock = [block copy];
    //用NSInvocationOperation建了一个后台线程,并且放到2.NSOperationQueue中。后台线程执行downloadImage方法
    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self                                                                           selector:@selector(downloadImage:) object:kURL];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:operation];
}


+ (void)queueDependencyTest{
    // 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // 创建3个操作
    NSOperation *a = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"operation---a");
    }];
    NSOperation *b = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"operation---b");
    }];
    NSOperation *c = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"operation---c");
    }];
    // 添加依赖
    [c addDependency:a];
    [c addDependency:b];
    // 执行操作
    [queue addOperation:a];
    [queue addOperation:b];
    [queue addOperation:c];
}
/**
 *  1、常用的方法dispatch_async
 * 为了避免界面在处理耗时的操作时卡死，比如读取网络数据，IO,数据库读写等，我们会在另外一个线程中处理这些操作，然后通知主线程更新界面
 */
+ (void)asyncDownImageBlock:(void (^)(UIImage *image))block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL * url = [[NSURL alloc] initFileURLWithPath:kURL];
        NSData * data = [[NSData alloc]initWithContentsOfURL:url];
        __block UIImage *image = [[UIImage alloc]initWithData:data];
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(image);
            });
        }
    });
}
/**
 *  dispatch_group_async的使用
     dispatch_group_async可以实现监听一组任务是否完成，完成后得到通知执行其他的操作。这个方法很有用，比如你执行三个下载任务，当三个任务都下载完成后你才通知界面说完成的了。
 */
+ (void)global_queue_test{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"group1");
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:5];
        NSLog(@"group2");
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:3];
        NSLog(@"group3");
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"ALL ---- FINISHED");
    });
    // dispatch_release(group);
}

//3、dispatch_barrier_async的使用
//dispatch_barrier_async是在前面的任务执行结束后它才执行，而且它后面的任务等它执行完成之后才会执行
+ (void)barrier_async_test{
    dispatch_queue_t queue = dispatch_queue_create("gcdtest.rongfzh.yc", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"dispatch_async1");
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"dispatch_async3");
    });
    dispatch_barrier_async(queue, ^{
        NSLog(@"dispatch_barrier_async");
        [NSThread sleepForTimeInterval:4];
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"dispatch_async2");
    });
}
+ (void)apply_test{
    dispatch_queue_t globalQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(5, globalQ, ^(size_t index) {
        // 执行5次
        NSLog(@"\n 打印5次");
    });
}
/**
 *  + (void)global_queue_test; 差不多, 只不过无法监听都执行完了
 */
+ (void)blockOperation_test {
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"--------1---%@", [NSThread currentThread]);
    }];
    [operation1 addExecutionBlock:^{
        NSLog(@"--------2---%@", [NSThread currentThread]);
    }];
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"--------3---%@", [NSThread currentThread]);
    }];
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"-------4---%@", [NSThread currentThread]);
    }];
    NSBlockOperation *operation4 = [NSBlockOperation blockOperationWithBlock:^{
        
        NSLog(@"-------5---%@", [NSThread currentThread]);
    }];
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // 主队列
    //    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    // 2.添加操作到队列中（自动异步执行）
    [queue addOperation:operation1];
    [queue addOperation:operation2];
    [queue addOperation:operation3];
    [queue addOperation:operation4];
}
@end
