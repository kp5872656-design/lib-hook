#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

// Forward declarations to fix any C-compiler implicit declaration errors
#ifdef __cplusplus
extern "C" {
#endif
    void* ivar_getInstanceAddress(id instance);
#ifdef __cplusplus
}
#endif

__attribute__((constructor))
static void init_hook(void) {
    NSLog(@"[LicenseHook] Started");
    Class cls = objc_getClass("CheatiOSShare.LicenseGateStore");
    if (!cls) {
        cls = objc_getClass("LicenseGateStore");
    }
    
    if (cls) {
        SEL sharedSel = NSSelectorFromString(@"shared");
        if ([cls respondsToSelector:sharedSel]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id inst = [cls performSelector:sharedSel];
            if (inst) {
                SEL setUnlockedSel = NSSelectorFromString(@"setIsUnlocked:");
                if ([inst respondsToSelector:setUnlockedSel]) {
                    [inst performSelector:setUnlockedSel withObject:@YES];
                    NSLog(@"[LicenseHook] Done");
                }
            }
            #pragma clang diagnostic pop
        }
    }
}
