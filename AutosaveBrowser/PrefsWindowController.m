//
//  PrefsWindowController.m
//  AutosaveBrowser
//
//  Created by localhome on 09/06/2016.
//  Copyright (c) 2016 Guardian News & Media. All rights reserved.
//

#import "PrefsWindowController.h"

@interface PrefsWindowController ()

@end

@implementation PrefsWindowController
- (id) init{
    self = [super init];
    [self setKnownPremiereVersions:[NSArray arrayWithObjects:@"8.0", nil]];
    return self;
}
- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) didEndSheet:(id)sheet returnCode:(NSUInteger)returncode contextInfo:(void*)contextInfo
{
    [sheet orderOut:self];
}

- (void) prefsClicked:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *vaultpath = [defaults valueForKey:@"autosavevault_local_path"];
    if(vaultpath==NULL){
        NSLog(@"warning: no vault path set");
        [defaults setValue:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Adobe/Premiere Pro/8.0/Adobe Premiere Pro Auto-Save"]
                    forKey:@"autosavevault_local_path"];
    }
    
    [NSApp beginSheet:[self window] modalForWindow:[self mainWindow]
        modalDelegate:self
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
          contextInfo:nil];
    
    //[NSApp beginSheet:[self prefsPanel] completionHandler:^(NSModalResponse returnCode){ NSLog(@"sheet completed."); }];
    
}

- (void) prefsCloseClicked:(id)sender
{
    [NSApp endSheet:[self window]];
}

- (void)chooseMasterLocationClicked:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            // do something with the url here.
            [defaults setObject:[url path] forKey:@"masterfolder_local_path"];
        }
    }
    
}

@end