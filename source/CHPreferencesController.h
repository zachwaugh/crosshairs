//
//  CHPreferencesController.h
//  Crosshairs
//
//  Created by Zach Waugh on 10/5/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CHPreferencesController : NSWindowController <NSToolbarDelegate>

@property (nonatomic, weak) IBOutlet NSToolbar *toolbar;
@property (nonatomic, weak) IBOutlet NSButton *startAtLogin;
@property (nonatomic, weak) IBOutlet NSColorWell *primaryColorWell;
@property (nonatomic, weak) IBOutlet NSColorWell *alternateColorWell;

- (IBAction)toolbarItemSelected:(id)sender;
- (IBAction)colorUpdated:(id)sender;
- (IBAction)toggleStartAtLogin:(id)sender;

@end
