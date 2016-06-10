//
//  PrefsWindowController.h
//  AutosaveBrowser
//
//  Created by localhome on 09/06/2016.
//  Copyright (c) 2016 Guardian News & Media. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PrefsWindowController : NSWindowController

@property (weak) IBOutlet NSPanel *prefsPanel;
@property (weak) IBOutlet NSWindow *mainWindow;
@property (weak) IBOutlet NSArrayController *knownPremiereVersionsController;

@property (strong) NSArray *knownPremiereVersions;

- (IBAction) prefsClicked:(id)sender;
- (IBAction) prefsCloseClicked:(id)sender;

- (IBAction) resetToDefaultClicked:(id)sender;
- (IBAction) chooseVaultLocationClicked:(id)sender;
- (IBAction) chooseMasterLocationClicked:(id)sender;

@end
