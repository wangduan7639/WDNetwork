//
//  WDNetworking.m
//  WDNetwork
//
//  Created by wangduan on 16/4/5.
//  Copyright © 2016年 wangduan. All rights reserved.
//

#import "WDNetworking.h"
#import <AFNetworkActivityIndicatorManager.h>

static NSString *wd_privateNetworkBaseUrl = nil;
static BOOL wd_isEnableInterfaceDebug = NO;
static BOOL wd_shouldAutoEncode = NO;
static NSDictionary *wd_httpHeaders = nil;
static WDResponseType wd_responseType = kWDResponseTypeJSON;
static WDRequestType  wd_requestType  = kWDRequestTypeJSON;

@implementation WDNetworking

+ (void)updateBaseUrl:(NSString *)baseUrl {
    wd_privateNetworkBaseUrl = baseUrl;
}

+ (NSString *)baseUrl {
    return wd_privateNetworkBaseUrl;
}

+ (void)enableInterfaceDebug:(BOOL)isDebug {
    wd_isEnableInterfaceDebug = isDebug;
}

+ (BOOL)isDebug {
    return wd_isEnableInterfaceDebug;
}

+ (void)configResponseType:(WDResponseType)responseType {
    wd_responseType = responseType;
}

+ (void)configRequestType:(WDRequestType)requestType {
    wd_requestType = requestType;
}

+ (void)shouldAutoEncodeUrl:(BOOL)shouldAutoEncode {
    wd_shouldAutoEncode = shouldAutoEncode;
}

+ (BOOL)shouldEncode {
    return wd_shouldAutoEncode;
}

+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders {
    wd_httpHeaders = httpHeaders;
}

+ (WDURLSessionTask *)getWithUrl:(NSString *)url
                          target:(id)target
                          action:(SEL)action
                        delegate:(id<WDNetworkingDelegate>)delegate
                          success:(WDResponseSuccess)success
                             fail:(WDResponseFail)fail {
    return [self getWithUrl:url
                     params:nil
                     target:target
                     action:action
                   delegate:delegate
                    success:success
                       fail:fail];
}

+ (WDURLSessionTask *)getWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                          target:(id)target
                          action:(SEL)action
                        delegate:(id<WDNetworkingDelegate>)delegate
                          success:(WDResponseSuccess)success
                             fail:(WDResponseFail)fail {
    return [self getWithUrl:url
                     params:params
                     target:target
                     action:action
                   delegate:delegate
                   progress:nil
                    success:success
                       fail:fail];
}

+ (WDURLSessionTask *)getWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                          target:(id)target
                          action:(SEL)action
                        delegate:(id<WDNetworkingDelegate>)delegate
                         progress:(WDGetProgress)progress
                          success:(WDResponseSuccess)success
                             fail:(WDResponseFail)fail {
    return [self _requestWithUrl:url
                       httpMedth:kWDHttpMethodTypeGet
                          params:params
                          target:target
                          action:action
                        delegate:delegate
                        progress:progress
                         success:success
                            fail:fail];
}

+ (WDURLSessionTask *)postWithUrl:(NSString *)url
                            params:(NSDictionary *)params
                           target:(id)target
                           action:(SEL)action
                         delegate:(id<WDNetworkingDelegate>)delegate
                           success:(WDResponseSuccess)success
                              fail:(WDResponseFail)fail {
    return [self postWithUrl:url
                      params:params
                      target:target
                      action:action
                    delegate:delegate
                    progress:nil
                     success:success
                        fail:fail];
}

+ (WDURLSessionTask *)postWithUrl:(NSString *)url
                            params:(NSDictionary *)params
                           target:(id)target
                           action:(SEL)action
                         delegate:(id<WDNetworkingDelegate>)delegate
                          progress:(WDPostProgress)progress
                           success:(WDResponseSuccess)success
                              fail:(WDResponseFail)fail {
    return [self _requestWithUrl:url
                       httpMedth:kWDHttpMethodTypePost
                          params:params
                          target:target
                          action:action
                        delegate:delegate
                        progress:progress
                         success:success
                            fail:fail];
}

