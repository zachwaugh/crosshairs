//
//  CrosshairsAppDelegate.m
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CHAppDelegate.h"
#import "DDHotKeyCenter.h"
#import "CHPreferencesController.h"
#import "CHOverlayView.h"
#import <Sparkle/Sparkle.h>

@interface CHAppDelegate ()

- (void)checkForBetaExpiration;
- (void)createStatusItem;

@end


@implementation CHAppDelegate

@synthesize window, view, statusItem, statusMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self checkForBetaExpiration];
	
	NSRect windowRect = NSZeroRect;
	
	for (NSScreen *screen in [NSScreen screens])
	{
		windowRect = NSUnionRect([screen frame], windowRect);
	}
	
	NSLog(@"windowRect: %@", NSStringFromRect(windowRect));
	[self.window setFrame:windowRect display:YES animate:NO];
	
	DDHotKeyCenter *hotKeyCenter = [[[DDHotKeyCenter alloc] init] autorelease];
	[hotKeyCenter registerHotKeyWithKeyCode:19 modifierFlags:(NSShiftKeyMask | NSCommandKeyMask) target:self action:@selector(hotkeyWithEvent:) object:nil];
	[hotKeyCenter registerHotKeyWithKeyCode:84 modifierFlags:(NSShiftKeyMask | NSCommandKeyMask) target:self action:@selector(hotkeyWithEvent:) object:nil];

	[self createStatusItem];
	[self activateApp:nil];
}


- (void)dealloc
{
	[[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
	self.statusItem = nil;
	self.statusMenu = nil;
	
	[super dealloc];
}


- (void)checkForBetaExpiration
{
	NSDate *expiration = [NSDate dateWithNaturalLanguageString:@"2010-11-01 23:59:00"];
	
	if ([expiration earlierDate:[NSDate date]] == expiration)
	{
		NSLog(@"Beta has expired!");
		NSAlert *alert = [NSAlert alertWithMessageText:@"I'm sorry, this beta version has expired. Please download a new version" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
		[alert runModal];
		[NSApp terminate:nil];
	}
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


- (void)checkForUpdates:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[self.window orderOut:sender];
	[[SUUpdater sharedUpdater] checkForUpdates:sender];
}


- (void)hotkeyWithEvent:(NSEvent *)event
{
	[NSApp activateIgnoringOtherApps:YES];
	[self.window makeKeyAndOrderFront:nil];
}


- (void)activateApp:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[self.window makeKeyAndOrderFront:nil];
}


- (void)copyDimensionsToClipboard
{
	NSLog(@"copyDimensionsToClipboard: %@", NSStringFromRect(self.view.overlayRect));
	[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	[[NSPasteboard generalPasteboard] setString:[NSString stringWithFormat:@"%dx%d", (int)self.view.overlayRect.size.width, (int)self.view.overlayRect.size.height] forType:NSStringPboardType];
}


- (void)openWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://zachwaugh.com/crosshairs?ref=app"]];
}


- (void)showPreferences:(id)sender
{
	CHPreferencesController *preferencesController = [[[CHPreferencesController alloc] initWithWindowNibName:@"CHPreferencesController"] autorelease];
	[preferencesController showWindow:sender];
}


#pragma mark -
#pragma mark Screenshot

- (void)takeScreenshot
{	
	CGRect captureRect = NSRectToCGRect(self.view.overlayRect);
	NSLog(@"captureRect: %@", NSStringFromRect(captureRect));
	float windowHeight = NSHeight([self.window frame]);
	float overlayHeight = NSHeight(captureRect);
	
	if (overlayHeight < windowHeight)
	{
		float adjustment = windowHeight - overlayHeight;
		NSLog(@"adjustment: %f, captureRect origin y: %f", adjustment, captureRect.origin.y);
		captureRect.origin.y -= adjustment + (adjustment + captureRect.origin.y);
	}
	
	CGImageRef screenShot = CGWindowListCreateImage(captureRect, kCGWindowListOptionOnScreenBelowWindow, [self.window windowNumber], kCGWindowImageDefault);
	NSBitmapImageRep *image = [[[NSBitmapImageRep alloc] initWithCGImage:screenShot] autorelease];
	[[image representationUsingType:NSPNGFileType properties:nil] writeToFile:[NSString stringWithFormat:@"%@/Desktop/Screen shot %@.png", NSHomeDirectory(), [NSDate date]] atomically:NO];

	CGImageRelease(screenShot);
}

@end
