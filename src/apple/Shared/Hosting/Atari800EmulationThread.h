//
//  Atari800EmulationThread.h
//  Atari800EmulationCore
//
//  Created by Rod Münch on 20/12/2017.
//  Copyright © 2017 Atari800 development team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Atari800Emulator.h"

typedef NS_ENUM(NSInteger, Atari800UICommandType) {
    
    Atari800CommandQuit,
    Atari800CommandBinaryLoad,
    Atari800CommandMountDisk,
    Atari800CommandInsertCartridge,
    Atari800CommandLoadCassette,
    Atari800CommandReset,
    Atari800CommandRemoveCartridge,
    Atari800CommandDismountDisk,
    Atari800CommandChangeVideoSystem,
    Atari800CommandChangeRAMSize,
    Atari800CommandChangeStereo,
};

typedef NS_ENUM(NSInteger, Atari800UICommandParamType) {
 
    Atari800CommandParamNotRequired = -1,
    Atari800CommandParamLeftCartridge,
    Atari800CommandParamRightCartridge,
    Atari800CommandParamPALVideoSystem,
    Atari800CommandParamNTSCVideoSystem
};

@class Atari800EmulationThread;

void Atari800UICommandEnqueue(Atari800UICommandType command, Atari800UICommandParamType param, NSInteger intParam, NSArray<NSString *> *parameters, Atari800CompletionHandler completion);

@interface Atari800EmulationThread : NSThread

- (instancetype)initWithEmulator:(Atari800Emulator *)emulator;

@end
