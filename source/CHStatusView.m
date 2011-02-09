//
//  CHStatusView.m
//  Crosshairs
//
//  Created by Zach Waugh on 2/8/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import "CHStatusView.h"
#import "CHAppDelegate.h"

@implementation CHStatusView

@synthesize statusItem, statusMenu;

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];

  if (self)
  {
    inactiveImage = [[NSImage imageNamed:@"crosshairs_menu_inactive.png"] retain];
    activeImage = [[NSImage imageNamed:@"crosshairs_menu_active.png"] retain];
    highlightImage = [[NSImage imageNamed:@"crosshairs_menu_highlight.png"] retain];
    currentState = CHStatusItemInactive;
  }
  
  return self;
}


- (void)dealloc
{
  [inactiveImage release];
  [activeImage release];
  [highlightImage release];
  
  self.statusItem = nil;
  self.statusMenu = nil;
  
  [super dealloc];
}


- (void)drawRect:(NSRect)dirtyRect
{
  NSSize imageSize;
  
  if (currentState == CHStatusItemInactive)
  {
    imageSize = [inactiveImage size];
    [inactiveImage drawInRect:NSMakeRect(round(([self bounds].size.width - imageSize.width) / 2), round(([self bounds].size.height - imageSize.height) / 2), imageSize.width, imageSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  }
  else if (currentState == CHStatusItemActive)
  {
    imageSize = [activeImage size];
    [activeImage drawInRect:NSMakeRect(round(([self bounds].size.width - imageSize.width) / 2), round(([self bounds].size.height - imageSize.height) / 2), imageSize.width, imageSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  }
  else if (currentState == CHStatusItemHighlighted)
  {
    imageSize = [highlightImage size];
    [[NSColor selectedMenuItemColor] set];
    NSRectFill([self bounds]);
    [highlightImage drawInRect:NSMakeRect(round(([self bounds].size.width - imageSize.width) / 2), round(([self bounds].size.height - imageSize.height) / 2), imageSize.width, imageSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  }
}


- (void)mouseDown:(NSEvent *)event
{
  if ([event modifierFlags] & NSControlKeyMask)
  {
    [self setState:CHStatusItemHighlighted];
    [self.statusItem popUpStatusItemMenu:self.statusMenu];
  }
  else
  {
    [self setState:CHStatusItemActive];
    [(CHAppDelegate *)[NSApp delegate] activateApp:self];
  }
}


- (void)rightMouseDown:(NSEvent *)event
{
  [self setState:CHStatusItemHighlighted];
  [self.statusItem popUpStatusItemMenu:self.statusMenu];
}


- (void)rightMouseUp:(NSEvent *)event
{
  [self setState:CHStatusItemInactive];
}


- (void)menuDidClose:(NSMenu *)menu
{
  [self setState:CHStatusItemInactive];
}


- (void)setState:(CHStatusItemState)state
{
  currentState = state;
  [self setNeedsDisplay:YES];
}

@end
