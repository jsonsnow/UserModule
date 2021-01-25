//
//  UserModule.m
//  UserModule
//
//  Created by chen liang on 2021/1/25.
//

#import "UserModule.h"
#import <WGCommon/WGCommon-Swift.h>
#import <UserModule/UserModule-Swift.h>

@implementation UserModule

+ (void)load {
    [Bifrost registerService:@protocol(WGUserModuleService) withModule:self];
}

- (nullable NSString *)albumId { 
    return [UserModuleImp.instance albumId];
}

- (void)saveLoginUserInfo:(nonnull NSDictionary *)info { 
    [[UserModuleImp instance] saveLoginUserInfo:info];
}

- (void)saveUserToken:(nonnull NSString *)token { 
    [[UserModuleImp instance] saveUserToken:token];
}

- (nullable NSString *)userToken { 
    return [UserModuleImp.instance userToken];
}

- (void)setJSDevelop:(NSString *)value {
    [UserModuleImp.instance setJsDevelopWith:value];
}

- (NSString *)jsDevelop {
    return [UserModuleImp.instance jsDevelop];
}

- (void)setup { 
    
}

- (void)loginOut:(void (^)(void))callback {
    [[UserModuleImp instance] clear];
}

+ (instancetype)sharedInstance { 
    static UserModule *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UserModule alloc] init];
    });
    return instance;
}

@end
