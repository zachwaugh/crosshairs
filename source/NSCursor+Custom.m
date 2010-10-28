//
//  NSCursor+Custom.m
//  Dimensions
//
//  Created by Zach Waugh on 10/16/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "NSCursor+Custom.h"


@implementation NSCursor (Custom)

//+ (NSCursor *)arrowCursor
//{
//	return [NSCursor crosshairsCursor];
//}


+ (NSCursor *)crosshairsCursor 
{ 
	static NSCursor *crosshairsCursor = nil; 
	
	if (!crosshairsCursor)
	{ 
		crosshairsCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"crosshairs_cursor.png"] hotSpot:NSMakePoint(12, 12)]; 
	}
	
	return crosshairsCursor; 
}


+ (NSCursor *)resizeLeftDiagonalCursor 
{ 
	static NSCursor *resizeLeftDiagonalCursor = nil;
	
	if (!resizeLeftDiagonalCursor)
	{ 
		resizeLeftDiagonalCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"resize_cursor_diagonal_left.tiff"] hotSpot:NSMakePoint(8, 8)]; 
	} 

	return resizeLeftDiagonalCursor; 
}


+ (NSCursor *)resizeRightDiagonalCursor 
{ 
	static NSCursor *resizeRightDiagonalCursor = nil;
	
	if (!resizeRightDiagonalCursor)
	{ 
		resizeRightDiagonalCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"resize_cursor_diagonal_right.tiff"] hotSpot:NSMakePoint(8, 8)]; 
	} 
	
	return resizeRightDiagonalCursor; 
}


@end
