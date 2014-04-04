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

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    _state = CHStatusItemDefault;
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (self.state == CHStatusItemHighlighted) {
        [[NSColor selectedMenuItemColor] set];
        NSRectFill(self.bounds);
    }

    NSImage *image = [self imageForState:self.state];
    NSRect imageRect = NSMakeRect(round((self.bounds.size.width - image.size.width) / 2), round((self.bounds.size.height - image.size.height) / 2), image.size.width, image.size.height);
    [image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

- (void)mouseDown:(NSEvent *)event
{
    if ([event modifierFlags] & NSControlKeyMask) {
        [self setState:CHStatusItemHighlighted];
        [self.statusItem popUpStatusItemMenu:self.statusMenu];
    } else {
        [self setState:CHStatusItemActive];
        [(CHAppDelegate *)[NSApp delegate] activateApp:self];
    }
}

- (void)rightMouseDown:(NSEvent *)event
{
    self.state = CHStatusItemHighlighted;
    [self.statusItem popUpStatusItemMenu:self.statusMenu];
}

- (void)rightMouseUp:(NSEvent *)event
{
    self.state = CHStatusItemDefault;
}

- (void)menuDidClose:(NSMenu *)menu
{
    self.state = CHStatusItemDefault;
}

- (void)setState:(CHStatusItemState)state
{
    _state = state;
    [self setNeedsDisplay:YES];
}

- (NSImage *)imageForState:(CHStatusItemState)state
{
    switch (state) {
        case CHStatusItemHighlighted:
            return [NSImage imageNamed:@"menu_highlight"];
            break;
        case CHStatusItemActive:
            return [NSImage imageNamed:@"menu_active"];
            break;
        default:
            return [NSImage imageNamed:@"menu_default"];
            break;
    }
}

@end
