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
#import "CHPreferences.h"
#import "CHOverlayView.h"
#import "CHGlobals.h"
#import <Sparkle/Sparkle.h>

@interface CHAppDelegate ()

- (void)checkForBetaExpiration;
- (void)createStatusItem;
- (void)setupHotkeys;

@end


@implementation CHAppDelegate

@synthesize window, view, statusItem, statusMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[CHPreferences registerDefaults];
	[self checkForBetaExpiration];	
	[self setupHotkeys];
	[self createStatusItem];
	[self activateApp:nil];
}


- (void)dealloc
{
	[[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
	self.statusItem = nil;
	self.statusMenu = nil;
	[preferencesController release];
	
	[super dealloc];
}


- (void)checkForBetaExpiration
{
	NSDate *expiration = [NSDate dateWithNaturalLanguageString:@"2010-11-10 23:59:00"];
	
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


- (void)setupHotkeys
{
	DDHotKeyCenter *hotKeyCenter = [[[DDHotKeyCenter alloc] init] autorelease];
	[hotKeyCenter registerHotKeyWithKeyCode:19 modifierFlags:(NSShiftKeyMask | NSCommandKeyMask) target:self action:@selector(hotkeyWithEvent:) object:nil];
	[hotKeyCenter registerHotKeyWithKeyCode:84 modifierFlags:(NSShiftKeyMask | NSCommandKeyMask) target:self action:@selector(hotkeyWithEvent:) object:nil];
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
	[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	[[NSPasteboard generalPasteboard] setString:[NSString stringWithFormat:@"%d %d", (int)self.view.overlayRect.size.width, (int)self.view.overlayRect.size.height] forType:NSStringPboardType];
}


- (void)openWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://zachwaugh.com/crosshairs?ref=app"]];
}


- (void)showPreferences:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[self.window orderOut:sender];
	
	if (preferencesController == nil)
	{
		preferencesController = [[CHPreferencesController alloc] initWithWindowNibName:@"CHPreferencesController"];
	}

	[preferencesController showWindow:sender];
}


#pragma mark -
#pragma mark Screenshot

- (void)takeScreenshot
{
	CGRect captureRect = NSRectToCGRect(self.view.overlayRect);
	captureRect.origin.y = NSMaxY([[self.window screen] frame]) - NSMaxY(self.view.overlayRect);

	// adjust if there are multiple displays
//	if ([[NSScreen screens] count] > 1)
//	{
//		float windowHeight = NSHeight([self.window frame]);
//		float overlayHeight = NSHeight(captureRect);
//		
//		if (overlayHeight < windowHeight)
//		{
//			float adjustment = windowHeight - overlayHeight;
//			NSLog(@"adjustment: %f, captureRect origin y: %f", adjustment, captureRect.origin.y);
//			captureRect.origin.y -= adjustment + (adjustment + captureRect.origin.y);
//		}
//	}

	
	CGImageRef screenShot = CGWindowListCreateImage(captureRect, kCGWindowListOptionOnScreenBelowWindow, [self.window windowNumber], kCGWindowImageDefault);
	NSBitmapImageRep *image = [[[NSBitmapImageRep alloc] initWithCGImage:screenShot] autorelease];
	[[image representationUsingType:NSPNGFileType properties:nil] writeToFile:[NSString stringWithFormat:@"%@/Desktop/Screen shot %@.png", NSHomeDirectory(), [NSDate date]] atomically:NO];

	CGImageRelease(screenShot);
}

@end
