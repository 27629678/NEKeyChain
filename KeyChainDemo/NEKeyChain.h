//
//  NEKeyChain.h
//  KeyChainDemo
//
//  Created by hzyuxiaohua on 2017/10/23.
//  Copyright © 2017年 hzyuxiaohua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEKeyChain : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier service:(NSString *)service;

- (NSData *)dataForKey:(NSString *)key;

- (void)setData:(NSData *)data forKey:(NSString *)key;

@end
