//
//  ZYNetworkerManager.m
//  ZYNetworker
//
//  Created by macOfEthan on 17/12/28.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//



#import "ZYNetworkerManager.h"

@interface ZYNetworkerManager ()


@property (nonatomic, strong) YYCache *cache;


@property (nonatomic, strong) DGActivityIndicatorView *activityIndicatorView;


@end

@implementation ZYNetworkerManager

static ZYNetworkerManager *manager = nil;

- (DGActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        self.activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeNineDots tintColor:ZY_THEME_COLOR size:20.0f];
        self.activityIndicatorView.frame = CGRectMake(0.0f, 0.0f, 100.0f, 100.0f);
        self.activityIndicatorView.center = CGPointMake(ZY_KEY_WINDOW.center.x, ZY_KEY_WINDOW.center.y-60);
        self.activityIndicatorView.transform = CGAffineTransformMakeScale(2.5, 2.5);
    }
    return _activityIndicatorView;
}

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZYNetworkerManager alloc] init];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",@"text/plain",  nil];
        manager.requestSerializer.timeoutInterval = 10;
        
    });
    return manager;
}

#pragma mark - zy_requestWithMethod
- (RACSignal *)zy_requestWithMethod:(ZYRequestMethod)requestMethod
                             andUrl:(NSString *)requestUrl
                      andParameters:(NSDictionary *)parameters
                      andRefreshNow:(BOOL)refreshNow
                andRequestAnimation:(ZYRequestAnimation)requestAnimation
{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [self request:requestMethod URLString:requestUrl parameters:parameters andRefreshNow:refreshNow animationType:requestAnimation withSubscriber:subscriber];
        
        return [RACDisposable disposableWithBlock:^{
            
            NSLog(@"清理");
        }];
    }];
}

- (void)request:(ZYRequestMethod)method
      URLString:(NSString *)URLString
     parameters:(NSDictionary *)parameters
  andRefreshNow:(BOOL)refreshNow
  animationType:(ZYRequestAnimation)requestAnimation
 withSubscriber:(id<RACSubscriber>  _Nonnull)subscriber
{
    [self addAnimationWithType:requestAnimation];
    
    //post
    if (method == ZYRequestMethodPOST) {
        
        //先返回缓存中的数据 不在请求
        BOOL isCached = [_cache containsObjectForKey:ZY_CACHE_NAME(@"post")];
        
        if (isCached && !refreshNow) {
            
            [subscriber sendNext:[_cache objectForKey:ZY_CACHE_NAME(@"post")]];
            
            return;
        }
        
        [manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
            
            [self removeAnimationsWithType:requestAnimation];
            
            //保存json name：url+请求方式
            _cache = [YYCache cacheWithName:ZY_CACHE_NAME(@"post")];
            [_cache setObject:responseObject forKey:ZY_CACHE_NAME(@"post")];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [subscriber sendError:error];
            
            [self removeAnimationsWithType:requestAnimation];
            
        }];
    }
    
    //get
    else{
        
        //先返回缓存中的数据 不在请求
        BOOL isCached = [_cache containsObjectForKey:ZY_CACHE_NAME(@"get")];
        
        if (isCached && !refreshNow) {
            
            [subscriber sendNext:[_cache objectForKey:ZY_CACHE_NAME(@"get")]];
            
            return;
        }
        
        [manager GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
            
            [self removeAnimationsWithType:requestAnimation];
            
            //保存json name：url+请求方式
            _cache = [YYCache cacheWithName:URLString];
            [_cache setObject:responseObject forKey:ZY_CACHE_NAME(@"get")];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            
            [subscriber sendError:error];
            
            [self removeAnimationsWithType:requestAnimation];
            
        }];
    }
}

#pragma mark - add animations
- (void)addAnimationWithType:(ZYRequestAnimation)requestAnimation
{
    if (requestAnimation == ZYRequestAnimationActive) {
        
        [ZY_KEY_WINDOW addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
    }
}

#pragma mark - remove animations
- (void)removeAnimationsWithType:(ZYRequestAnimation)requestAnimation
{
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
}


@end
