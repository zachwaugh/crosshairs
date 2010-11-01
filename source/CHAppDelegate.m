//
//  CrosshairsAppDelegate.m
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import <Sparkle/Sparkle.h>
#import "CHAppDelegate.h"
#import "DDHotKeyCenter.h"
#import "CHPreferencesController.h"
#import "CHPreferences.h"
#import "CHOverlayView.h"
#import "CHGlobals.h"
#import "NSCursor+Custom.h"

@interface CHAppDelegate ()

- (void)checkForBetaExpiration;
- (void)createStatusItem;
- (void)setupHotkeys;

@end


@implementation CHAppDelegate

@synthesize window, view, statusItem, statusMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[self checkForBetaExpiration];
	[self setupHotkeys];
	[self createStatusItem];
  
  [self activateApp:nil];
  
  [[SUUpdater sharedUpdater] setDelegate:self];
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
	NSDate *expiration = [NSDate dateWithNaturalLanguageString:@"2010-11-14 23:59:00"];
	
	if ([expiration earlierDate:[NSDate date]] == expiration)
	{
		NSLog(@"Beta has expired!");
		NSAlert *alert = [NSAlert alertWithMessageText:@"I'm sorry, this beta version has expired. Please download a new version from http://zachwaugh.com/crosshairs" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
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
	[hotKeyCenter registerHotKeyWithKeyCode:[CHPreferences globalHotKeyCode] modifierFlags:[CHPreferences globalHotKeyFlags] target:self action:@selector(hotkeyWithEvent:) object:nil];
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
  int width = (int)self.view.overlayRect.size.width;
  int height = (int)self.view.overlayRect.size.height;
  NSString *format = [CHPreferences copyFormat];
  
  NSString *dimensions = [format stringByReplacingOccurrencesOfString:@"{w}" withString:[NSString stringWithFormat:@"%d", width]];
  dimensions = [dimensions stringByReplacingOccurrencesOfString:@"{h}" withString:[NSString stringWithFormat:@"%d", height]];
  
	[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	[[NSPasteboard generalPasteboard] setString:dimensions forType:NSStringPboardType];
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
  // Capture screenshot
	CGRect captureRect = NSRectToCGRect(self.view.overlayRect);
	CGImageRef screenShot = CGWindowListCreateImage(captureRect, kCGWindowListOptionOnScreenBelowWindow, [self.window windowNumber], kCGWindowImageDefault);
	NSBitmapImageRep *image = [[[NSBitmapImageRep alloc] initWithCGImage:screenShot] autorelease];
  
  // Build screenshot filename
  int width = (int)self.view.overlayRect.size.width;
  int height = (int)self.view.overlayRect.size.height;
  NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
  [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' h.mm.ss a"];
  NSString *timestamp = [NSString stringWithFormat:@"%@ (%d x %d)", [dateFormatter stringFromDate:[NSDate date]], width, height];
  
  // Write out screenshot png
  [[image representationUsingType:NSPNGFileType properties:nil] writeToFile:[NSString stringWithFormat:@"%@/Desktop/Screen shot %@.png", NSHomeDirectory(), timestamp] atomically:NO];

	CGImageRelease(screenShot);
}


#pragma mark -
#pragma mark Sparkle delegate methods

- (void)updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)update
{
  [self.window orderOut:nil];
}


- (void)updaterDidNotFindUpdate:(SUUpdater *)update
{
  [self.window orderOut:nil];
}                                                                   
                                                                      

@end
