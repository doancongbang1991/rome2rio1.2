//
//  R2RPathEncoder.m
//  Rome2Rio
//
//  Created by Bernie Tschirren.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RPathEncoder.h"

@implementation R2RPathEncoder

+ (NSString *)encode:(R2RPath *)path
{
	NSMutableString *data = [[NSMutableString alloc] init];
	
	int prevLat = 0;
	int prevLng = 0;
	
	for (R2RPosition *position in [path positions])
	{
		// Round to 5 decimal places and drop the decimal
		int lat = (int)((position.lat * 1e5f) + 0.5f);
		int lng = (int)((position.lng * 1e5f) + 0.5f);

		// Encode the differences between the coordinates
        
        [self encodeNumber:data number:lat - prevLat];
        [self encodeNumber:data number:lng - prevLng];

		// Store the current coordinates
		prevLat = lat;
		prevLng = lng;
	}

	return data;
}

+ (void)encodeNumber:(NSMutableString *)data number:(int) number
{
	number = (number < 0) ? ~(number << 1) : (number << 1);

	while (number >= 0x20)
	{
		[data appendFormat:@"%c", (char)((0x20 | (number & 0x1f)) + 63)];
		number >>= 5;
	}

	[data appendFormat:@"%c", (char)(number + 63)];
}

+ (R2RPath *)decode:(NSString *)data
{
    return [self decode:data :nil];
}

+(R2RPath *)decode:(NSString *)data :(R2RPath *)path
{
    if (!path)
    {
        path = [[R2RPath alloc] init];
	}
    
	long length = [data length];
	int index = 0;
	int lat = 0;
	int lng = 0;

	while (index < length)
	{
		lat += [self decodeNumber:data index:&index];
		lng += [self decodeNumber:data index:&index];

		R2RPosition *position = [[R2RPosition alloc] init];
		position.lat = lat / 1e5f;
		position.lng = lng / 1e5f;

		[path addPosition:position];
	}

	return path;
}

+ (int)decodeNumber:(NSString *)data index:(int *) index
{
	long length = [data length];
	int number = 0;
	
	if (*index < length)
	{
		int shifter = 0;
		int bits = 0;
		
		do
		{
			bits = (int)[data characterAtIndex:(*index)++] - 63;
			number |= (bits & 31) << shifter;
			shifter += 5;
		} while (bits >= 0x20 && *index < length);
	}
	
	number = (number & 1) != 0 ? ~(number >> 1) : (number >> 1);

	return number;
}

@end