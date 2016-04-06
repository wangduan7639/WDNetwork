//
//  WDNetworking.h
//  WDNetwork
//
//  Created by wangduan on 16/4/5.
//  Copyright © 2016年 wangduan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDNetworkingConfigure.h"

//基于AFNetworking的网络层封装类.
@interface WDNetworking : NSObject
/*!
 *  用于指定网络请求接口的基础url，
 *  @param baseUrl 网络接口的基础url
 */
+ (void)updateBaseUrl:(NSString *)baseUrl;

/*!
 *  获取当前所设置的网络接口基础url
 *
 *  @return 当前基础url
 */
+ (NSString *)baseUrl;

/*!
 *  开启或关闭接口打印信息
 *
 *  @param isDebug 开发期，最好打开，默认是NO
 */
+ (void)enableInterfaceDebug:(BOOL)isDebug;

/*!
 *  配置返回格式，默认为JSON。
 *
 *  @param responseType 响应格式
 */
+ (void)configResponseType:(WDResponseType)responseType;

/*!
 *
 *  配置请求格式，默认为JSON。
 *
 *  @param requestType 请求格式
 */
+ (void)configRequestType:(WDRequestType)requestType;

/*!
*  开启或关闭是否自动将URL使用UTF8编码
 *
 *  @param shouldAutoEncode YES or NO,默认为NO
 */
+ (void)shouldAutoEncodeUrl:(BOOL)shouldAutoEncode;

/*!
 *  配置公共的请求头，只调用一次即可，通常放在应用启动的时候配置就可以了
 *
 *  @param httpHeaders 只需要将与服务器商定的固定参数设置即可
 */
+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders;

/*!
 *
 *  GET请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url     接口路径，
 *  @param success 接口成功请求到数据的回调
 *  @param fail    接口请求数据失败的回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (WDURLSessionTask *)getWithUrl:(NSString *)url
                          target:(id)target
                          action:(SEL)action
                        delegate:(id<WDNetworkingDelegate>)delegate
                          success:(WDResponseSuccess)success
                             fail:(WDResponseFail)fail;
/*!
 *
 *  GET请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url     接口路径，
 *  @param params  接口中所需要的拼接参数，如@{"uid" : @(111)}
 *  @param success 接口成功请求到数据的回调
 *  @param fail    接口请求数据失败的回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (WDURLSessionTask *)getWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                          target:(id)target
                          action:(SEL)action
                        delegate:(id<WDNetworkingDelegate>)delegate
                          success:(WDResponseSuccess)success
                             fail:(WDResponseFail)fail;

//带进度条
+ (WDURLSessionTask *)getWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                          target:(id)target
                          action:(SEL)action
                        delegate:(id<WDNetworkingDelegate>)delegate
                         progress:(WDGetProgress)progress
                          success:(WDResponseSuccess)success
                             fail:(WDResponseFail)fail;

/*!
 *
 *  POST请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url     接口路径
 *  @param params  接口中所需的参数，如@{"uid" : @(111)}
 *  @param success 接口成功请求到数据的回调
 *  @param fail    接口请求数据失败的回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (WDURLSessionTask *)postWithUrl:(NSString *)url
                            params:(NSDictionary *)params
                           target:(id)target
                           action:(SEL)action
                         delegate:(id<WDNetworkingDelegate>)delegate
                           success:(WDResponseSuccess)success
                              fail:(WDResponseFail)fail;

+ (WDURLSessionTask *)postWithUrl:(NSString *)url
                            params:(NSDictionary *)params
                           target:(id)target
                           action:(SEL)action
                         delegate:(id<WDNetworkingDelegate>)delegate
                          progress:(WDPostProgress)progress
                           success:(WDResponseSuccess)success
                              fail:(WDResponseFail)fail;
/**
 *	图片上传接口，若不指定baseurl，可传完整的url
 *
 *	@param image			图片对象
 *	@param url				上传图片的接口路径，如/path/images/
 *	@param filename		给图片起一个名字，默认为当前日期时间,格式为"yyyyMMddHHmmss"，后缀为`jpg`
 *	@param name				与指定的图片相关联的名称，这是由后端写接口的人指定的，如imagefiles
 *	@param mimeType		默认为image/jpeg
 *	@param parameters	参数
 *	@param progress		上传进度
 *	@param success		上传成功回调
 *	@param fail         上传失败回调
 *
 *	@return
 */
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
                                  fail:(WDResponseFail)fail;

/**
 *
 *	上传文件操作
 *
 *	@param url				上传路径
 *	@param uploadingFile	待上传文件的路径
 *	@param progress			上传进度
 *	@param success			上传成功回调
 *	@param fail				上传失败回调
 *
 *	@return
 */
+ (WDURLSessionTask *)uploadFileWithUrl:(NSString *)url
                           uploadingFile:(NSString *)uploadingFile
                                 target:(id)target
                                 action:(SEL)action
                               delegate:(id<WDNetworkingDelegate>)delegate
                                progress:(WDUploadProgress)progress
                                 success:(WDResponseSuccess)success
                                    fail:(WDResponseFail)fail;


/*!
 *
 *  下载文件
 *
 *  @param url           下载URL
 *  @param saveToPath    下载到哪个路径下
 *  @param progressBlock 下载进度
 *  @param success       下载成功后的回调
 *  @param failure       下载失败后的回调
 */
+ (WDURLSessionTask *)downloadWithUrl:(NSString *)url
                            saveToPath:(NSString *)saveToPath
                               target:(id)target
                               action:(SEL)action
                             delegate:(id<WDNetworkingDelegate>)delegate
                              progress:(WDDownloadProgress)progressBlock
                               success:(WDResponseSuccess)success
                               failure:(WDResponseFail)failure;
@end