+ (WDURLSessionTask *)_requestWithUrl:(NSString *)url
                             httpMedth:(WDHttpMethodType)httpMethod
                                params:(NSDictionary *)params
                               target:(id)target
                               action:(SEL)action
                             delegate:(id<WDNetworkingDelegate>)delegate
                              progress:(WDDownloadProgress)progress
                               success:(WDResponseSuccess)success
                                  fail:(WDResponseFail)fail {
    AFHTTPSessionManager *manager = [self manager];
    
    if ([self baseUrl] == nil) {
        if ([NSURL URLWithString:url] == nil) {
            WDAppLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    } else {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil) {
            WDAppLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    
    WDURLSessionTask *session = nil;
    
    if (httpMethod == kWDHttpMethodTypeGet) {
        session = [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //block
            if (success) {
                [self successResponse:responseObject callback:success];
            }
            //delegate
            if (delegate && [delegate respondsToSelector:@selector(requestDidFinishWithData:)]) {
                [delegate performSelector:@selector(requestDidFinishWithData:) withObject:[self tryToParseData:responseObject]];
            }
            //SEL
            if (target && [target respondsToSelector:@selector(action)]) {
                [target performSelector:@selector(action) withObject:[self tryToParseData:responseObject] withObject:nil];
            }
            
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject
                                         url:task.response.URL.absoluteString
                                      params:params];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //block
            if (fail) {
                fail(error);
            }
            //delegate
            if (delegate && [delegate respondsToSelector:@selector(requestDidFailWithError:)]) {
                [delegate performSelector:@selector(requestDidFailWithError:) withObject:error];
            }
            //SEL
            if (target && [target respondsToSelector:@selector(action)]) {
                [target performSelector:@selector(action) withObject:[self tryToParseData:nil] withObject:error];
            }

            if ([self isDebug]) {
                [self logWithFailError:error url:task.response.URL.absoluteString params:params];
            }
        }];
    } else if (httpMethod == kWDHttpMethodTypePost) {
        session = [manager POST:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //block
            if (success) {
                [self successResponse:responseObject callback:success];
            }
            //delegate
            if (delegate && [delegate respondsToSelector:@selector(requestDidFinishWithData:)]) {
                [delegate performSelector:@selector(requestDidFinishWithData:) withObject:[self tryToParseData:responseObject]];
            }
            //SEL
            if (target && [target respondsToSelector:@selector(action)]) {
                [target performSelector:@selector(action) withObject:[self tryToParseData:responseObject] withObject:nil];
            }

            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject
                                         url:task.response.URL.absoluteString
                                      params:params];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //block
            if (fail) {
                fail(error);
            }
            //delegate
            if (delegate && [delegate respondsToSelector:@selector(requestDidFailWithError:)]) {
                [delegate performSelector:@selector(requestDidFailWithError:) withObject:error];
            }
            //SEL
            if (target && [target respondsToSelector:@selector(action)]) {
                [target performSelector:@selector(action) withObject:[self tryToParseData:nil] withObject:error];
            }
            
            if ([self isDebug]) {
                [self logWithFailError:error url:task.response.URL.absoluteString params:params];
            }
        }];
    }
    
    return session;
}

