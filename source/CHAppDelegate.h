//
//  CrosshairsAppDelegate.h
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CHAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSMenu *statusMenu;

- (IBAction)activateApp:(id)sender;
- (IBAction)deactivateApp;
- (IBAction)showPreferences:(id)sender;
- (IBAction)showHelp:(id)sender;

@end
