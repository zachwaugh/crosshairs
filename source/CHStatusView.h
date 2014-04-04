//
//  CHStatusView.h
//  Crosshairs
//
//  Created by Zach Waugh on 2/8/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CHGlobals.h"

@interface CHStatusView : NSView <NSMenuDelegate>
{
    NSStatusItem *statusItem;
    CHStatusItemState currentState;
    NSMenu *statusMenu;
    NSImage *inactiveImage;
    NSImage *activeImage;
    NSImage *highlightImage;
}

@property (strong) NSStatusItem *statusItem;
@property (strong) NSMenu *statusMenu;

- (void)setState:(CHStatusItemState)state;

@end
