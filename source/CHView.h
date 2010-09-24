//
//  CHView.h
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CHView : NSView
{
	NSPoint startPoint;
	NSRect box;
	BOOL dragging;
	NSDictionary *textAttrs;
}

@property(assign) NSPoint startPoint;
@property(assign) NSRect box;
@property(assign) BOOL dragging;
@property(retain) NSDictionary *textAttrs;

@end
