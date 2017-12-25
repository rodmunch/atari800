//
//  Atari800EmulationThread.m
//  Atari800EmulationCore-macOS
//
//  Created by Rod Münch on 20/12/2017.
//  Copyright © 2017 Atari800 development team. All rights reserved.
//

#import "Atari800EmulationThread.h"
#import "Atari800Emulator.h"
#import "Atari800Renderer.h"

#include "antic.h"
#include "atari.h"
#include "binload.h"
#include "gtia.h"
#include "input.h"
#include "akey.h"
#include "log.h"
#include "monitor.h"
#include "platform.h"

@interface Atari800EmulationThread() {
@public
    Atari800Emulator *_emulator;
    __unsafe_unretained id<Atari800Renderer> _renderer;
    __unsafe_unretained Atari800KeyboardHandler _keyboardHandler;
    BOOL _atari800Running;
}

@end

static Atari800EmulationThread *atari800EmulationThread;

int VIDEOMODE_80_column;


void PLATFORM_DisplayScreen(void)
{
    //memcpy(atari800EmulationThread->_renderer.screen, Screen_atari, 384 * 240 * sizeof(uint8_t));
}

int PLATFORM_Exit(int run_monitor) {
    
    return noErr;
}

int PLATFORM_Initialise(int *argc, char *argv[])
{
    
    return TRUE;
}

int PLATFORM_Keyboard(void) { return 0; }

int PLATFORM_PORT(int num) { return 0xff; }

int PLATFORM_TRIG(int num) { return 1; }

int VIDEOMODE_Set80Column(int value)
{
    
    VIDEOMODE_80_column = value;
    return value;
}

void Atari800StartEmulation(__unsafe_unretained Atari800EmulationThread *thread)
{
    atari800EmulationThread = thread;
    
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"Atari800EmulationThread")];
    const char *bundlePath = [[bundle.resourcePath stringByAppendingPathComponent:@"Resources"] UTF8String];
    int argc = 1;
    const char **argv = {&bundlePath};
    
    Screen_atari = (unsigned int *)atari800EmulationThread->_renderer.screen;
    
    if (!Atari800_Initialise(&argc, (char **)argv)) {
        
        return;
    }
    
    atari800EmulationThread->_atari800Running = YES;
    
    // HACK: Load something for now
    NSString *exeFilePath = [bundle pathForResource:@"Colossal Adventure"
                                             ofType:@"xex"
                                        inDirectory:@"XEX"];
    const char *exeName = [exeFilePath cStringUsingEncoding:NSUTF8StringEncoding];
    BINLOAD_Loader(exeName);
    
    while (atari800EmulationThread->_atari800Running) {
        
        if (atari800EmulationThread->_keyboardHandler) {
            
            int keycode = 0;
            int controlKey = 0;
            int shiftKey = 0;
            
            atari800EmulationThread->_keyboardHandler(&keycode, &shiftKey, &controlKey);
            
            INPUT_key_code = (shiftKey) ? keycode | AKEY_SHFT : keycode;
        }
        else {
            
            INPUT_key_code = AKEY_NONE;
        }
        
        Atari800_Frame();
        if (Atari800_display_screen)
            PLATFORM_DisplayScreen();
    }
}

@implementation Atari800EmulationThread

- (instancetype)initWithEmulator:(Atari800Emulator *)emulator
{
    self = [super init];
    
    if (self) {
        
        _emulator = emulator;
        _keyboardHandler = emulator.keyboardHandler;
        _renderer = emulator.renderer;
    }
    
    return self;
}

- (void)main
{
    @autoreleasepool {
        Atari800StartEmulation(self);
    }
}

- (void)pause
{
    // TODO: Implement this
}

- (void)cancel
{
    _atari800Running = NO;
    [super cancel];
}

@end
