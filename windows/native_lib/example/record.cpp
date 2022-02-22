#include "AudioRecordingManager.h"

#undef main

#include <memory>
#include <string>
#include <chrono>
#include <thread>

int main (int argc, void **argv) {
    std::unique_ptr<AudioRecordingManager> audioRecordingManager = nullptr;
    AudioRecordingManager::AudioConfig audioConfig;
    audioRecordingManager = std::make_unique<AudioRecordingManager>(audioConfig);

    std::string wavFile = "record.wav";
    audioRecordingManager->init(wavFile.c_str());
    audioRecordingManager->start();
    std::this_thread::sleep_for(std::chrono::seconds(5));
    audioRecordingManager->stop();
    return 0;
}

