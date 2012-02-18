//
//  TMAppDelegate.m
//  uddddd
//
//  Created by TAKAGI MASAYA on 12/02/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TMAppDelegate.h"
#import "objc-runtime-new.h"
#import <objc/runtime.h>
#include <mach-o/getsect.h>
#include <mach-o/dyld.h>

@implementation TMAppDelegate

@synthesize window = _window;

+ (void)load 
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unsigned int i, count;
        Method *methods = class_copyMethodList([UIDevice class], &count);
        for (i = 0; i < count; i++) {
            Method method = methods[i];
            if (sel_isEqual(method_getName(method), @selector(uniqueIdentifier))) {
                IMP imp = imp_implementationWithBlock((void*)objc_unretainedPointer(^(NSString *s) { return @"";}));
                method_setImplementation(method, imp);
            }
        }
        free(methods);
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    uint32_t count = _dyld_image_count();
    const struct mach_header *header;
    
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        NSString *basename = [[NSString stringWithCString:name encoding:NSASCIIStringEncoding] lastPathComponent];
        if ([basename isEqualToString:@"UIKit"]) {
            NSLog(@"%s", name);
            header = _dyld_get_image_header(i);
        }
    }
    
    unsigned long size;
    class_t **data = (class_t **)getsectiondata(header, SEG_DATA, "__objc_classlist", &size);
    uint32_t class_count = size / sizeof(class_t *);
    
    for (uint32_t i = 0; i < class_count; i++) {
        class_t *cls = data[i];
        const class_ro_t *ro_cls;
        NSString *class_name;
        if ((cls->data()->flags & RW_REALIZED)) {
            ro_cls = cls->data()->ro;
            class_name = [NSString stringWithCString:ro_cls->name encoding:NSASCIIStringEncoding];
        } else {
            ro_cls = (const class_ro_t *)cls->data();
            class_name = [NSString stringWithCString:ro_cls->name encoding:NSASCIIStringEncoding];
        }
        if ([class_name isEqualToString:@"UIDevice"]) {
            const method_list_t *m_list = ro_cls->baseMethods;
            method_list_t::method_iterator begin = m_list->begin();
            method_list_t::method_iterator end   = m_list->end();
            
            for (; begin != end; ++begin) {
                NSString *selName = NSStringFromSelector(begin->name);
                if ([selName isEqualToString:@"uniqueIdentifier"]) {
                    NSLog(@"%@", begin->imp([UIDevice currentDevice], begin->name));
                }
            }
        }
    }
    

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
