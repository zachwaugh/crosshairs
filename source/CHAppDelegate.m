//
//  CrosshairsAppDelegate.m
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CHAppDelegate.h"
#import "CHStatusItemView.h"

@implementation CHAppDelegate

@synthesize window, statusItem, statusMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSRect windowRect = NSZeroRect;
	
	for (NSScreen *screen in [NSScreen screens])
	{
		windowRect = NSUnionRect([screen frame], windowRect);
	}
	
	[self.window setFrame:windowRect display:YES animate:NO];

	
	//[NSApp preventWindowOrdering];
//	[NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask 
//                                         handler:^{
//																					 [NSApp activateIgnoringOtherApps:YES];
//																					 [mainWindowController showWindow:self];
//																				 }];
	
	// Build the statusbar menu
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	CHStatusItemView *statusItemView = [[[CHStatusItemView alloc] initWithFrame:NSMakeRect(0, 0, [[NSStatusBar systemStatusBar] thickness], [[NSStatusBar systemStatusBar] thickness])] autorelease];
	statusItemView.delegate = self;
	[self.statusItem setView:statusItemView];
}


- (void)dealloc
{
	[[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
	self.statusItem = nil;
	self.statusMenu = nil;
	
	[super dealloc];
}



- (void)didClickStatusItem
{
	if ([self.window isVisible] && [NSApp isActive])
	{
		[NSApp hide:nil];
	}
	else
	{	
		[NSApp activateIgnoringOtherApps:YES];
	}
}


- (void)didRightClickStatusItem:(NSEvent *)event
{
	[self.statusItem popUpStatusItemMenu:self.statusMenu];
}

@end
