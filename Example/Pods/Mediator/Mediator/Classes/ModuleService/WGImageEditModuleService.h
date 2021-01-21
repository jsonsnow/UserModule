//
//  WGImageEditModuleService.h
//  Mediator
//
//  Created by chen liang on 2020/12/26.
//

#import <Foundation/Foundation.h>
#import <WGRouter/BifrostHeader.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - URL routers
static NSString *const kRouteImageEdit = @"//edit/imageEdit";
static NSString *const kRouteImageEditParamImage = @"image";
static NSString *const kRouteImageEditParamAutoDismiss = @"autoDismiss";
static NSString *const kRouteImageEditParamDefaultColor = @"defaultColor";
static NSString *const kRouteImageEditParamEditorCtr = @"editorCtr";
static NSString *const kRouteImageEditParamNeedChangeOriention = @"needChangeOriention";

@protocol WGImageEditModuleService <NSObject>

@end

NS_ASSUME_NONNULL_END
