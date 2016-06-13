//
//  AppDelegate.m
//  AutosaveBrowser
//
//  Created by localhome on 09/06/2016.
//  Copyright (c) 2016 Guardian News & Media. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(! [defaults valueForKey:@"cachefolder_local_path"]) [self setupLocalCacheFolder];
    
    [[self mainWindowController] scanAutosaveVault];
    
}

- (void) setupLocalCacheFolder
{
    NSError *e=NULL;
    NSLog(@"no local cache folder present.  Setting one up.");
    NSString *path = [[self applicationDataDirectory] path];
    NSLog(@"data directory is %@",path);
    NSString *newCachePath = [path stringByAppendingPathComponent:@"PremiereProjectCache"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:newCachePath forKey:@"cachefolder_local_path"];
    
    BOOL isDir;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:newCachePath isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:newCachePath withIntermediateDirectories:YES attributes:nil error:&e]){
            NSAlert *a=[NSAlert alertWithError:e];
            [a runModal];
        }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

/* thanks to http://stackoverflow.com/questions/8430777/programatically-get-path-to-application-support-folder */
- (NSURL*)applicationDataDirectory {
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray* possibleURLs = [sharedFM URLsForDirectory:NSApplicationSupportDirectory
                                             inDomains:NSUserDomainMask];
    NSURL* appSupportDir = nil;
    NSURL* appDirectory = nil;
    
    if ([possibleURLs count] >= 1) {
        // Use the first directory (if multiple are returned)
        appSupportDir = [possibleURLs objectAtIndex:0];
    }
    
    // If a valid app support directory exists, add the
    // app's bundle ID to it to specify the final directory.
    if (appSupportDir) {
        NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        appDirectory = [appSupportDir URLByAppendingPathComponent:appBundleID];
    }
    
    return appDirectory;
}

@end
