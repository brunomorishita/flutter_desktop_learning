#include "AudioPlayManager.h"

#undef main

#include <memory>
#include <string>
#include <chrono>
#include <thread>
#include <iostream>

int main (int argc, char **argv) {
    if (argc < 2)
    {
        std::cout << "missing parameter with wav file" << std::endl;
        return -1;
    }
    std::unique_ptr<AudioPlayManager> audioPlayManager = nullptr;
    audioPlayManager = std::make_unique<AudioPlayManager>();

    std::string wavFile = argv[1];
    audioPlayManager->init(wavFile.c_str());
    audioPlayManager->start();
    std::this_thread::sleep_for(std::chrono::seconds(5));
    audioPlayManager->stop();
    return 0;
}

