//
//  UCARLoadTime.h
//  UCARLoadTime
//
//  Created by suzhiqiu on 2019/6/29.
//  Copyright © 2019 364121248@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//在控制台打印load耗时
FOUNDATION_EXPORT void printLoadAnalyzeInfo(void);

//key:cost  value:name 
extern NSMutableArray<NSDictionary *> *dlaLoadModels;




