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

#import "Bifrost+Router.h"
#import "Bifrost.h"
#import "BifrostHeader.h"
#import "BifrostProtocol.h"

FOUNDATION_EXPORT double WGRouterVersionNumber;
FOUNDATION_EXPORT const unsigned char WGRouterVersionString[];

