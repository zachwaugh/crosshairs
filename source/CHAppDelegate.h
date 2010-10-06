//
//  CrosshairsAppDelegate.h
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CHWindow;
@class CHView;

@interface CHAppDelegate : NSObject <NSApplicationDelegate>
{
	CHWindow *window;
	CHView *view;
	NSStatusItem *statusItem;
	IBOutlet NSMenu *statusMenu;
}

@property (assign) IBOutlet CHWindow *window;
@property (assign) IBOutlet CHView *view;
@property (retain) NSStatusItem *statusItem;
@property (retain) NSMenu *statusMenu;

- (void)activateApp:(id)sender;
- (void)showPreferences:(id)sender;
- (void)openWebsite:(id)sender;

@end
