//
//  MainWindowController.m
//  AutosaveBrowser
//
//  Created by localhome on 09/06/2016.
//  Copyright (c) 2016 Guardian News & Media. All rights reserved.
//

#import "MainWindowController.h"

@interface MainWindowController ()

@end

@implementation MainWindowController
- (id) init {
    self=[super init];
    [self setOutlineViewData:[NSMutableArray array]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self forKeyPath:@"autosavevault_local_path" options:NSKeyValueObservingOptionNew context:nil];
    
    [self setNsPremiereIcon:[[NSWorkspace sharedWorkspace] iconForFile:@"/Applications/Adobe Premiere Pro CC 2014/Adobe Premiere Pro CC 2014.app"]];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    //[self setOutlineViewData:[NSMutableArray array]];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSLog(@"windowDidLoad");
    [self scanAutosaveVault];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    //NSUserDefaults *defaults = (NSUserDefaults *)object;

    if([keyPath compare:@"autosavevault_local_path"]==NSOrderedSame){
        [self emptyVaultList];
        [self scanAutosaveVault];
    }
}

- (IBAction) restoreProjectClicked:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSError *e=NULL;
    [[self progressBar] startAnimation:self];

    NSString *vaultpath = [defaults valueForKey:@"autosavevault_local_path"];
    if(vaultpath==NULL){
        NSAlert *a=[[NSAlert alloc] init];
        [a setIcon:[NSImage imageNamed:NSImageNameCaution]];
        [a setInformativeText:@"Preferences have not been set up.  Please go to Preferences in the Application menu and set up the autosave vault path then reload the app."];
        [a runModal];
        return;
    }
    
    if([[[self outlineViewController] selectedObjects] count]>1){
        NSAlert *a=[[NSAlert alloc] init];
        [a setMessageText:@"You must select only one item at a time to restore"];
        [a setIcon:[NSImage imageNamed:NSImageNameCaution]];
        [a runModal];
        [[self progressBar] stopAnimation:self];
        return;
    }
    if([[[self outlineViewController] selectedObjects] count]<1){
        NSAlert *a=[[NSAlert alloc] init];
        [a setMessageText:@"You must select an item to restore"];
        [a setIcon:[NSImage imageNamed:NSImageNameCaution]];
        [a runModal];
        [[self progressBar] stopAnimation:self];
        return;
    }

    NSDictionary *selectedEntry = [[[self outlineViewController] selectedObjects] objectAtIndex:0];
    NSString *srcFilename = [selectedEntry objectForKey:@"filepath"];
    if(srcFilename == nil){
        NSAlert *a=[[NSAlert alloc] init];
        [a setMessageText:@"You must select a specific version to restore"];
        [a setIcon:[NSImage imageNamed:NSImageNameCaution]];
        [a runModal];
        [[self progressBar] stopAnimation:self];
        return;
    }
    

    NSString *destFilename = [defaults valueForKey:@"masterfolder_local_path"];
    if(destFilename==NULL){
        NSAlert *a=[[NSAlert alloc] init];
        [a setIcon:[NSImage imageNamed:NSImageNameCaution]];
        [a setInformativeText:@"Preferences have not been set up.  Please go to Preferences in the Application menu and set up the master folder path then try again."];
        [a runModal];
        return;
    }

    destFilename = [destFilename stringByAppendingPathComponent:[selectedEntry valueForKey:@"path"]];

    destFilename = [destFilename stringByAppendingString:@".prproj"];

    NSLog(@"I will copy from %@ to %@",srcFilename,destFilename);

    if([[NSFileManager defaultManager] fileExistsAtPath:destFilename]){
        NSLog(@"Project already exists at %@",destFilename);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //[formatter dateFormatFromTemplate:@"yymmddHHMMSS" options:0 locale:[NSLocale currentLocale]];
        
        [formatter setDateFormat:@"yymmddHHMMSS"];
        NSDate *now = [NSDate date];
        NSString *datestring = [formatter stringFromDate:now];
        NSString *safeHostName = [[[NSHost currentHost] name] stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSString *destBackupFilename = [NSString stringWithFormat:@"%@/%@_%@_%@.prproj",
                                        [defaults valueForKey:@"masterfolder_local_path"],
                                        [selectedEntry valueForKey:@"path"],
                                        safeHostName,
                                        datestring];
        
        NSLog(@"Backing up %@ to %@",destFilename,destBackupFilename);
        
        BOOL result = [[NSFileManager defaultManager] moveItemAtPath:destFilename toPath:destBackupFilename error:&e];
        if(!result){
            NSAlert *a=[NSAlert alertWithError:e];
            [a runModal];
            [[self progressBar] stopAnimation:self];
            return;
        }
    }
    
    BOOL result = [[NSFileManager defaultManager] copyItemAtPath:srcFilename toPath:destFilename error:&e];
    if(!result){
        NSAlert *a=[NSAlert alertWithError:e];
        [a runModal];
        [[self progressBar] stopAnimation:self];
        return;
    }
    
    NSAlert *a=[[NSAlert alloc] init];
    [a setIcon:[NSImage imageNamed:NSImageNameInfo]];
    [a addButtonWithTitle:@"Yes"];
    [a addButtonWithTitle:@"No"];
    [a setMessageText:@"Project has been restored"];
    NSString *alertText = [NSString stringWithFormat:@"The project %@ has been replaced with the autosave version from %@, and the original has been backed up.  Do you want to open the restored project now?",destFilename,[selectedEntry valueForKey:@"updated"]];
    [a setInformativeText:alertText];
    
    NSModalResponse n=[a runModal];
    switch(n){
        case 1000:
        {
            NSLog(@"Attempting to open %@",destFilename);
            NSTask *t = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/open"
                                                 arguments:[NSArray arrayWithObjects:destFilename, nil]
                         ];
            break;
        }
        case 1001:
            NSLog(@"you clicked No");
            break;
        default:
            NSLog(@"unknown click %lu",n);
    }
    [[self progressBar] stopAnimation:self];
}