+ (WDURLSessionTask *)uploadFileWithUrl:(NSString *)url
                           uploadingFile:(NSString *)uploadingFile
                                 target:(id)target
                                 action:(SEL)action
                               delegate:(id<WDNetworkingDelegate>)delegate
                                progress:(WDUploadProgress)progress
                                 success:(WDResponseSuccess)success
                                    fail:(WDResponseFail)fail {
    if ([NSURL URLWithString:uploadingFile] == nil) {
        WDAppLog(@"uploadingFile无效，无法生成URL。请检查待上传文件是否存在");
        return nil;
    }
    
    NSURL *uploadURL = nil;
    if ([self baseUrl] == nil) {
        uploadURL = [NSURL URLWithString:url];
    } else {
        uploadURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]];
    }
    
    if (uploadURL == nil) {
        WDAppLog(@"URLString无效，无法生成URL。可能是URL中有中文或特殊字符，请尝试Encode URL");
        return nil;
    }
    
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    
    AFHTTPSessionManager *manager = [self manager];
    NSURLRequest *request = [NSURLRequest requestWithURL:uploadURL];
    WDURLSessionTask *session = [manager uploadTaskWithRequest:request fromFile:[NSURL URLWithString:uploadingFile] progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        //block
        if (success) {
            [self successResponse:responseObject callback:success];
        }
        //delegate
        if (delegate && [delegate respondsToSelector:@selector(requestDidFinishWithData:)]) {
            [delegate performSelector:@selector(requestDidFinishWithData:) withObject:[self tryToParseData:responseObject]];
        }
        //SEL
        if (target && [target respondsToSelector:@selector(action)]) {
            [target performSelector:@selector(action) withObject:[self tryToParseData:responseObject] withObject:nil];
        }

        
        if (error) {
            //block
            if (fail) {
                fail(error);
            }
            //delegate
            if (delegate && [delegate respondsToSelector:@selector(requestDidFailWithError:)]) {
                [delegate performSelector:@selector(requestDidFailWithError:) withObject:error];
            }
            //SEL
            if (target && [target respondsToSelector:@selector(action)]) {
                [target performSelector:@selector(action) withObject:[self tryToParseData:nil] withObject:error];
            }
            
            if ([self isDebug]) {
                [self logWithFailError:error url:response.URL.absoluteString params:nil];
            }
        } else {
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject
                                         url:response.URL.absoluteString
                                      params:nil];
            }
        }
    }];
    
    return session;
}

