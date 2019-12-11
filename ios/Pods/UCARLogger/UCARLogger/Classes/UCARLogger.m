//
//  UCARLogger.m
//  Pods
//
//  Created by linux on 2017/8/30.
//
//

#import "UCARLogger.h"

#ifdef DEBUG

void UCARLoggerError(NSString *format, ...) {
    if ([UCARLogger sharedLogger].closeLogger || UCARLoggerLevelError > [UCARLogger sharedLogger].logLevel) {
        return;
    }
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    [[UCARLogger sharedLogger] log:message level:UCARLoggerLevelError];
}

void UCARLoggerWarn(NSString *format, ...) {
    if ([UCARLogger sharedLogger].closeLogger || UCARLoggerLevelWarn > [UCARLogger sharedLogger].logLevel) {
        return;
    }
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    [[UCARLogger sharedLogger] log:message level:UCARLoggerLevelWarn];
}

void UCARLoggerInfo(NSString *format, ...) {
    if ([UCARLogger sharedLogger].closeLogger || UCARLoggerLevelInfo > [UCARLogger sharedLogger].logLevel) {
        return;
    }
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    [[UCARLogger sharedLogger] log:message level:UCARLoggerLevelInfo];
}

void UCARLoggerDebug(NSString *format, ...) {
    if ([UCARLogger sharedLogger].closeLogger || UCARLoggerLevelDebug > [UCARLogger sharedLogger].logLevel) {
        return;
    }
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    [[UCARLogger sharedLogger] log:message level:UCARLoggerLevelDebug];
}

void UCARLoggerVerbose(NSString *format, ...) {
    if ([UCARLogger sharedLogger].closeLogger || UCARLoggerLevelVerbose > [UCARLogger sharedLogger].logLevel) {
        return;
    }

    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    [[UCARLogger sharedLogger] log:message level:UCARLoggerLevelVerbose];
}

#endif

@interface UCARLogger ()

@end

@implementation UCARLogger

+ (instancetype)sharedLogger {
    static UCARLogger *logger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[UCARLogger alloc] init];
    });
    return logger;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _closeLogger = YES;
        _logLevel = UCARLoggerLevelVerbose;
    }
    return self;
}

- (void)log:(NSString *)message level:(UCARLoggerLevel)level {
    if (_closeLogger || level > _logLevel) {
        return;
    }

#ifdef DEBUG
    NSLog(@"%@", message);
#endif
    
}

@end
