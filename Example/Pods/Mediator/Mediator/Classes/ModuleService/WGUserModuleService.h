//
//  WGUserModuleService.h
//  Mediator
//
//  Created by chen liang on 2020/12/26.
//

#import <Foundation/Foundation.h>
#import <WGRouter/BifrostHeader.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *kRouterUserLogin = @"//user/login";

@protocol WGUserModuleService <NSObject>

- (nullable NSString *)userToken;
- (nullable NSString *)albumId;

@end

NS_ASSUME_NONNULL_END
