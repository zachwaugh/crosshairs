//
//  CHMenuItemView.m
//  Crosshairs
//
//  Created by Zach Waugh on 10/5/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CHMenuItemView.h"


@implementation CHMenuItemView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[[NSImage imageNamed:@"beta_warning"] drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

@end
