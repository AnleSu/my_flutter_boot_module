//
//  UCARLogger.h
//  Pods
//
//  Created by linux on 2017/8/30.
//
//

#import <Foundation/Foundation.h>

#ifdef DEBUG

FOUNDATION_EXPORT void UCARLoggerError(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2) NS_NO_TAIL_CALL;
FOUNDATION_EXPORT void UCARLoggerWarn(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2) NS_NO_TAIL_CALL;
FOUNDATION_EXPORT void UCARLoggerInfo(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2) NS_NO_TAIL_CALL;
FOUNDATION_EXPORT void UCARLoggerDebug(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2) NS_NO_TAIL_CALL;
FOUNDATION_EXPORT void UCARLoggerVerbose(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2) NS_NO_TAIL_CALL;

#else

#define UCARLoggerError(...) {}
#define UCARLoggerWarn(...) {}
#define UCARLoggerInfo(...) {}
#define UCARLoggerDebug(...) {}
#define UCARLoggerVerbose(...) {}

#endif

/**
 数值越小，优先级越高

 - UCARLoggerLevelError: 错误
 - UCARLoggerLevelWarn: 警告
 - UCARLoggerLevelInfo: 提示
 - UCARLoggerLevelDebug: 调试
 - UCARLoggerLevelVerbose: 三方库内部调试信息
 */
typedef NS_ENUM(NSUInteger, UCARLoggerLevel) {
    UCARLoggerLevelError = 0,
    UCARLoggerLevelWarn = 1,
    UCARLoggerLevelInfo = 2,
    UCARLoggerLevelDebug = 3,
    UCARLoggerLevelVerbose = 4
};


/**
 日志打印
 */
@interface UCARLogger : NSObject

/**
 是否关闭日志，当关闭时，终端将不再输出，default = YES
 */
@property (nonatomic) BOOL closeLogger;


/**
 打印级别，default = UCARLoggerLevelVerbose
 */
@property (nonatomic) UCARLoggerLevel logLevel;


/**
 单例

 @return a logger instance
 */
+ (instancetype)sharedLogger;


/**
 打印日志

 @param message 日志
 @param level 级别
 */
- (void)log:(NSString *)message level:(UCARLoggerLevel)level;

@end
