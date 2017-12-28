//
//  ViewController.m
//  ZYNetworker
//
//  Created by macOfEthan on 17/12/28.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "ViewController.h"
#import "ZYNetworker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    static NSString * targetUrl = @"http://guangdiu.com/api/getranklist.php";
    
    [[[ZYNetworkerManager shareManager] zy_requestWithMethod:ZYRequestMethodPOST andUrl:targetUrl andParameters:@{} andRefreshNow:NO andRequestAnimation:ZYRequestAnimationActive] subscribeNext:^(id  _Nullable x) {
        
        id json = x;
        
        NSLog(@"json = %@", json);
    }];
    
}

@end
