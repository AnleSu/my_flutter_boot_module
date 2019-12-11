//
//  UCARMonitorMemory.h
//  Pods
//
//  Created by linux on 2017/8/14.
//
//

#import <Foundation/Foundation.h>

/**
 https://github.com/facebook/FBMemoryProfiler
 FBMemoryProfilerDeviceUtils.h
 **/

#ifdef __cplusplus
extern "C" {
#endif
    
    /**
     搜集内存使用情况

     @return current resident memory from mach task info
     */
    uint64_t UCAR_FBMemoryProfilerResidentMemoryInBytes(void);
    
#ifdef __cplusplus
}
#endif
