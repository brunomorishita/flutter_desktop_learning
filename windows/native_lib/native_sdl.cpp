#include "native_sdl.h"
#include "AudioRecordingManager.h"

#include <iostream>
#include <memory>

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32)
#define IS_WIN32
#endif

#ifdef IS_WIN32
#include <windows.h>
#endif

static std::unique_ptr<AudioRecordingManager> audioRecordingManager = nullptr;

// Avoiding name mangling
extern "C" {
void init(char* wavFile) {
    AudioRecordingManager::AudioConfig audioConfig;
    audioRecordingManager = std::make_unique<AudioRecordingManager>(audioConfig);

    audioRecordingManager->init(wavFile);
}

void start() {
    audioRecordingManager->start();
}

void stop() {
    audioRecordingManager->stop();
}

}  // extern "C"