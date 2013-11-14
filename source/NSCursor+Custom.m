//
//  NSCursor+Custom.m
//  Crosshairs
//
//  Created by Zach Waugh on 10/16/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "NSCursor+Custom.h"

@implementation NSCursor (Custom)

+ (NSCursor *)crosshairsCursor 
{
  static NSCursor *_crosshairsCursor = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _crosshairsCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"crosshairs_cursor"] hotSpot:NSMakePoint(11, 11)];
  });
  
	return _crosshairsCursor;
}

+ (NSCursor *)resizeLeftDiagonalCursor 
{
  static NSCursor *_resizeLeftDiagonalCursor = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _resizeLeftDiagonalCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"resize_cursor_diagonal_left"] hotSpot:NSMakePoint(8, 8)];
  });

	return _resizeLeftDiagonalCursor;
}

+ (NSCursor *)resizeRightDiagonalCursor 
{
  static NSCursor *_resizeRightDiagonalCursor = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _resizeRightDiagonalCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"resize_cursor_diagonal_right"] hotSpot:NSMakePoint(8, 8)];
  });
  
	return _resizeRightDiagonalCursor;
}

@end
