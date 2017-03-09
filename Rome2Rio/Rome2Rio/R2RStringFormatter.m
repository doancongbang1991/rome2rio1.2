//
//  R2RStringFormatters.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 20/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RStringFormatter.h"
#import "R2RDuration.h"


@implementation R2RStringFormatter

+(id) alloc
{
    [NSException raise:@"R2RStringFormatters is static" format:@"R2RStringFormatters is static"];
    return nil;
}

#pragma mark - Multi label descriptions
+(NSString *)formatFlightHopCellDuration:(float)minutes
{
    return [NSString stringWithFormat:@"%@ by plane", [R2RStringFormatter formatDuration:minutes]];
}

+(NSString *)formatFlightHopCellStops:(NSInteger)stops
{
    return [R2RStringFormatter formatStopovers:stops];
}

+(NSString *)formatTransitHopCellDuration:(float)minutes changes:(NSInteger)changes vehicle:(NSString *)vehicle line:(NSString *)line
{
    if (changes == 0)
    {
        if ([line length] > 0)
            return [NSString stringWithFormat:@"%@ by %@ %@", [R2RStringFormatter formatDuration:minutes], line, vehicle];
        else
            return [NSString stringWithFormat:@"%@ by %@", [R2RStringFormatter formatDuration:minutes], vehicle];
    }
    else if (changes == 1)
    {
        return [NSString stringWithFormat:@"%@ by %@, 1 change", [self formatDuration:minutes], vehicle];
    }
    else if (changes >= 2)
    {
        return [NSString stringWithFormat:@"%@ by %@, %ld changes", [self formatDuration:minutes], vehicle, (long)changes];
    }
    return nil;
}

+(NSString *)formatTransitHopCellFrequency:(float)frequency
{
    NSString *frequencyString = [R2RStringFormatter formatFrequency:frequency];
    
    // Uppercase first letter
    return [[[frequencyString substringToIndex:1] uppercaseString] stringByAppendingString:[frequencyString substringFromIndex:1]];
}

+(NSString *)formatWalkDriveHopCellDuration:(float)minutes vehicle:(NSString *)vehicle
{
    return [NSString stringWithFormat:@"%@ by %@", [self formatDuration:minutes], vehicle];
}

+(NSString *)formatWalkDriveHopCellDistance:(float)distance isImperial:(bool)isImperial
{
    return [self formatDistance:distance isImperial:isImperial];
}

#pragma mark - Helpers
+(NSString *) formatDuration: (float) minutes
{
    R2RDuration *duration = [[R2RDuration alloc] initWithMinutes:minutes];
    
    if (duration.totalHours >= 48)
    {
        return [NSString stringWithFormat:@"%lddays %ldhrs", (long)duration.days, (long)duration.hours];
    }
    else if (duration.totalHours < 1)
    {
        return [NSString stringWithFormat:@"%ldmin", (long)duration.minutes];
    }
    else
    {
        if (duration.minutes == 0)
        {
            return [NSString stringWithFormat:@"%ldhrs", (long)duration.totalHours];
        }
        else
        {
            return [NSString stringWithFormat:@"%ldhrs %ldmin", (long)duration.totalHours, (long)duration.minutes];
        }
    }
}

+(NSString *) formatDurationZeroPadded:(float)minutes
{
    R2RDuration *duration = [[R2RDuration alloc] initWithMinutes:minutes];
    
    if (duration.totalHours >= 48)
    {
        return [NSString stringWithFormat:@"%lddays %ldhrs", (long)duration.days, (long)duration.hours];
    }
    else if (duration.totalHours < 1)
    {
        return [NSString stringWithFormat:@"%ldmin", (long)duration.minutes];
    }
    else
    {
        return [NSString stringWithFormat:@"%ldhrs %ldmin", (long)duration.totalHours, (long)duration.minutes];
    }
}

