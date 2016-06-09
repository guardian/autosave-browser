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
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    //[self setOutlineViewData:[NSMutableArray array]];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSLog(@"windowDidLoad");
    [self scanAutosaveVault];
}


- (IBAction) restoreProjectClicked:(id)sender
{
    [[self progressBar] startAnimation:self];
    NSMutableDictionary *entry = [[self outlineViewController] newObject];
    [entry setValue:@"entry" forKey:@"path"];
    [entry setValue:@"1" forKey:@"version"];
    [entry setValue:@"blah" forKey:@"updated"];
    NSLog(@"%@",entry);
    [[self outlineViewController] addObject:entry];
}

- (IBAction) cacheProjectClicked:(id)sender
{
    [[self outlineViewController] addChild:sender];
}

- (void) scanAutosaveVault
{
    [self scanAutosaveVault_v80];
}

- (void) addVaultEntryToList:(NSString *)name entryVersion:(NSString *)versionString entryMTime:(NSDate *)entryMTime
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
        parent_entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:name,@"path", [NSMutableArray array], @"child", nil];
        [[self outlineViewController] addObject:parent_entry];
    }
    
    NSDictionary *new_subentry = [NSDictionary dictionaryWithObjectsAndKeys:versionString,@"version",[entryMTime description], @"updated", nil];
    
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
        NSLog(@"warning: no vault path set");
        vaultpath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Adobe/Premiere Pro/8.0/Adobe Premiere Pro Auto-Save"];
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
            NSDictionary *fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:[vaultpath stringByAppendingPathComponent:path] error:&e];
            
            [self addVaultEntryToList:[props objectAtIndex:0] entryVersion:[props objectAtIndex:1] entryMTime:[fileAttribs objectForKey:NSFileModificationDate]];
            
        }
    }
    [[self outlineViewController] setContent:[self outlineViewData]];
    [[self progressBar] stopAnimation:self];
}
@end
