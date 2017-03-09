//
//  R2RLog.h
//  rome2rio
//
//  Created by Ash Verdoorn on 12/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#ifndef rome2rio_R2RLog_h
#define rome2rio_R2RLog_h

#import <Foundation/Foundation.h>

#ifdef DEBUG
#   define R2RLog(__FORMAT__, ...) NSLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define R2RLog(__FORMAT__, ...) do {} while (0)
#endif

#endif
