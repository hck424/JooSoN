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

#import "VYNFCKit.h"
#import "VYNFCNDEFMessageHeader.h"
#import "VYNFCNDEFPayloadParser.h"
#import "VYNFCNDEFPayloadTypes.h"

FOUNDATION_EXPORT double VYNFCKitVersionNumber;
FOUNDATION_EXPORT const unsigned char VYNFCKitVersionString[];

