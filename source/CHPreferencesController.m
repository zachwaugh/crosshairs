//
//  CHPreferencesController.m
//  Crosshairs
//
//  Created by Zach Waugh on 10/5/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CHPreferencesController.h"
#import "CHPreferences.h"
#import "CHAppDelegate.h"
#import "CHGlobals.h"
#import "DDHotKeyCenter.h"

@implementation CHPreferencesController

- (id)init
{
    self = [super initWithWindowNibName:@"CHPreferencesController"];
	if (!self) return nil;
    
    return self;
}

- (void)awakeFromNib
{
    //[self.shortcutRecorder setKeyCombo:SRMakeKeyCombo([CHPreferences globalHotKeyCode], [CHPreferences globalHotKeyFlags])];
    [self.toolbar setSelectedItemIdentifier:@"general"];
}

// Only one option, do nothing
- (void)toolbarItemSelected:(id)sender
{
    
}

//- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
//{
//  KeyCombo keyCombo = [aRecorder keyCombo];
//  [CHPreferences setGlobalHotKeyCode:keyCombo.code];
//  [CHPreferences setGlobalHotKeyFlags:keyCombo.flags];
//
//  DDHotKeyCenter *hotKeyCenter = [[[DDHotKeyCenter alloc] init] autorelease];
//
//  [hotKeyCenter unregisterHotKeysWithTarget:[NSApp delegate]];
//  [hotKeyCenter registerHotKeyWithKeyCode:keyCombo.code modifierFlags:keyCombo.flags target:[NSApp delegate] action:@selector(hotkeyWithEvent:) object:nil];
//}


- (void)colorUpdated:(id)sender
{
    if (sender == self.primaryColorWell) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CHColorsDidChangeNotification object:self userInfo:@{ CHPrimaryOverlayColorKey: self.primaryColorWell.color }];
    } else if (sender == self.alternateColorWell) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CHColorsDidChangeNotification object:nil userInfo:@{ CHAlternateOverlayColorKey: self.alternateColorWell.color }];
    }
}

- (void)toggleStartAtLogin:(id)sender
{
    
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(id)sender
{
    [NSApp hide:sender];
}

@end
