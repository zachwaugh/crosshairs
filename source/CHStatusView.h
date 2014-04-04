//
//  CHStatusView.h
//  Crosshairs
//
//  Created by Zach Waugh on 2/8/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, CHStatusItemState) {
    CHStatusItemDefault = 0,
    CHStatusItemHighlighted,
    CHStatusItemActive
};

@interface CHStatusView : NSView <NSMenuDelegate>

@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSMenu *statusMenu;
@property (nonatomic, assign) CHStatusItemState state;

@end
