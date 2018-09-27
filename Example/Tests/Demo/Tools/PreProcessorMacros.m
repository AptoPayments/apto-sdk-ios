//
//  PreprocessorMacros.m
//  LedgeLink
//
//  Created by Ivan Oliver Martínez on 16/02/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

#import "PreprocessorMacros.h"

#ifdef DEV
BOOL const DEBUG_BUILD = YES;
#else
BOOL const DEBUG_BUILD = NO;
#endif

#ifdef ALPHA
BOOL const ALPHA_BUILD = YES;
#else
BOOL const ALPHA_BUILD = NO;
#endif

#ifdef BETA
BOOL const BETA_BUILD = YES;
#else
BOOL const BETA_BUILD = NO;
#endif

#ifdef RELEASE
BOOL const RELEASE_BUILD = YES;
#else
BOOL const RELEASE_BUILD = NO;
#endif