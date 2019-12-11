//
//  LBSTools.c
//  Pods-LocationMonitorExample
//
//  Created by 戈宝福 on 2018/9/13.
//  
//


#include "UCarLBSTools.h"
#include <math.h>

static double PI = 3.1415926;
static double ConvertDegreesToRadians(double degrees)
{
    return degrees * PI / 180;
}

void LBSToolDistance(double lat1, double lon1, double lat2, double lon2, double* distance, double* heading)
{
    static double chidao = 40076000;  //赤道周长,单位米
    static double ziwu = 40009000;    //子午线长度, 单位米
    double dist1 = chidao * cos(ConvertDegreesToRadians(lat1)) * (lon1-lon2)/360.0;
    double dist2 = ziwu * (lat1-lat2)/360.0;
    if (heading) {
        *heading = atan2(dist1,dist2)*180/PI+180; //加180是为了保持和gps方向数据一致
    }
    if (distance) {
        *distance = sqrt(dist1*dist1+dist2*dist2);
    }
}
