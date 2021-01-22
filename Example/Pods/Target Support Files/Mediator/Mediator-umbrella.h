#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ModuleBundle.h"
#import "ModuleExceptionHandler.h"
#import "GoodsModuleService.h"
#import "HomeModuleService.h"
#import "LaunchModuleService.h"
#import "SaleModuleService.h"
#import "ShopModuleService.h"
#import "WGAppModuleService.h"
#import "WGImageEditModuleService.h"
#import "WGUserModuleService.h"
#import "WGWebModuleService.h"

FOUNDATION_EXPORT double MediatorVersionNumber;
FOUNDATION_EXPORT const unsigned char MediatorVersionString[];

