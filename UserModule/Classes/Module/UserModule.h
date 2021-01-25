//
//  UserModule.h
//  UserModule
//
//  Created by chen liang on 2021/1/25.
//

#import <Foundation/Foundation.h>
#import <Mediator/WGUserModuleService.h>

NS_ASSUME_NONNULL_BEGIN


@interface UserModule : NSObject<WGUserModuleService, BifrostModuleProtocol>

@end

NS_ASSUME_NONNULL_END
