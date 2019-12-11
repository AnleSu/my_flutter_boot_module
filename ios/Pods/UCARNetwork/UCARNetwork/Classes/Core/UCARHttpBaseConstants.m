//
//  UCARHttpConstants.m
//  UCar
//
//  Created by KouArlen on 16/3/7.
//  Copyright © 2016年 zuche. All rights reserved.
//

#import "UCARHttpBaseConstants.h"

NSString *const UCARDNSCheckErrorDomain = @"UCARDNSCheckErrorDomain";

NSString *const UCARHttpErrorDomain = @"UCARHttpErrorDomain";
NSString *const UCARHttpMAPIErrorDomain = @"UCARHttpMAPIErrorDomain";
const NSInteger UCARHttpMAPICodeSuccess = 1;

const NSInteger UCARHttpTimeOut = 30;

NSString *const UCARHttpRSAPublicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDQUi8ycUr+p1rlRucHmuDaa6QcCY/"
                                       @"gENqHxHt3QcqRWoMHj63ZjVEpXcIRG9Nu5fdknIsoxzAG1gQQsNZh0sfCBxn1VfAtYiU6OLXH"
                                       @"WNR/485jzinfOWADEcVNk8W+U17SFyKcoWyO38Ry0PkTvHiU0hA3sbIwbn5C1BRwrX/"
                                       @"7JwIDAQAB";
NSString *const UCARHttpSessionID = @"UCARHttpSessionID";

NSString *const UCARHttpKeyMAPIServerDomain = @"MAPIServerDomain";
NSString *const UCARHttpKeyMAPIServerIP = @"MAPIServerIP";

NSString *const UCARHttpKeyDomain = @"domain";
NSString *const UCARHttpKeyIP = @"ip";

NSString *const UCARHttpRequestHeader = @"UCARHttp_header";
NSString *const UCARHttpKeyEventID = @"event_id";
NSString *const UCARHttpKeySecretKey = @"secretKey";
NSString *const UCARHttpKeyDeviceID = @"deviceId";

NSString *const UCARHttpResponseKeyCode = @"code";
NSString *const UCARHttpResponseKeyContent = @"content";
NSString *const UCARHttpResponseKeyUID = @"uid";
NSString *const UCARHttpResponseKeyMsg = @"msg";
NSString *const UCARHttpResponseKeyHandler = @"handler";

NSString *const UCARHttpResponseKeyHandlerServer = @"SERVER";
NSString *const UCARHttpResponseKeyHandlerClient = @"CLIENT";
NSString *const UCARHttpResponseKeyHandlerUser = @"USER";

// never use this URL unless you know what you are doing
NSString *const UCARURLHttpDNS = @"/extrainfo/hosturlnavigator";
