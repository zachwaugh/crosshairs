//
//  CrosshairsAppDelegate.h
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CHOverlayWindow;
@class CHOverlayView;
@class CHPreferencesController;

@interface CHAppDelegate : NSObject <NSApplicationDelegate>
{
	CHOverlayWindow *window;
	CHOverlayView *view;
	NSStatusItem *statusItem;
	IBOutlet NSMenu *statusMenu;
	CHPreferencesController *preferencesController;
}

@property (assign) IBOutlet CHOverlayWindow *window;
@property (assign) IBOutlet CHOverlayView *view;
@property (retain) NSStatusItem *statusItem;
@property (retain) NSMenu *statusMenu;

- (void)activateApp:(id)sender;
- (void)showPreferences:(id)sender;
- (void)openWebsite:(id)sender;
- (void)copyDimensionsToClipboard;
- (void)checkForUpdates:(id)sender;
- (void)takeScreenshot;

@end
