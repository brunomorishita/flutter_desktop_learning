#include "al.h"
#include "alc.h"
#include "alext.h"

#include <chrono>
#include <iostream>

#include "native_openal_soft.h"

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32)
#define IS_WIN32
#endif

#ifdef IS_WIN32
#include <windows.h>
#endif

typedef struct Recorder {
    ALCdevice *mDevice;

    FILE *mFile;
    long mDataSizeOffset;
    ALuint mDataSize;
    float mRecTime;

    ALuint mChannels;
    ALuint mBits;
    ALuint mSampleRate;
    ALuint mFrameSize;
    ALbyte *mBuffer;
    ALsizei mBufferSize;
} Recorder;

// Avoiding name mangling
extern "C" {
    void init() {
        Recorder recorder;

        recorder.mDevice = NULL;
        recorder.mFile = NULL;
        recorder.mDataSizeOffset = 0;
        recorder.mDataSize = 0;
        recorder.mRecTime = 4.0f;
        recorder.mChannels = 1;
        recorder.mBits = 16;
        recorder.mSampleRate = 44100;
        recorder.mFrameSize = recorder.mChannels * recorder.mBits / 8;
        recorder.mBuffer = NULL;
        recorder.mBufferSize = 0;

        std::cout << "Calling init yay!" << std::endl;
    }
}