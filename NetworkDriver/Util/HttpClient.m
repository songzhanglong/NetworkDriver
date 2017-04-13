//
//  DJTHttpClient.m
//  TY
//
//  Created by songzhanglong on 14-5-20.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "HttpClient.h"

@implementation HttpClient

#pragma mark - 单任务请求
+ (NSURLSessionDataTask *)asynchronousNormalRequest:(NSString *)url parameters:(NSDictionary *)parameters complateBlcok:(void (^)(NSError *error,id data))complateBlock
{
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    serializer.timeoutInterval = 30;
    NSError *error;
    NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString:url parameters:parameters error:&error];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
    response.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain",@"application/json",@"text/html", nil];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer = response;
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        id result = [responseObject valueForKey:@"result"];
        if (result){
            /*
            if ([result integerValue]==12)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                    [APPDELEGETE CusAlertView:@"提示" message:@"访问超时，请重新登录" ok:@"确定"];
                });
            }
            else    */if ([result integerValue] == 0)
            {
                complateBlock(nil,responseObject);
            }
            else{
                NSString *resultNote = [responseObject valueForKey:@"resultNote"];
                if (![resultNote isKindOfClass:[NSString class]] || resultNote.length == 0) {
                    resultNote = NET_WORK_TIP;
                }
                complateBlock([[NSError alloc] initWithDomain:resultNote code:0 userInfo:nil],responseObject);
            }
        }
        else{
            complateBlock([[NSError alloc] initWithDomain:NET_WORK_TIP code:0 userInfo:nil],responseObject);
        }
    }];
    [dataTask resume];
    return dataTask;
}

#pragma mark - 单个文件上传,下载
+ (NSURLSessionTask *)downloadFileWithProgress:(NSString *)url complateBlcok:(void (^)(NSError *error,NSURL *filePath))complateBlock progressBlock:(void (^)(NSProgress *progress))progressBlock
{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        progressBlock(downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        complateBlock(error,filePath);
    }];
    [downloadTask resume];
    
    return downloadTask;
}

+ (NSURLSessionTask *)uploadFile:(NSString *)url filePath:(NSString *)path parameters:(NSDictionary *)parameter complateBlcok:(void (^)(NSError *error,id data))complateBlock progressBlock:(void (^)(NSProgress *progress))progressBlock
{
    // 构造 NSURLRequest
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:@"file" error:nil];
    } error:nil];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFHTTPResponseSerializer *response = [AFHTTPResponseSerializer serializer];
    response.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"audio/mpeg",@"text/plain",@"application/zip",@"audio/x-aac",@"application/json",@"text/xml",@"image/png",@"image/jpg",@"image/jpeg",@"image/gif", nil];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer = response;
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:progressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        complateBlock(error,responseObject);
    }];
    [uploadTask resume];
    
    return uploadTask;
}

@end
