#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// Ye function dylib load hote hi run hoga
__attribute__((constructor))
void init_hook() {
    NSLog(@"[LicenseHook] Dylib Loaded Successfully");

    // 1. Class Name Check
    // Pehle puray naam se try karo, agar na mile to sirf class name se
    Class licenseClass = objc_getClass("CheatiOSShare.LicenseGateStore");
    if (!licenseClass) {
        licenseClass = objc_getClass("LicenseGateStore");
    }

    if (licenseClass) {
        // 2. Singleton Instance Get Karna
        SEL sharedSel = NSSelectorFromString(@"shared");
        if ([licenseClass respondsToSelector:sharedSel]) {
            id instance = ((id(*)(id, SEL))objc_msgSend)((id)licenseClass, sharedSel);

            if (instance) {
                // 3. Unlock Logic
                // Pehle Setter Method try karo
                SEL setSel = NSSelectorFromString(@"setIsUnlocked:");
                if ([instance respondsToSelector:setSel]) {
                    ((void (*)(id, SEL, BOOL))objc_msgSend)(instance, setSel, YES);
                    NSLog(@"[LicenseHook] Unlocked via Setter");
                } else {
                    // Agar setter nahi hai, to Direct Ivar (Memory) modify karo
                    Ivar ivar = class_getInstanceVariable(licenseClass, "_isUnlocked");
                    if (ivar) {
                        BOOL *ptr = (BOOL *)ivar_getInstanceAddress(instance);
                        *ptr = YES;
                        NSLog(@"[LicenseHook] Unlocked via Ivar Direct Access");
                    } else {
                        NSLog(@"[LicenseHook] Failed: _isUnlocked property not found");
                    }
                }
            } else {
                NSLog(@"[LicenseHook] Failed: Instance is nil");
            }
        } else {
            NSLog(@"[LicenseHook] Failed: 'shared' selector not found");
        }
    } else {
        NSLog(@"[LicenseHook] Failed: Class 'LicenseGateStore' not found");
    }
}
