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
    [self prefsChooseLocationClicked:sender defaultsKey:@"masterfolder_local_path"];
}

- (IBAction) chooseVaultLocationClicked:(id)sender
{
    [self prefsChooseLocationClicked:sender defaultsKey:@"autosavevault_local_path"];
}

- (void)prefsChooseLocationClicked:(id)sender defaultsKey:(NSString *)defaultsKey
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
            [defaults setObject:[url path] forKey:defaultsKey];
        }
    }
    
}

- (IBAction) resetToDefaultClicked:(id)sender
{
    NSString *versionString = [[[self knownPremiereVersionsController] selectedObjects] objectAtIndex:0];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([versionString compare:@"8.0"]==NSOrderedSame){
        NSString *vaultpath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Adobe/Premiere Pro/8.0/Adobe Premiere Pro Auto-Save"];
        [defaults setValue:vaultpath forKey:@"autosavevault_local_path"];
    } else {
        NSAlert *a=[[NSAlert alloc] init];
        [a setMessageText:@"Unknown premiere version"];
        NSString *infotext = [NSString stringWithFormat:@"I don't know how to manage autosaves for premiere version %@", versionString];
        [a setInformativeText:infotext];
        [a setIcon:[NSImage imageNamed:NSImageNameCaution]];
        [a runModal];
    }
}
@end
