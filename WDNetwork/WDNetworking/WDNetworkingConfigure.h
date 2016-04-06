//
//  WDNetworkingConfigure.h
//  WDNetwork
//
//  Created by wangduan on 16/4/5.
//  Copyright © 2016年 wangduan. All rights reserved.
//

#ifndef WDNetworkingConfigure_h
#define WDNetworkingConfigure_h

#ifdef DEBUG
#define WDAppLog(s, ... ) NSLog( @"[%@：in line: %d]-->%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define WDAppLog(s, ... )
#endif

/**
 *  请求类型
 */
typedef NS_ENUM (NSInteger, WDHttpMethodType) {
    kWDHttpMethodTypeGet = 1, //get请求类型
    kWDHttpMethodTypePost = 2, //post
    kWDHttpMethodTypePut = 3, //put
};

typedef NS_ENUM(NSUInteger, WDResponseType) {
    kWDResponseTypeJSON = 1, // 默认JSON
    kWDResponseTypeXML  = 2, // XML
    kWDResponseTypeData = 3
};

typedef NS_ENUM(NSUInteger, WDRequestType) {
    kWDRequestTypeJSON = 1, // 默认JSON
    kWDRequestTypePlainText  = 2 // text/html
};

/*!
 
 *  下载进度
 *  @param bytesDownload                 已下载的大小
 *  @param totalBytesDownload            文件总大小
 */
typedef void (^WDDownloadProgress)(int64_t bytesDownload,
                                    int64_t totalBytesDownload);

typedef WDDownloadProgress WDGetProgress;
typedef WDDownloadProgress WDPostProgress;

/*!
 *  上传进度
 *  @param bytesUpload              已上传的大小
 *  @param totalBytesUpload         总上传大小
 */
typedef void (^WDUploadProgress)(int64_t bytesUpload,
                                  int64_t totalBytesUpload);

/*
 *  请求成功的回调
 *  @param response 服务端返回的数据类型
 */
typedef void(^WDResponseSuccess)(id response);

/*
 *  失败时的回调
 *  @param error 错误信息
 */
typedef void(^WDResponseFail)(NSError *error);

@class NSURLSessionTask;

typedef NSURLSessionTask WDURLSessionTask;

/**
 *   AFN 请求封装的代理协议
 */
@protocol WDNetworkingDelegate <NSObject>

@optional
/**
 *   请求结束
 *
 *   @param  返回的数据
 */
- (void)requestDidFinishWithData:(id)responseData;
/**
 *   请求失败
 *
 *   @param error 失败的 error
 */
- (void)requestDidFailWithError:(NSError*)error;

/**
 *   target   SEL的默认方法，规则。
 */
- (void)finishedRequest:(id)responseData didFaild:(NSError*)error;

@end


#endif /* WDNetworkingConfigure_h */
