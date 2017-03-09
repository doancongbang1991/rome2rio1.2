//
//  R2RCompletionState.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 12/11/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

typedef enum
{
    r2rCompletionStateIdle = 0,
    r2rCompletionStateResolving,
    r2rCompletionStateResolved,
    r2rCompletionStateLocationNotFound,
    r2rCompletionStateError
} R2RCompletionState;