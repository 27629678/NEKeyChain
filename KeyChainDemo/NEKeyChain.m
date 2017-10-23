//
//  NEKeyChain.m
//  KeyChainDemo
//
//  Created by hzyuxiaohua on 2017/10/23.
//  Copyright © 2017年 hzyuxiaohua. All rights reserved.
//

#import "NEKeyChain.h"

#import <Security/Security.h>

@interface NEKeyChain ()

@property (nonatomic) NSString *service;
@property (nonatomic) NSString *identifier;

@end

@implementation NEKeyChain

- (instancetype)initWithIdentifier:(NSString *)identifier service:(NSString *)service
{
    if (identifier.length == 0) {
        NSCAssert(NO, @"identifier MUST NOT be empty!");
        
        return nil;
    }
    
    if (self = [super init]) {
        self.service = service ? : @"";
        self.identifier = identifier;
    }
    
    return self;
}

- (NSData *)dataForKey:(NSString *)key
{
    NSMutableDictionary *query = [[self queryDictWithKey:key] mutableCopy];
    [query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    // retrieve sec item data from keychain
    CFDataRef outData = NULL;
    OSStatus result = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef*)&outData);
    
    if (result != errSecSuccess) {
        return nil;
    }
    
    return (__bridge NSData*)outData;
}

- (void)setData:(NSData *)data forKey:(NSString *)key
{
    if (!data) {
        return;
    }
    
    if (key.length == 0) {
        NSCAssert(NO, @"");
        return;
    }
    
    NSMutableDictionary *query = [[self queryDictWithKey:key] mutableCopy];
    [query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    
    // retrieve sec item attrbutes from keychain
    CFDictionaryRef attributes = NULL;
    OSStatus result = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&attributes);
    if (result != errSecSuccess) {
        if (result != errSecItemNotFound) {
            NSCAssert(NO, @"");
            
            return;
        }
        
        attributes = NULL;
    }
    
    NSDictionary *origin_attributes = (__bridge NSDictionary *)attributes;
    
    // add
    if (origin_attributes.count == 0) {
        [self addData:data forKey:key];
        
        return;
    }
    
    // update
    [self updateData:data forKey:key usingAttributes:origin_attributes];
}

#pragma mark - private

- (void)addData:(NSData *)data forKey:(NSString *)key
{
    // delete if need
    SecItemDelete((__bridge CFDictionaryRef)[self queryDictWithKey:key]);
    
    // add new sec item
    OSStatus result = SecItemAdd((__bridge CFDictionaryRef)[self emptyItemWithKey:key data:data], NULL);
    
    NSCAssert(result == errSecSuccess, @"Could not add item.");
}

- (void)updateData:(NSData *)data forKey:(NSString *)key usingAttributes:(NSDictionary *)attributes
{
    NSMutableDictionary *target = [attributes mutableCopy];
    [target setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSMutableDictionary *update = [attributes mutableCopy];
    [update setObject:data forKey:(__bridge id)kSecValueData];
    
    OSStatus result = SecItemUpdate((__bridge CFDictionaryRef)target, (__bridge CFDictionaryRef)update);
    
    NSCAssert(result == errSecSuccess, @"");
}

- (NSDictionary *)emptyItemWithKey:(NSString *)key data:(NSData *)data
{
    NSMutableDictionary *dict = [[self commonDictWithKey:key] mutableCopy];
    [dict setObject:@"" forKey:(__bridge id)kSecAttrLabel];
    [dict setObject:@"" forKey:(__bridge id)kSecAttrDescription];
    [dict setObject:data forKey:(__bridge id)kSecValueData];
    
    return dict;
}

- (NSDictionary *)queryDictWithKey:(NSString *)key
{
    NSMutableDictionary *dict = [[self commonDictWithKey:key] mutableCopy];
    [dict setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    return dict;
}

- (NSDictionary *)commonDictWithKey:(NSString *)key
{
    return @{ (__bridge id)kSecClass        : (__bridge id)kSecClassGenericPassword,
              (__bridge id)kSecAttrAccount  : key ? : @"",
              (__bridge id)kSecAttrService  : self.service,
              (__bridge id)kSecAttrGeneric  : self.identifier,
              (__bridge id)kSecAttrAccessible : (__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly,
              };
}

@end
