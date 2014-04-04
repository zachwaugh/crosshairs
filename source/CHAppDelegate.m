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
#import "CHStatusView.h"
#import "CHGlobals.h"

static NSString * const CHAppStoreURL = @"http://itunes.apple.com/us/app/crosshairs/id402446112?mt=12";
static NSString * const CHHelpURL = @"http://giantcomet.com/crosshairs/help";

@interface CHAppDelegate ()

@property (nonatomic, strong) CHOverlayWindowController *overlayController;
@property (nonatomic, strong) CHPreferencesController *preferencesController;

- (void)showOverlayWindow;
- (void)createStatusItem;
- (void)setupHotkeys;

@end

@implementation CHAppDelegate

#pragma mark - App life cycle

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
    // Only show overlay if not launched at login
    NSAppleEventDescriptor *currentEvent = [[NSAppleEventManager sharedAppleEventManager] currentAppleEvent];
    
    [self createStatusItem];
    
    if ([[currentEvent paramDescriptorForKeyword:keyAEPropData] enumCodeValue] != keyAELaunchedAsLogInItem) {
        [self activateApp:nil];
    }
    
	[self setupHotkeys];
    [CHPreferences incrementNumberOfLaunches];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [self.overlayController showWindow:nil];
    
    return YES;
}

- (void)applicationWillUnhide:(NSNotification *)aNotification
{
    [self.overlayController showWindow:nil];
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
    CGFloat width = 29.0;
    CGFloat height = [[NSStatusBar systemStatusBar] thickness];
    
	// Build the statusbar menu
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:width];
    CHStatusView *statusView = [[CHStatusView alloc] initWithFrame:NSMakeRect(0, 0, width, height)];
    statusView.statusMenu = self.statusMenu;
    [self.statusMenu setDelegate:statusView];
    [self.statusItem setView:statusView];
    statusView.statusItem = self.statusItem;
}

- (void)setupHotkeys
{
	DDHotKeyCenter *hotKeyCenter = [[DDHotKeyCenter alloc] init];
	[hotKeyCenter registerHotKeyWithKeyCode:[CHPreferences globalHotKeyCode] modifierFlags:[CHPreferences globalHotKeyFlags] target:self action:@selector(hotkeyWithEvent:) object:nil];
}

- (void)hotkeyWithEvent:(NSEvent *)event
{
    if (self.overlayController.window.isVisible) {
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

- (CHOverlayWindowController *)overlayController
{
    if (!_overlayController) {
        _overlayController = [[CHOverlayWindowController alloc] init];
    }
    
    return _overlayController;
}

- (CHPreferencesController *)preferencesController
{
    if (!_preferencesController) {
        _preferencesController = [[CHPreferencesController alloc] init];
    }
    
    return _preferencesController;
}

- (void)showOverlayWindow
{
    [self.overlayController showWindow:self];
}

- (void)showPreferences:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
    [self.overlayController hideWindow];
	[(CHStatusView *)[self.statusItem view] setState:CHStatusItemInactive];
    
	[self.preferencesController showWindow:sender];
}

- (void)showHelp:(id)sender
{
    [self.overlayController hideWindow];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:CHHelpURL]];
}

- (void)openAppStore:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:CHAppStoreURL]];
}

@end
