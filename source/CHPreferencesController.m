//
//  CHPreferencesController.m
//  Crosshairs
//
//  Created by Zach Waugh on 10/5/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CHPreferencesController.h"
#import "CHPreferences.h"
#import "CHGlobals.h"
#import "MPLoginItems.h"
#import "DDHotKeyCenter.h"

@implementation CHPreferencesController

@synthesize toolbar, startAtLogin, primaryColorWell, alternateColorWell, shortcutRecorder;

- (void)awakeFromNib
{
  [self.shortcutRecorder setKeyCombo:SRMakeKeyCombo([CHPreferences globalHotKeyCode], [CHPreferences globalHotKeyFlags])];
  [self.toolbar setSelectedItemIdentifier:@"general"];
  
  NSURL *appPath = [[NSBundle mainBundle] bundleURL];
  BOOL loginItemExists = [MPLoginItems loginItemExists:appPath];
  [self.startAtLogin setState:(loginItemExists) ? NSOnState : NSOffState];
}


- (void)dealloc
{
  self.toolbar = nil;
  self.startAtLogin = nil;
  self.alternateColorWell = nil;
  self.primaryColorWell = nil;
  self.shortcutRecorder = nil;
  
  [super dealloc];
}


// Only one option, do nothing
- (void)toolbarItemSelected:(id)sender
{
  
}


- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
{
  KeyCombo keyCombo = [aRecorder keyCombo];
  [CHPreferences setGlobalHotKeyCode:keyCombo.code];
  [CHPreferences setGlobalHotKeyFlags:keyCombo.flags];
  
  DDHotKeyCenter *hotKeyCenter = [[[DDHotKeyCenter alloc] init] autorelease];
  
  [hotKeyCenter unregisterHotKeysWithTarget:[NSApp delegate]];
  [hotKeyCenter registerHotKeyWithKeyCode:keyCombo.code modifierFlags:keyCombo.flags target:[NSApp delegate] action:@selector(hotkeyWithEvent:) object:nil];
}


- (void)colorUpdated:(id)sender
{  
  if (sender == primaryColorWell)
  {
    [[NSNotificationCenter defaultCenter] postNotificationName:CHColorsDidChangeNotification object:self userInfo:[NSDictionary dictionaryWithObject:[primaryColorWell color] forKey:CHPrimaryOverlayColorKey]];
  }
  else if (sender == alternateColorWell)
  {
    [[NSNotificationCenter defaultCenter] postNotificationName:CHColorsDidChangeNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[alternateColorWell color] forKey:CHAlternateOverlayColorKey]];
  }
}


- (void)toggleStartAtLogin:(id)sender
{
  NSURL *appPath = [[NSBundle mainBundle] bundleURL];
  BOOL wantsToStartAtLogin = [sender state];
  BOOL loginItemEnabled = [MPLoginItems loginItemExists:appPath];
  
  if (wantsToStartAtLogin && !loginItemEnabled)
  {
    [MPLoginItems addLoginItemWithURL:appPath];
  }
  
  if (!wantsToStartAtLogin && loginItemEnabled)
  {
    [MPLoginItems removeLoginItemWithURL:appPath];
  }
}


@end