- (IBAction) cacheProjectClicked:(id)sender
{
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSError *e;
    
    NSDictionary *selectedEntry = [[[self outlineViewController] selectedObjects] objectAtIndex:0];
    NSString *srcFilename = [selectedEntry objectForKey:@"filepath"];
    if(srcFilename == nil){
        NSAlert *a=[[NSAlert alloc] init];
        [a setMessageText:@"You must select a specific version to cache"];
        [a setIcon:[NSImage imageNamed:NSImageNameCaution]];
        [a runModal];
        [[self progressBar] stopAnimation:self];
        return;
    }
    
    NSString *cachepath = [defaults valueForKey:@"cachefolder_local_path"];
    if(cachepath==NULL){
        NSAlert *a=[[NSAlert alloc] init];
        [a setIcon:[NSImage imageNamed:NSImageNameCaution]];
        [a setInformativeText:@"Preferences have not been set up.  Please go to Preferences in the Application menu and set up the cache path then reload the app."];
        [a runModal];
        return;
    }
    
    NSString *fnOnly = [srcFilename lastPathComponent];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter dateFormatFromTemplate:@"yymmddHHMMSS" options:0 locale:[NSLocale currentLocale]];
    
    [formatter setDateFormat:@"yymmddHHMMSS"];
    NSDate *now = [NSDate date];
    NSString *datestring = [formatter stringFromDate:now];
    NSString *safeHostName = [[[NSHost currentHost] name] stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *newFilename = [NSString stringWithFormat:@"%@_%@_%@",datestring,safeHostName,fnOnly];
    
    NSString *destFileName = [cachepath stringByAppendingPathComponent:newFilename];
    
    NSLog(@"cache project: I will copy %@ to %@",srcFilename, destFileName);
    
    bool r=[mgr copyItemAtPath:srcFilename toPath:destFileName error:&e];
    if(!r){
        NSLog(@"%@",e);
        NSAlert *al = [NSAlert alertWithError:e];
        [al runModal];
    }
    
}

