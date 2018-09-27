//
//  PreprocessorMacros.m
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 16/02/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

#import "PreProcessorMacros.h"

#ifdef LOCAL
BOOL const LOCAL_BUILD = YES;
#else
BOOL const LOCAL_BUILD = NO;
#endif

#ifdef DEV
BOOL const DEV_BUILD = YES;
#else
BOOL const DEV_BUILD = NO;
#endif

#ifdef STG
BOOL const STG_BUILD = YES;
#else
BOOL const STG_BUILD = NO;
#endif

#ifdef SBX
BOOL const SBX_BUILD = YES;
#else
BOOL const SBX_BUILD = NO;
#endif

#ifdef PRD
BOOL const PRD_BUILD = YES;
#else
BOOL const PRD_BUILD = NO;
#endif
