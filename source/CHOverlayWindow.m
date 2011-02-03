//
//  CHWindow.m
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CHOverlayWindow.h"
#import "CHOverlayWindowController.h"

#define ESC_KEY 53

@implementation CHOverlayWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag 
{	
	NSPanel *window = [super initWithContentRect:contentRect styleMask:(NSBorderlessWindowMask | NSNonactivatingPanelMask) backing:NSBackingStoreBuffered defer:NO];
	
	[window setBackgroundColor:[NSColor clearColor]];
	//[window setBackgroundColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.25]];
	[window setLevel:NSStatusWindowLevel];
	[window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
	[window setAlphaValue:1.0];
	[window setOpaque:NO];
	[window setHasShadow:NO];
	[window setMovableByWindowBackground:NO];
  //[window setBecomesKeyOnlyIfNeeded:NO];
	[window setIgnoresMouseEvents:NO];
	//[window setAcceptsMouseMovedEvents:YES];
	
	return window;
}


- (BOOL)canBecomeKeyWindow
{
	return YES;
}


//- (BOOL)canBecomeMainWindow
//{
//  return YES;
//}


//- (void)sendEvent:(NSEvent *)event
//{
//  NSLog(@"sendEvent: %@", event);
//  [super sendEvent:event];
//}


- (void)awakeFromNib
{
	NSRect windowRect = NSZeroRect;
	
	for (NSScreen *screen in [NSScreen screens])
	{
		windowRect = NSUnionRect([screen frame], windowRect);
	}
	
	[self setFrame:windowRect display:YES animate:NO];
}


- (BOOL)performKeyEquivalent:(NSEvent *)event
{
	NSLog(@"(CHOverlayWindow) performKeyEquivalent: %@, %c", [event characters], [event keyCode]);
	NSString *characters = [event charactersIgnoringModifiers];

	if (([event modifierFlags] & NSCommandKeyMask) && [characters length] == 1 && [characters isEqualToString:@"c"])
	{
		[(CHOverlayWindowController *)[self delegate] copyDimensionsToClipboard];
		return YES;
	}
	else
	{
		return [super performKeyEquivalent:event];
	}
}


@end
