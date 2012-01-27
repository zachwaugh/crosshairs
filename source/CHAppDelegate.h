//
//  CrosshairsAppDelegate.h
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CHOverlayWindowController;
@class CHPreferencesController;
@class CHHelpController;
@class CHWelcomeController;

@interface CHAppDelegate : NSObject <NSApplicationDelegate>
{
	IBOutlet NSMenu *statusMenu;
	NSStatusItem *statusItem;
	
  CHOverlayWindowController *overlayController;
	CHPreferencesController *preferencesController;
  CHHelpController *helpController;
}

@property (retain) NSStatusItem *statusItem;
@property (retain) NSMenu *statusMenu;

- (void)activateApp:(id)sender;
- (void)deactivateApp;
- (void)showPreferences:(id)sender;
- (void)showHelp:(id)sender;

@end
