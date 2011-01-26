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


#define TRIAL_INTERVAL (7 * 86400)
#define APP_STORE_URL @"http://itunes.apple.com/us/app/crosshairs/id402446112?mt=12"


@interface CHAppDelegate ()

- (void)showOverlayWindow;
- (void)createStatusItem;
- (void)setupHotkeys;

// trial
- (void)openAppStore:(id)sender;
- (BOOL)hasTrialExpired;
- (int)daysLeftInTrial;

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


#pragma mark -
#pragma mark App life cycle


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
  #ifdef TRIAL
  
    // First launch
    if ([CHPreferences numberOfLaunches] == 0)
    {
      [CHPreferences setFirstLaunchDate:[NSDate date]];
    }
    
    if ([self hasTrialExpired])
    {
      NSAlert *alert = [NSAlert alertWithMessageText:@"I'm sorry, your trial has expired. You can purchase Crosshairs on the Mac App Store by clicking the Buy Now button." defaultButton:@"Buy Now" alternateButton:@"Quit" otherButton:nil informativeTextWithFormat:@""];
      NSInteger button = [alert runModal];
      
      if (button == NSAlertDefaultReturn)
      {
        [self openAppStore:nil];
      }
      
      [NSApp terminate:nil];           
    }
    
    int days = [self daysLeftInTrial];
    NSString *message = [NSString stringWithFormat:@"%d day%@ left in trial. Buy now!", days, (days > 1) ? @"s" : @""];
    
    NSMenuItem *trial = [[[NSMenuItem alloc] initWithTitle:message action:@selector(openAppStore:) keyEquivalent:@""] autorelease];
    [trial setTarget:self];
    [self.statusMenu insertItem:trial atIndex:0];
    [self.statusMenu insertItem:[NSMenuItem separatorItem] atIndex:1];
  #endif
  
  
  // Only show overlay if not launched at login
  NSAppleEventDescriptor *currentEvent = [[NSAppleEventManager sharedAppleEventManager] currentAppleEvent];
  
  if ([[currentEvent paramDescriptorForKeyword:keyAEPropData] enumCodeValue] != keyAELaunchedAsLogInItem)
  {
    [self showOverlayWindow];
    [NSApp activateIgnoringOtherApps:YES];
  }
  
	[self setupHotkeys];
	[self createStatusItem];
  [CHPreferences incrementNumberOfLaunches];
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


- (void)applicationWillTerminate:(NSNotification *)notification
{
  [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark -

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


#pragma mark -
#pragma mark Trial support

- (void)openAppStore:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:APP_STORE_URL]];
}


- (int)daysLeftInTrial
{
  NSDate *firstLaunch = [CHPreferences firstLaunchDate];
  //firstLaunch = [NSDate dateWithTimeIntervalSinceNow:(86400 * 7) - 3600];
  
  int delta = [[NSDate date] timeIntervalSinceDate:firstLaunch];
  
  float days = (TRIAL_INTERVAL - delta) / 86400.0;
  NSLog(@"delta: %d, days: %f", delta, days);
  
  return ceil(days);
}


- (BOOL)hasTrialExpired
{
  return ([self daysLeftInTrial] > 0) ? NO : YES;
}


@end
