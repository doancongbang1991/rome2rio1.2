//
//  R2RPrintSearch.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 5/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "R2RSearchResponse.h"

@interface R2RPrintSearch : NSObject

-(void) printSearchData :(R2RSearchResponse*)searchData;

@end
