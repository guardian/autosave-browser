//
//  MainWindowController.h
//  AutosaveBrowser
//
//  Created by localhome on 09/06/2016.
//  Copyright (c) 2016 Guardian News & Media. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainWindowController : NSWindowController
- (IBAction) restoreProjectClicked:(id)sender;
- (IBAction) cacheProjectClicked:(id)sender;

@property (strong) IBOutlet NSMutableArray *outlineViewData;
@property (strong) IBOutlet NSArray *knownPremiereVersions;

@property (weak) IBOutlet NSPanel *prefsPanel;
@property (weak) IBOutlet NSTreeController *outlineViewController;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSWindow *mainWindow;

- (void) scanAutosaveVault;
- (IBAction) prefsClicked:(id)sender;
- (IBAction) prefsCloseClicked:(id)sender;
@end
