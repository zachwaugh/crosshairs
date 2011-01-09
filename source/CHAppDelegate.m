//
//  CrosshairsAppDelegate.m
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 Giant Comet. All rights reserved.
//

#import "CHAppDelegate.h"
#import "DDHotKeyCenter.h"
#import "CHOverlayWindowController.h"
#import "CHPreferencesController.h"
#import "CHPreferences.h"
#import "CHGlobals.h"

@interface CHAppDelegate ()

- (void)showOverlayWindow;
- (void)createStatusItem;
- (void)setupHotkeys;

@end


@implementation CHAppDelegate

@synthesize statusItem, statusMenu;

- (void)dealloc
{
	[[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
	self.statusItem = nil;
	self.statusMenu = nil;
  [overlayController release];
	[preferencesController release];
	
	[super dealloc];
}


// Transform process as early as possible if needed
- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
  if ([CHPreferences showInDock])
  {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  }
}


- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
  // Only show overlay if not launched at login
  NSAppleEventDescriptor *currentEvent = [[NSAppleEventManager sharedAppleEventManager] currentAppleEvent];
  
  if ([[currentEvent paramDescriptorForKeyword:keyAEPropData] enumCodeValue] != keyAELaunchedAsLogInItem)
  {
    [self showOverlayWindow];
    [NSApp activateIgnoringOtherApps:YES];
  }
  
	[self setupHotkeys];
	[self createStatusItem];
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
  [overlayController showWindow:nil];
  
  return YES;
}


- (void)applicationWillUnhide:(NSNotification *)aNotification
{
  [overlayController showWindow:nil];
}


- (void)createStatusItem
{
	// Build the statusbar menu
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	[self.statusItem setImage:[NSImage imageNamed:@"crosshairs_menu_off.png"]];
	[self.statusItem setAlternateImage:[NSImage imageNamed:@"crosshairs_menu_on.png"]];
	[self.statusItem setHighlightMode:YES];
	[self.statusItem setMenu:self.statusMenu];
}


- (void)setupHotkeys
{
	DDHotKeyCenter *hotKeyCenter = [[[DDHotKeyCenter alloc] init] autorelease];
	[hotKeyCenter registerHotKeyWithKeyCode:[CHPreferences globalHotKeyCode] modifierFlags:[CHPreferences globalHotKeyFlags] target:self action:@selector(hotkeyWithEvent:) object:nil];
}


- (void)hotkeyWithEvent:(NSEvent *)event
{
	[self activateApp:nil];
}


- (void)activateApp:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[self showOverlayWindow];
}


- (void)showOverlayWindow
{
  if (overlayController == nil)
  {
    overlayController = [[CHOverlayWindowController alloc] initWithWindowNibName:@"CHOverlayWindowController"];
  }
  
  [overlayController showWindow:self];
}


- (void)showPreferences:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[overlayController hideWindow];
	
	if (preferencesController == nil)
	{
		preferencesController = [[CHPreferencesController alloc] initWithWindowNibName:@"CHPreferencesController"];
	}

	[preferencesController showWindow:sender];
}
                                                                 

@end