+ (WDURLSessionTask *)uploadWithImage:(UIImage *)image
                                   url:(NSString *)url
                              filename:(NSString *)filename
                                  name:(NSString *)name
                              mimeType:(NSString *)mimeType
                            parameters:(NSDictionary *)parameters
                               target:(id)target
                               action:(SEL)action
                             delegate:(id<WDNetworkingDelegate>)delegate
                              progress:(WDUploadProgress)progress
                               success:(WDResponseSuccess)success
                                  fail:(WDResponseFail)fail {
    if ([self baseUrl] == nil) {
        if ([NSURL URLWithString:url] == nil) {
            WDAppLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    } else {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil) {
            WDAppLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    
    AFHTTPSessionManager *manager = [self manager];
    WDURLSessionTask *session = [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        
        NSString *imageFileName = filename;
        if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            imageFileName = [NSString stringWithFormat:@"%@.jpg", str];
        }
        
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //block
        if (success) {
            [self successResponse:responseObject callback:success];
        }
        //delegate
        if (delegate && [delegate respondsToSelector:@selector(requestDidFinishWithData:)]) {
            [delegate performSelector:@selector(requestDidFinishWithData:) withObject:[self tryToParseData:responseObject]];
        }
        //SEL
        if (target && [target respondsToSelector:@selector(action)]) {
            [target performSelector:@selector(action) withObject:[self tryToParseData:responseObject] withObject:nil];
        }
        
        if ([self isDebug]) {
            [self logWithSuccessResponse:responseObject
                                     url:task.response.URL.absoluteString
                                  params:parameters];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //block
        if (fail) {
            fail(error);
        }
        //delegate
        if (delegate && [delegate respondsToSelector:@selector(requestDidFailWithError:)]) {
            [delegate performSelector:@selector(requestDidFailWithError:) withObject:error];
        }
        //SEL
        if (target && [target respondsToSelector:@selector(action)]) {
            [target performSelector:@selector(action) withObject:[self tryToParseData:nil] withObject:error];
        }
        
        if ([self isDebug]) {
            [self logWithFailError:error url:task.response.URL.absoluteString params:nil];
        }
    }];
    
    return session;
}

+ (WDURLSessionTask *)downloadWithUrl:(NSString *)url
                            saveToPath:(NSString *)saveToPath
                               target:(id)target
                               action:(SEL)action
                             delegate:(id<WDNetworkingDelegate>)delegate
                              progress:(WDDownloadProgress)progressBlock
                               success:(WDResponseSuccess)success
                               failure:(WDResponseFail)failure {
    if ([self baseUrl] == nil) {
        if ([NSURL URLWithString:url] == nil) {
            WDAppLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    } else {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil) {
            WDAppLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPSessionManager *manager = [self manager];
    
    WDURLSessionTask *session = [manager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL URLWithString:saveToPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //block
        if (success) {
            success(filePath.absoluteString);
        }
        //delegate
        if (delegate && [delegate respondsToSelector:@selector(requestDidFinishWithData:)]) {
            [delegate performSelector:@selector(requestDidFinishWithData:) withObject:filePath.absoluteString];
        }
        //SEL
        if (target && [target respondsToSelector:@selector(action)]) {
            [target performSelector:@selector(action) withObject:filePath.absoluteString withObject:nil];
        }
    }];
    
    return session;
}

#pragma mark - Private
+ (AFHTTPSessionManager *)manager {
    // 开启转圈圈
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    AFHTTPSessionManager *manager = nil;;
    if ([self baseUrl] != nil) {
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[self baseUrl]]];
    } else {
        manager = [AFHTTPSessionManager manager];
    }
    
    switch (wd_requestType) {
        case kWDRequestTypeJSON: {
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
        }
        case kWDRequestTypePlainText: {
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        }
        default: {
            break;
        }
    }
    
    switch (wd_responseType) {
        case kWDResponseTypeJSON: {
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        }
        case kWDResponseTypeXML: {
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        }
        case kWDResponseTypeData: {
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        }
        default: {
            break;
        }
    }
    
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    
    
    for (NSString *key in wd_httpHeaders.allKeys) {
        if (wd_httpHeaders[key] != nil) {
            [manager.requestSerializer setValue:wd_httpHeaders[key] forHTTPHeaderField:key];
        }
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"]];
    
    // 设置允许同时最大并发数量，过大容易出问题
    manager.operationQueue.maxConcurrentOperationCount = 3;
    return manager;
}

+ (void)logWithSuccessResponse:(id)response url:(NSString *)url params:(NSDictionary *)params {
    WDAppLog(@"\nabsoluteUrl: %@\n params:%@\n response:%@\n\n",
              [self generateGETAbsoluteURL:url params:params],
              params,
              [self tryToParseData:response]);
}

+ (void)logWithFailError:(NSError *)error url:(NSString *)url params:(NSDictionary *)params {
    WDAppLog(@"\nabsoluteUrl: %@\n params:%@\n errorInfos:%@\n\n",
              [self generateGETAbsoluteURL:url params:params],
              params,
              [error localizedDescription]);
}

// 仅对一级字典结构起作用
+ (NSString *)generateGETAbsoluteURL:(NSString *)url params:(NSDictionary *)params {
    if (params.count == 0) {
        return url;
    }
    
    NSString *queries = @"";
    for (NSString *key in params) {
        id value = [params objectForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            continue;
        } else if ([value isKindOfClass:[NSArray class]]) {
            continue;
        } else if ([value isKindOfClass:[NSSet class]]) {
            continue;
        } else {
            queries = [NSString stringWithFormat:@"%@%@=%@&",
                       (queries.length == 0 ? @"&" : queries),
                       key,
                       value];
        }
    }
    
    if (queries.length > 1) {
        queries = [queries substringToIndex:queries.length - 1];
    }
    
    if (([url rangeOfString:@"http://"].location != NSNotFound
         || [url rangeOfString:@"https://"].location != NSNotFound)
        && queries.length > 1) {
        if ([url rangeOfString:@"?"].location != NSNotFound
            || [url rangeOfString:@"#"].location != NSNotFound) {
            url = [NSString stringWithFormat:@"%@%@", url, queries];
        } else {
            queries = [queries substringFromIndex:1];
            url = [NSString stringWithFormat:@"%@?%@", url, queries];
        }
    }
    
    return url.length == 0 ? queries : url;
}


+ (NSString *)encodeUrl:(NSString *)url {
    return [self WD_URLEncode:url];
}

+ (id)tryToParseData:(id)responseData {
    if ([responseData isKindOfClass:[NSData class]]) {
        // 尝试解析成JSON
        if (responseData == nil) {
            return responseData;
        } else {
            NSError *error = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&error];
            
            if (error != nil) {
                return responseData;
            } else {
                return response;
            }
        }
    } else {
        return responseData;
    }
}

+ (void)successResponse:(id)responseData callback:(WDResponseSuccess)success {
    if (success) {
        success([self tryToParseData:responseData]);
    }
}

+ (NSString *)WD_URLEncode:(NSString *)url {
    NSString *newString =
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)url,
                                                              NULL,
                                                              CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    if (newString) {
        return newString;
    }
    
    return url;
}
@end
