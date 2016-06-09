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
    [[self mainWindowController] setKnownPremiereVersions:[NSArray arrayWithObjects:@"8.0", nil]];
    // Insert code here to initialize your application
    [[self mainWindowController] scanAutosaveVault];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
