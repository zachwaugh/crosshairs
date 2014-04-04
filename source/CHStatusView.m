//
//  CHStatusView.m
//  Crosshairs
//
//  Created by Zach Waugh on 2/8/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import "CHStatusView.h"
#import "CHAppDelegate.h"

@interface CHStatusView ()

@property (nonatomic, strong) NSImage *defaultImage;
@property (nonatomic, strong) NSImage *activeImage;
@property (nonatomic, strong) NSImage *highlightImage;

@end

@implementation CHStatusView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    _defaultImage = [NSImage imageNamed:@"menu_default"];
    _activeImage = [NSImage imageNamed:@"menu_active"];
    _highlightImage = [NSImage imageNamed:@"menu_highlight"];
    _state = CHStatusItemDefault;
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSSize imageSize;
    
    if (self.state == CHStatusItemDefault) {
        imageSize = self.defaultImage.size;
        [self.defaultImage drawInRect:NSMakeRect(round(([self bounds].size.width - imageSize.width) / 2), round(([self bounds].size.height - imageSize.height) / 2), imageSize.width, imageSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    } else if (self.state == CHStatusItemActive) {
        imageSize = [self.activeImage size];
        [self.activeImage drawInRect:NSMakeRect(round(([self bounds].size.width - imageSize.width) / 2), round(([self bounds].size.height - imageSize.height) / 2), imageSize.width, imageSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    } else if (self.state == CHStatusItemHighlighted) {
        imageSize = [self.highlightImage size];
        [[NSColor selectedMenuItemColor] set];
        NSRectFill([self bounds]);
        [self.highlightImage drawInRect:NSMakeRect(round(([self bounds].size.width - imageSize.width) / 2), round(([self bounds].size.height - imageSize.height) / 2), imageSize.width, imageSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
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
    [self setState:CHStatusItemHighlighted];
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

@end
