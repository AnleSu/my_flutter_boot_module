//
//  UCARMonitorAOP.m
//  Pods
//
//  Created by linux on 2017/8/14.
//
//

#import "UCARMonitorAOP.h"
#import <UCARUtility/UCARUtility.h>
#import <UCARLogger/UCARLogger.h>
#import <objc/message.h>
#import <objc/runtime.h>

#import "UCARMonitorStore.h"

static void ucar_aop_hookMethod(Class aClass, SEL originMeth, SEL newMeth) {
    Method origMethod = class_getInstanceMethod(aClass, originMeth);
    Method newMethod = class_getInstanceMethod(aClass, newMeth);

    method_exchangeImplementations(origMethod, newMethod);
}

static NSDictionary *ucar_aop_getButtonInfo(UIControl *button, SEL action, id target) {
    NSString *selfClass = NSStringFromClass([button class]);
    NSString *actionStr = NSStringFromSelector(action);
    NSString *targetStr = NSStringFromClass([target class]);
    NSString *responderClass = nil;
    UIResponder *responder = button.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            responderClass = NSStringFromClass([responder class]);
            break;
        }
        if ([responder isKindOfClass:[UIWindow class]]) {
            responderClass = NSStringFromClass([responder class]);
            break;
        }
        if (!responder.nextResponder) {
            responderClass = NSStringFromClass([responder class]);
            break;
        }
        responder = responder.nextResponder;
    }
    return @{
        @"type" : @"UIButton",
        @"responderClass" : [NSString stringWithFormat:@"%@", responderClass],
        @"selfClass" : [NSString stringWithFormat:@"%@", selfClass],
        @"targetStr" : [NSString stringWithFormat:@"%@", targetStr],
        @"actionStr" : [NSString stringWithFormat:@"%@", actionStr]
    };
}

// hook
@implementation UIControl (UCARAOP)

+ (void)load {
    ucar_aop_hookMethod([self class], @selector(sendAction:to:forEvent:), @selector(ucar_sendAction:to:forEvent:));
}

- (void)ucar_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    [self ucar_sendAction:action to:target forEvent:event];
    //只统计UIButton
    if ([self isKindOfClass:[UIButton class]]) {
        NSDictionary *remark = ucar_aop_getButtonInfo(self, action, target);
        UCARLoggerDebug(@"%@", remark);
        [[UCARMonitorStore sharedStore] storeEvent:@"tap" remark:remark];
    }
}

@end
