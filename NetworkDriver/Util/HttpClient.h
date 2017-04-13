//
//  DJTHttpClient.h
//  TY
//
//  Created by songzhanglong on 14-5-20.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@interface HttpClient : NSObject
#pragma mark - 单任务请求
+ (NSURLSessionDataTask *)asynchronousNormalRequest:(NSString *)url parameters:(NSDictionary *)parameters complateBlcok:(void (^)(NSError *error,id data))complateBlock;

#pragma mark - 多任务请求
// 3种方式 1.GCD dispatch group （dispatch_group_create，dispatch_group_leave(group);dispatch_group_notify）
//2.NSOperationQueue NSOperation是对象，不像 dispatch 是 c 函数。这就意味着你可以继承它，可以给它加 category，在执行过程中也可以始终管理它，访问到它，查看它的状态等，不像 dispatch 是一撒手就够不着了。 用NSOperation执行的任务，执行过程中可以随时取消。dispatch 一经发出是无法取消的。 NSOperationQueue可以限制最大并发数。假如队列里真有 100 个文件要传，开出 100 个线程反而会严重影响性能。NSOperationQueue可以很方便地设置maxConcurrentOperationCount。dispatch 也可以限制最大并发数（参考苹果的文档）不过写起来麻烦很多。  然而，用NSOperation也有一个很不方便的特点：NSOperationQueue是用 KVO 观察NSOperation状态来判断任务是否已结束的。而我们请求用的NSURLSessionTask，它长得很像一个NSOperation，但却并不是NSOperation的子类。所以，这一套方法最麻烦的地方就在于我们需要写一个自定义的NSOperation子类，只是为了跟踪NSURLSessionTask的状态。
//3.PromiseKit

#pragma mark - 单个文件上传,下载
+ (NSURLSessionTask *)downloadFileWithProgress:(NSString *)url complateBlcok:(void (^)(NSError *error,NSURL *filePath))complateBlock progressBlock:(void (^)(NSProgress *progress))progressBlock;

+ (NSURLSessionTask *)uploadFile:(NSString *)url filePath:(NSString *)path parameters:(NSDictionary *)parameter complateBlcok:(void (^)(NSError *error,id data))complateBlock progressBlock:(void (^)(NSProgress *progress))progressBlock;

@end
