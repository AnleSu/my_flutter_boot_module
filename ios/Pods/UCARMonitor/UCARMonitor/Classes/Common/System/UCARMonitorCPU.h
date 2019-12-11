//
//  UCARMonitorCPU.h
//  Pods
//
//  Created by linux on 2017/8/14.
//
//

#import <Foundation/Foundation.h>


/**
 https://stackoverflow.com/questions/8223348/ios-get-cpu-usage-from-application
 **/

#ifdef __cplusplus
extern "C" {
#endif
    /**
     搜集cpu使用情况

     @return current cpu usage
     */
    float ucar_cpu_usage(void);
    
#ifdef __cplusplus
}
#endif

