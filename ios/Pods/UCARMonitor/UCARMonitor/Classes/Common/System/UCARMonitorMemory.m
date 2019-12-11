//
//  UCARMonitorMemory.m
//  Pods
//
//  Created by linux on 2017/8/14.
//
//

#import "UCARMonitorMemory.h"

#import <mach/mach.h>
#import <mach/mach_host.h>

//@info: https://developer.apple.com/videos/play/wwdc2018/416/

uint64_t UCAR_FBMemoryProfilerResidentMemoryInBytes() {
    kern_return_t rval = 0;
    mach_port_t task = mach_task_self();

    task_vm_info_data_t info = {0};
    mach_msg_type_number_t tcnt = TASK_VM_INFO_COUNT;
    task_flavor_t flavor = TASK_VM_INFO;


    task_info_t tptr = (task_info_t)&info;

    if (tcnt > sizeof(info))
        return 0;

    rval = task_info(task, flavor, tptr, &tcnt);
    if (rval != KERN_SUCCESS) {
        return 0;
    }

    return info.phys_footprint;
}
