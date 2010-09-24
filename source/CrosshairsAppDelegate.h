//
//  CrosshairsAppDelegate.h
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CrosshairsAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
