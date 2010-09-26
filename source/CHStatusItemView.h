//
//  CHStatusItemView.h
//  Crosshairs
//
//  Created by Zach Waugh on 9/26/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CHStatusItemView : NSView
{
	id delegate;
	NSImage *image;
	BOOL highlighted;
}

@property (assign) id delegate;
@property (assign) BOOL highlighted;
@property (retain) NSImage *image;

@end
