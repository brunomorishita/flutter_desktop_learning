#include "native_sdl.h"
#include "AudioRecordingManager.h"

#include <iostream>

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32)
#define IS_WIN32
#endif

#ifdef IS_WIN32
#include <windows.h>
#endif

static AudioRecordingManager audioRecordingManager;

// Avoiding name mangling
extern "C" {
void init() {
    audioRecordingManager.init();
}
}  // extern "C"