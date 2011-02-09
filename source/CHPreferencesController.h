//
//  CHPreferencesController.h
//  Crosshairs
//
//  Created by Zach Waugh on 10/5/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ShortcutRecorder/ShortcutRecorder.h>

@interface CHPreferencesController : NSWindowController <NSToolbarDelegate>
{
  IBOutlet NSButton *startAtLogin;
  IBOutlet NSColorWell *primaryColorWell;
  IBOutlet NSColorWell *alternateColorWell;
  IBOutlet SRRecorderControl *shortcutRecorder;
  IBOutlet NSToolbar *toolbar;
}

@property (assign) NSToolbar *toolbar;
@property (assign) NSButton *startAtLogin;
@property (assign) NSColorWell *primaryColorWell;
@property (assign) NSColorWell *alternateColorWell;
@property (assign) SRRecorderControl *shortcutRecorder;

- (void)toolbarItemSelected:(id)sender;
- (void)colorUpdated:(id)sender;
- (void)toggleStartAtLogin:(id)sender;

@end
