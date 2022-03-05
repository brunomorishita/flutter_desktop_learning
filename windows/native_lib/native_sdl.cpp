#include "native_sdl.h"
#include "AudioRecordingManager.h"
#include "AudioPlayManager.h"

#include <iostream>
#include <memory>

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32)
#define IS_WIN32
#endif

#ifdef IS_WIN32
#include <windows.h>
#endif

static std::unique_ptr<AudioRecordingManager> audioRecordingManager = nullptr;
static std::unique_ptr<AudioPlayManager> audioPlayManager = nullptr;

// Avoiding name mangling
extern "C" {
void record_init(char* wavFile) {
    AudioRecordingManager::AudioConfig audioConfig;
    audioRecordingManager = std::make_unique<AudioRecordingManager>(audioConfig);

    audioRecordingManager->init(wavFile);
}

void record_start() {
    audioRecordingManager->start();
}

void record_stop() {
    audioRecordingManager->stop();
}

void play_init(char* wavFile) {
    audioPlayManager = std::make_unique<AudioPlayManager>();
    audioPlayManager->init(wavFile);
}

void play_start() {
    audioPlayManager->start();
}

void play_stop() {
    audioPlayManager->stop();
}

}  // extern "C"