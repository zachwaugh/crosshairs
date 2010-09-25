//
//  CrosshairsAppDelegate.m
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CrosshairsAppDelegate.h"

@implementation CrosshairsAppDelegate

@synthesize window, statusItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self.window setFrame:[[NSScreen mainScreen] frame] display:YES];
	//[NSApp preventWindowOrdering];
//	[NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask 
//                                         handler:^{
//																					 [NSApp activateIgnoringOtherApps:YES];
//																					 [mainWindowController showWindow:self];
//																				 }];
	
	// Create an NSStatusItem.
	float width = 30.0;
	float height = [[NSStatusBar systemStatusBar] thickness];
	NSRect viewFrame = NSMakeRect(0, 0, width, height);
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:width];
	NSImageView *imageView = [[[NSImageView alloc] initWithFrame:viewFrame] autorelease];
	imageView.image = [NSImage imageNamed:@"crosshairs.png"];
	[statusItem setView:imageView];
}


- (void)dealloc
{
	[[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
	self.statusItem = nil;
	[super dealloc];
}

@end
