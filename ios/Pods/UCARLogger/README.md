# UCARLogger

使用样例:    
```
// Logger 配置
[UCARLogger sharedLogger].closeLogger = NO;
[UCARLogger sharedLogger].logLevel = UCARLoggerLevelWarn;

// 能打印
UCARLoggerError(@"UCARLoggerError");
// 不能打印
UCARLoggerInfo(@"UCARLoggerInfo");
```