- (void) emptyVaultList
{
    [self setOutlineViewData:[NSMutableArray array]];   //set outline data to a blank array
}

- (void) scanAutosaveVault
{
    [self scanAutosaveVault_v80];
}

- (void) addVaultEntryToList:(NSString *)name
                entryVersion:(NSString *)versionString
                  entryMTime:(NSDate *)entryMTime
                    filepath:(NSString *)filepath
{
    NSMutableDictionary *parent_entry=NULL;
    
    NSLog(@"addVaultEntryToList: name %@",name);
    /*is this entry already present? */
    for(NSMutableDictionary *entry in [self outlineViewData]){
        if([[entry objectForKey:@"path"] isEqualToString:name]){
            parent_entry = entry;
            continue;
        }
    }
    
    if(parent_entry==NULL){
        NSLog(@"creating new parent entry");
        parent_entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:name,@"path", [NSMutableArray array], @"child", [self nsPremiereIcon], @"icon", nil];
        [[self outlineViewController] addObject:parent_entry];
    }
    
    NSDictionary *new_subentry = [NSDictionary dictionaryWithObjectsAndKeys:name,@"path",
                                  [NSNumber numberWithInteger:[versionString integerValue]],@"version",
                                  entryMTime, @"updated",
                                  filepath, @"filepath",
                                  [self nsPremiereIcon], @"icon",
                                  nil];
    
    [[parent_entry objectForKey:@"child"] addObject:new_subentry];
    
}

- (void) scanAutosaveVault_v80
{
    NSError *e=NULL;
    NSRegularExpression *autosave_matcher = [NSRegularExpression regularExpressionWithPattern:@"^(.*)-(\\d+).prproj" options:NSRegularExpressionCaseInsensitive error:&e];
    if(autosave_matcher ==NULL){
        NSLog(@"Unable to compile regex: %@",e);
        return;
    }
    
    [[self progressBar] startAnimation:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *vaultpath = [defaults valueForKey:@"autosavevault_local_path"];
    if(vaultpath==NULL){
        NSAlert *a=[[NSAlert alloc] init];
        [a setIcon:[NSImage imageNamed:NSImageNameCaution]];
        [a setInformativeText:@"Preferences have not been set up.  Please go to Preferences in the Application menu and set up the autosave vault path then reload the app."];
        [a runModal];
        return;
    }
    
    [[self outlineViewController] setContent:nil];
    NSLog(@"Scanning %@",vaultpath);
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:vaultpath error:&e];
    if(files==NULL) NSLog(@"%@",e);
    
    for(NSString *path in files){
        NSLog(@"\tGot %@",path);
        NSArray *matches = [autosave_matcher matchesInString:path options:NSMatchingAnchored range:NSMakeRange(0,[path length])];
        if(matches == NULL){
            NSLog(@"no match");
            continue;
        }
        
        for(NSTextCheckingResult *result in matches){
            //NSLog(@"got %d ranges",[result numberOfRanges]);
            NSMutableArray *props=[NSMutableArray arrayWithCapacity:3];
            for(int n=1;n<[result numberOfRanges];++n){ //rangeAtIndex:0 is whole matching string
                [props addObject:[path substringWithRange:[result rangeAtIndex:n]]];
                //NSLog(@"\t\t%@",);
            }
            NSString *filepath = [vaultpath stringByAppendingPathComponent:path];
            NSDictionary *fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:filepath error:&e];
            
            [self addVaultEntryToList:[props objectAtIndex:0]
                         entryVersion:[props objectAtIndex:1]
                           entryMTime:[fileAttribs objectForKey:NSFileModificationDate]
                             filepath:filepath
             ];
            
        }
    }
    [[self outlineViewController] setContent:[self outlineViewData]];
    [[self progressBar] stopAnimation:self];
}
@end
