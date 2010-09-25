//
//  CrosshairsAppDelegate.h
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CHWindow;

@interface CrosshairsAppDelegate : NSObject <NSApplicationDelegate>
{
	CHWindow *window;
	NSStatusItem *statusItem;
}

@property (assign) IBOutlet CHWindow *window;
@property (retain) NSStatusItem *statusItem;

@end
