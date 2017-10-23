//
//  AppDelegate.m
//  KeyChainDemo
//
//  Created by hzyuxiaohua on 2017/10/21.
//  Copyright © 2017年 hzyuxiaohua. All rights reserved.
//

#import "AppDelegate.h"

#import "NEKeyChain.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *kNEDeviceIDKey = @"com.netease.mail.device-id";
    NEKeyChain *kc = [[NEKeyChain alloc] initWithIdentifier:@"com.netese.mail" service:@"device-info"];
    
    NSData *data = [kc dataForKey:kNEDeviceIDKey];
    NSString *mesg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (mesg.length == 0) {
        mesg = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        data = [mesg dataUsingEncoding:NSUTF8StringEncoding];
        [kc setData:data forKey:kNEDeviceIDKey];
    }
    
    NSLog(@"%@", mesg);
    
    NSString *date = [NSString stringWithFormat:@"%@", [NSDate date]];
    data = [date dataUsingEncoding:NSUTF8StringEncoding];
    [kc setData:data forKey:kNEDeviceIDKey];
    
    return YES;
}


@end
