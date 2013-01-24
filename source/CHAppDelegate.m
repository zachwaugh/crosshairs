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
//#import "CHHelpController.h"
#import "CHPreferences.h"
#import "CHStatusView.h"
#import "CHGlobals.h"
#import "NSString+MD5.h"

#define TRIAL_INTERVAL (10 * 86400)
#define TRIAL_SALT @"02818f30cf5036e78eab4ed03bab41afb8b8e323"
#define APP_STORE_URL @"http://itunes.apple.com/us/app/crosshairs/id402446112?mt=12"
#define HELP_URL @"http://giantcomet.com/crosshairs/help"

@interface CHAppDelegate ()

- (void)showOverlayWindow;
- (void)createStatusItem;
- (void)setupHotkeys;

// trial
- (void)validateTrial;
- (void)openAppStore:(id)sender;
- (BOOL)hasTrialExpired;
- (int)daysLeftInTrial;

@end


@implementation CHAppDelegate

@synthesize statusItem, statusMenu;

- (void)dealloc
{
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
  [CHPreferences registerDefaults];
  
  if ([CHPreferences showInDock]) {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
  #ifdef TRIAL
    [self validateTrial];
  #endif
  
  // Only show overlay if not launched at login
  NSAppleEventDescriptor *currentEvent = [[NSAppleEventManager sharedAppleEventManager] currentAppleEvent];
  
  [self createStatusItem];
  
  if ([[currentEvent paramDescriptorForKeyword:keyAEPropData] enumCodeValue] != keyAELaunchedAsLogInItem)
  {
    [self activateApp:nil];
  }
  
	[self setupHotkeys];
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
	[[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}

#pragma mark -

- (void)createStatusItem
{
  // Create an NSStatusItem.
  float width = 29.0;
  float height = [[NSStatusBar systemStatusBar] thickness];

	// Build the statusbar menu
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:width];
  CHStatusView *statusView = [[[CHStatusView alloc] initWithFrame:NSMakeRect(0, 0, width, height)] autorelease];
  statusView.statusMenu = self.statusMenu;
  [self.statusMenu setDelegate:statusView];
  [self.statusItem setView:statusView];
  statusView.statusItem = self.statusItem;
}

- (void)setupHotkeys
{
	DDHotKeyCenter *hotKeyCenter = [[[DDHotKeyCenter alloc] init] autorelease];
	[hotKeyCenter registerHotKeyWithKeyCode:[CHPreferences globalHotKeyCode] modifierFlags:[CHPreferences globalHotKeyFlags] target:self action:@selector(hotkeyWithEvent:) object:nil];
}

- (void)hotkeyWithEvent:(NSEvent *)event
{
  if ([[overlayController window] isVisible]) {
    [self deactivateApp];
  } else {
    [self activateApp:nil];  
  }	
}

- (void)activateApp:(id)sender
{
  if ([CHPreferences activateApp]) {
    [NSApp activateIgnoringOtherApps:YES];
  }
	
	[self showOverlayWindow];
  [(CHStatusView *)[self.statusItem view] setState:CHStatusItemActive];
}

- (void)deactivateApp
{
  [(CHStatusView *)[self.statusItem view] setState:CHStatusItemInactive];
  [NSApp hide:nil];
}

- (void)showOverlayWindow
{
  if (overlayController == nil) {
    overlayController = [[CHOverlayWindowController alloc] initWithWindowNibName:@"CHOverlayWindowController"];
  }
  
  [overlayController showWindow:self];
}

- (void)showPreferences:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
  [overlayController hideWindow];
	[(CHStatusView *)[self.statusItem view] setState:CHStatusItemInactive];
  
	if (preferencesController == nil) {
		preferencesController = [[CHPreferencesController alloc] initWithWindowNibName:@"CHPreferencesController"];
	}

	[preferencesController showWindow:sender];
}

- (void)showHelp:(id)sender
{
  [overlayController hideWindow];
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:HELP_URL]];
}

#pragma mark -
#pragma mark Trial support

- (void)validateTrial
{
  // First launch
  if ([CHPreferences numberOfLaunches] == 0 && [CHPreferences trialHash] == nil) {
    NSDate *launchDate = [NSDate date];
    //NSDate *launchDate = [NSDate dateWithTimeIntervalSinceNow:86400 * -9];
    [CHPreferences setFirstLaunchDate:launchDate];
    [CHPreferences setTrialHash:[NSString md5:[NSString stringWithFormat:@"%@%@", TRIAL_SALT, [launchDate description]]]];
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
}

- (void)openAppStore:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:APP_STORE_URL]];
  
  // track purchase
  //[[[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:4567/trialbuy"]] delegate:nil startImmediately:YES] autorelease];
}

- (int)daysLeftInTrial
{
  NSDate *firstLaunch = [CHPreferences firstLaunchDate];
  int delta = [[NSDate date] timeIntervalSinceDate:firstLaunch];  
  float days = (TRIAL_INTERVAL - delta) / 86400.0;
  
  return ceil(days);
}

- (BOOL)hasTrialExpired
{
  NSString *trialHash = [CHPreferences trialHash];
  NSString *date = [[CHPreferences firstLaunchDate] description];
  NSString *hash = [NSString md5:[NSString stringWithFormat:@"%@%@", TRIAL_SALT, date]];
  
  BOOL tampered = ([trialHash isEqualToString:hash]) ? NO : YES;
  BOOL expired = ([self daysLeftInTrial] > 0) ? NO : YES;
  
  return (tampered || expired);
}

@end
