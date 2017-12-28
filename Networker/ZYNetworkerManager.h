//
//  ZYNetworkerManager.h
//  ZYNetworker
//
//  Created by macOfEthan on 17/12/28.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#define ZY_KEY_WINDOW [UIApplication sharedApplication].keyWindow
#define ZY_THEME_COLOR [UIColor redColor]
#define ZY_CACHE_NAME(name) [URLString stringByAppendingString:name]

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import <YYCache/YYCache.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>

/** 网络请求方法枚举 */
typedef NS_ENUM(NSUInteger, ZYRequestMethod) {
    
    ZYRequestMethodGET = 0,
    ZYRequestMethodPOST,
};

/** 加载动画*/
typedef NS_ENUM(NSInteger, ZYRequestAnimation) {
    ZYRequestAnimationNONE = -1,      // 无
    ZYRequestAnimationActive = 0,        // 动图
};

@interface ZYNetworkerManager : AFHTTPSessionManager

+ (instancetype)shareManager;


/**
 发起网路请求

 @param requestMethod 请求方式扩展枚举
 @param requestUrl 请求url
 @param parameters 参数
 @param refreshNow 是否立即刷新数据 设置为YES：即使有缓存也去请求网络
 @param requestAnimation 动画扩展枚举
 @return 网路数据信号
 */
- (RACSignal *)zy_requestWithMethod:(ZYRequestMethod)requestMethod
                             andUrl:(NSString *)requestUrl
                      andParameters:(id)parameters
                      andRefreshNow:(BOOL)refreshNow
                andRequestAnimation:(ZYRequestAnimation)requestAnimation;

@end
