//
//  LBSTools.h
//  Pods-LocationMonitorExample
//
//  Created by 戈宝福 on 2018/9/13.
//  
//


#ifndef LBSTools_h
#define LBSTools_h

#include <stdio.h>

//计算两点直接的距离与方向, 简化算法, 适用于短距离计算, 两点就距离越大误差越大
//lat,lon为经纬度.
//distance单位米, heading单位度
void LBSToolDistance(double lat1, double lon1, double lat2, double lon2, double* distance, double* heading);

#endif /* LBSTools_h */
