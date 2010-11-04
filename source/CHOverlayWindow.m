//
//  CHWindow.m
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CHOverlayWindow.h"
#import "CHOverlayWindowController.h"


@implementation CHOverlayWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag 
{	
	NSWindow *window = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	
	[window setBackgroundColor:[NSColor clearColor]];
	//[window setBackgroundColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.25]];
	[window setLevel:NSStatusWindowLevel];
	[window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
	[window setAlphaValue:1.0];
	[window setOpaque:NO];
	[window setHasShadow:NO];
	[window setMovableByWindowBackground:NO];
	[window setIgnoresMouseEvents:NO];
	[window setAcceptsMouseMovedEvents:YES];
	
	return window;
}


- (BOOL)canBecomeKeyWindow
{
	return YES;
}


- (void)awakeFromNib
{
	NSRect windowRect = NSZeroRect;
	
	for (NSScreen *screen in [NSScreen screens])
	{
		windowRect = NSUnionRect([screen frame], windowRect);
	}
	
	[self setFrame:windowRect display:YES animate:NO];
}


- (void)keyDown:(NSEvent *)event
{
	if ([event keyCode] == ESC_KEY)
	{
		[self orderOut:nil];
		return;
	}
	else if ([event keyCode] == SPACE_KEY)
	{
		[(CHOverlayWindowController *)self.delegate takeScreenshot];
		return;
	}
	else
	{
		[super keyDown:event];
	}
}


- (BOOL)performKeyEquivalent:(NSEvent *)event
{
	NSString *characters = [event charactersIgnoringModifiers];
	
	// cmd-c - copy dimensions
	if (([event modifierFlags] & NSCommandKeyMask) && [characters length] == 1 && [characters isEqualToString:@"c"])
	{
		[(CHOverlayWindowController *)self.delegate copyDimensionsToClipboard];
		return YES;
	}
	
	return [super performKeyEquivalent:event];
}

@end