+(NSString *) formatFrequency: (float) frequency
{
    long weekFrequency = lroundf(frequency);
    if (weekFrequency <= 1)
    {
        return @"once a week";
    }
    if (weekFrequency == 2)
    {
        return @"twice a week";
    }
    if (weekFrequency < 7)
    {
        return [NSString stringWithFormat:@"%ld times a week", weekFrequency];
    }
    
    NSInteger dayFrequency = lroundf(frequency/7);
    
    if (dayFrequency == 1)
    {
        return @"once daily";
    }
    if (dayFrequency == 2)
    {
        return @"twice daily";
    }
    if (dayFrequency < 6)
    {
        return [NSString stringWithFormat:@"%ld times a day", (long)dayFrequency];
    }
    if (dayFrequency < 9)
    {
        return @"every 4 hours";
    }
    if (dayFrequency < 11)
    {
        return @"every 3 hours";
    }
    if (dayFrequency < 13)
    {
        return @"every 2 hours";
    }
    
    NSInteger hourFrequency = lroundf(frequency/7/24);
    
    if (hourFrequency == 1)
    {
        return @"hourly";
    }
    if (hourFrequency == 2)
    {
        return @"every 30 minutes";
    }
    if (hourFrequency == 3)
    {
        return @"every 20 minutes";
    }
    if (hourFrequency == 4 || hourFrequency == 5)
    {
        return @"every 15 minutes";
    }
    if (hourFrequency <= 10)
    {
        return @"every 10 minutes";
    }
    
    return @"every 5 minutes";
}

+(NSString *) formatDistance:(float) distance isImperial:(bool)isImperial
{
    if (isImperial)
    {
        if (distance < 1.6)
        {
            return [NSString stringWithFormat:@"%.0f feet", distance*3.28084*1000];
        }
        else
        {
            return [NSString stringWithFormat:@"%.0f miles", distance*0.62137];
        }
    }
    else
    {
        if (distance < 1)
        {
            return [NSString stringWithFormat:@"%.0f m", distance*1000];
        }
        else if(distance < 100)
        {
            return [NSString stringWithFormat:@"%.1f km", distance];
        }
        else
        {
            return [NSString stringWithFormat:@"%.0f km", distance];
        }
    }
}

+(NSString *) formatDays: (NSInteger) days
{
	NSString *labels[] = { @"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat" };

	if (days == 0x7F)		// every day
		return @"Daily";

	else if (days == 0x3E)	// week days
		return @"Mon to Fri";

	else
	{
		NSMutableString *result = [[NSMutableString alloc] init];
		NSString *separator = @"";

		for (NSInteger day = 0; day < 7; day++)
		{
			if ((days & (1 << day)) != 0)
			{
				[result appendString:separator];
				[result appendString:labels[day]];
				separator = @" ";
			}
		}

		return result;
	}
}

+(NSString *) padNumber: (NSInteger) number
{
    if (number < 10)
    {
        return [NSString stringWithFormat:@"0%ld", (long)number];
    }
    else
    {
        return [NSString stringWithFormat:@"%ld", (long)number];
    }
}

+(NSString *) formatStopovers: (NSInteger) stops
{
    if (stops == 0)
    {
        return @"Non-stop";
    }
    else if (stops == 1)
    {
        return @"1 stopover";
    }
    else if (stops >= 2)
    {
        return [NSString stringWithFormat:@"%ld stopovers", (long)stops];
    }
    return @"";
}

+(NSString *)formatTransitHopVehicle:(NSString *) vehicle
{
    vehicle = [vehicle stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[vehicle substringToIndex:1] uppercaseString]];
    vehicle = [vehicle stringByAppendingString:@" from"];
    return vehicle;
}

+(NSString *) capitaliseFirstLetter: (NSString *) string
{
    string = [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string substringToIndex:1] uppercaseString]];
    return string;
}

+(NSString *)formatIndicativePrice:(R2RIndicativePrice *)indicativePrice
{
    if (indicativePrice.isFreeTransfer)
    {
        return NSLocalizedString(@"Transfer", nil);
    }
        
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setMaximumFractionDigits:0];
    [formatter setCurrencyCode:indicativePrice.currency];
    NSString *priceString = [formatter stringFromNumber:[NSNumber numberWithFloat: indicativePrice.price]];
    
    return priceString;
}


@end
