//
//  ToolsNetworking.m
//  demoApplication
//
//  Created by YJ on 16/3/29.
//  Copyright © 2016年 YJ. All rights reserved.
//
#import "ToolsNetworking.h"
@interface ToolsNetworking()
@property (nonatomic, strong) NSString* method;
@property (nonatomic, strong) NSString* datatype;
@property (nonatomic, strong) NSData* reqData;
@property (nonatomic, copy) void (^successCB) (NSDictionary *);
@property (nonatomic, copy) void (^failureCB) (NSDictionary *);
@property (nonatomic, copy) void (^multiPartBC)(id <AFMultipartFormData> formData);
@end
@implementation ToolsNetworking
/**
 * 1.本工具类进行网络数据获取
 * 2.可以调整多个数据类型的获取
 * 3.加载信息
 **/

//初始化工具类
-(id) init {
    self = [super init];
    if(self) {
        self.noLoadingMsg = FALSE;
        self.dismissLoadingMsgManual = FALSE;
        self.noSuccessMsg = TRUE;
        self.noFailMsg = FALSE;
    }
    return self;
}

//设置ip地址
-(void)initWithBaseURL:(NSString*) baseURL
{
    if(self) {
        self.reqObj = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    }
}

-(void)prepareRequest {
    self.params = [NSMutableDictionary dictionary];
}
-(void)get:(void (^)(NSDictionary *))success fail:(void (^)(NSDictionary *))fail datatype:(NSString *)datatype{
    self.method = @"GET";
    self.successCB = success;
    self.failureCB = fail;
    self.datatype =datatype;
    [self sendRequest:datatype];
}
-(void)post:(void (^)(NSDictionary *))success fail:(void (^)(NSDictionary *))fail datatype:(NSString *)datatype{
    self.method = @"POST";
    self.successCB = success;
    self.failureCB = fail;
    [self sendRequest:datatype];
}

-(void)postData:(NSData*)data success:(void (^)(NSDictionary *))success fail:(void (^)(NSDictionary *))fail datatype:(NSString *)datatype{
    self.method = @"POST_DATA";
    self.reqData = data;
    self.successCB = success;
    self.failureCB = fail;
    
    [self sendRequest:datatype];
}

-(void)multiPart:(void (^)(id <AFMultipartFormData> formData))block success:(void (^)(NSDictionary* response))success fail:(void (^)(NSDictionary* response)) fail datatype:(NSString *)datatype{
    
    self.method = @"MULTIPART";
    self.multiPartBC = block;
    self.successCB = success;
    self.failureCB = fail;
    [self sendRequest:datatype];
}

-(void)sendRequest:(NSString *)datatype
{
    //准备提交给服务器的参数
    [self prepareRequest];
    
    //处理网络连接协议
    
    //消息提示
    if(!self.noLoadingMsg) {
        NSString* msg = self.loadingMsg;
        if(!msg || msg.length == 0) {
            msg = @"加载中";
        }
        
        //[SVProgressHUD showWithStatus:msg maskType:SVProgressHUDMaskTypeClear];
    }
    // 成功处理 block
    void (^loc_SuccessFn)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // no mutable => mutable
        NSData* orgData = [NSJSONSerialization dataWithJSONObject:responseObject options:0 error:nil];
        NSDictionary* data = [NSJSONSerialization JSONObjectWithData:orgData options:NSJSONReadingMutableContainers error:nil];
        if(self.noSuccessMsg) {
            if(!self.noLoadingMsg && !self.dismissLoadingMsgManual) {
                //[SVProgressHUD dismiss];
            }
        } else {
            NSString* msg = self.successMsg;
            if(!msg || msg.length == 0) {
                msg = data[@"msg"];
            }
            
           // [SVProgressHUD showSuccessWithStatus:msg];
        }
        if(self.successCB) {
            dispatch_sync(dispatch_get_main_queue(), ^(){
                //Update UI in UI thread here
                self.successCB(data);
            });
        }
        if (self.failureCB) {
             self.failureCB(data);
        }
    };
    // 错误处理 block
    void (^loc_FailFn)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if(self.noFailMsg) {
            if(!self.noLoadingMsg) {
               // [SVProgressHUD dismiss];
            }
        } else {
            //[SVProgressHUD showInfoWithStatus:@"网络错误"];
        }
        
        if(self.failureCB) {
            self.failureCB(nil);
        }
    };
    // 提交请求
    if (datatype) {
        self.reqObj.responseSerializer.acceptableContentTypes =[NSSet setWithObject:datatype];
    }
    if([self.method isEqualToString:@"GET"]) {
        
        [self.reqObj GET:self.action
             parameters:self.params
                success:loc_SuccessFn
                failure:loc_FailFn];
        
    } else if([self.method isEqualToString:@"POST"]) {
        
        [self.reqObj POST:self.action
              parameters:self.params
                 success:loc_SuccessFn
                 failure:loc_FailFn];
        
    } else if([self.method isEqualToString:@"POST_DATA"]) {
        
        NSMutableString* urlStr = [NSMutableString stringWithFormat:@"%@/%@", self.reqObj.baseURL, self.action];
        
        // 组织参数
        NSMutableArray* paramAry = [NSMutableArray array];
        for(NSString* key in self.params.allKeys) {
            [paramAry addObject:[NSString stringWithFormat:@"%@=%@", key, self.params[key]]];
        }
        
        if(paramAry.count > 0) {
            [urlStr appendFormat:@"?%@", [paramAry componentsJoinedByString:@"&"]];
        }
        
        NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        req.HTTPBody = self.reqData;
        req.HTTPMethod = @"POST";
        
        AFHTTPRequestOperation* reqOp = [self.reqObj HTTPRequestOperationWithRequest:req success:loc_SuccessFn failure:loc_FailFn];
        [self.reqObj.operationQueue addOperation:reqOp];
        
    } else if([self.method isEqualToString:@"MPART"]) {
        [self.reqObj POST:self.action
              parameters:self.params
              constructingBodyWithBlock:self.multiPartBC
              success:loc_SuccessFn
              failure:loc_FailFn];
        
    } else if([self.method isEqualToString:@"MULTIPART"]) {
        [self.reqObj POST:self.action
              parameters:self.params
              constructingBodyWithBlock:self.multiPartBC
              success:loc_SuccessFn
              failure:loc_FailFn];
    }
}

//网络环境检测
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //创建网络监听管理者对象
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    /*
     typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
     AFNetworkReachabilityStatusUnknown          = -1,//未识别的网络
     AFNetworkReachabilityStatusNotReachable     = 0,//不可达的网络(未连接)
     AFNetworkReachabilityStatusReachableViaWWAN = 1,//2G,3G,4G...
     AFNetworkReachabilityStatusReachableViaWiFi = 2,//wifi网络
     };
     */
    //设置监听
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未识别的网络");
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"不可达的网络(未连接)");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"2G,3G,4G...的网络");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"wifi的网络");
                break;
            default:
                break;
        }
    }];
    //开始监听
    [manager startMonitoring];
}
@end
