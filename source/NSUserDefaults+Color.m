//
//  NSUserDefaults+Color.m
//  Crosshairs
//
//  Created by Zach Waugh on 10/31/10.
//  Copyright 2010 Giant Comet. All rights reserved.
//

#import "NSUserDefaults+Color.h"


@implementation NSUserDefaults (Color)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey
{
  NSData *theData = [NSArchiver archivedDataWithRootObject:aColor];
  [self setObject:theData forKey:aKey];
}


- (NSColor *)colorForKey:(NSString *)aKey
{
  NSColor *theColor = nil;
  NSData *theData = [self dataForKey:aKey];
  
  if (theData != nil)
  {
    theColor = (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
  }
    
  return theColor;
}

@end
