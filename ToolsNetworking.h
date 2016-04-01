//
//  ToolsNetworking.h
//  demoApplication
//
//  Created by YJ on 16/3/29.
//  Copyright © 2016年 YJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@interface ToolsNetworking : NSObject
// 加载中显示信息
@property (nonatomic, strong) NSString* loadingMsg;
// 加载成功显示信息
@property (nonatomic, strong) NSString* successMsg;

// 隐藏加载中信息
@property (nonatomic, assign) bool noLoadingMsg;
// 手动隐藏加载信息
@property (nonatomic, assign) bool dismissLoadingMsgManual;

// 隐藏加载成功信息
@property (nonatomic, assign) bool noSuccessMsg;

// 隐藏加载失败信息
@property (nonatomic, assign) bool noFailMsg;

@property (nonatomic, strong) NSString* action;
@property (nonatomic, strong) NSMutableDictionary* params;

@property (nonatomic, strong) AFHTTPRequestOperationManager* reqObj;


// 准备调用
-(void)prepareRequest;
//初始化baseURL-afnetworking
-(void)initWithBaseURL:(NSString*) baseURL;

// 开始调用请求
-(void)get:(void (^)(NSDictionary* response))success
      fail:(void (^)(NSDictionary* response))fail
      datatype:(NSString *)datatype;

-(void)post:(void (^)(NSDictionary* response))success
       fail:(void (^)(NSDictionary* response))fail
        datatype:(NSString *)datatype;

-(void)postData:(NSData*)data
        success:(void (^)(NSDictionary *))success
           fail:(void (^)(NSDictionary *))fail
        datatype:(NSString *)datatype;

-(void)multiPart:(void (^)(id <AFMultipartFormData> formData))block
         success:(void (^)(NSDictionary* response))success
            fail:(void (^)(NSDictionary* response)) fail
        datatype:(NSString *)datatype;

@end
