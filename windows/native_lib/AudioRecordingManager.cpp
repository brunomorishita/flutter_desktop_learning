#include "AudioRecordingManager.h"

#include <iostream>
#include <functional>

static void audioRecordingCallback(void* userdata, Uint8* stream, int len )
{
    AudioRecordingManager* recordManager = (AudioRecordingManager*) userdata;
    recordManager->processReceivedSpec(stream, len);
}

void AudioRecordingManager::init() {
    using namespace std::placeholders;

    if (SDL_Init(SDL_INIT_AUDIO) != 0) {
        std::cout << "SDL_Init Error: " << SDL_GetError() << std::endl;
        return;
    }

    SDL_AudioDeviceID playbackDeviceId = 0;

    SDL_zero(m_desiredSpec);
    m_desiredSpec.freq = 44100;
    m_desiredSpec.format = AUDIO_S16;
    m_desiredSpec.channels = 2;
    m_desiredSpec.samples = 4096;
    m_desiredSpec.userdata = this;
    m_desiredSpec.callback = audioRecordingCallback;

    m_deviceCount = SDL_GetNumAudioDevices(SDL_TRUE);

    if(m_deviceCount < 1)
    {
        printf( "Unable to get audio capture device! SDL Error: %s\n", SDL_GetError() );
        return;
    }

    // pick the first audio device
    int audioIndex = 0;

    //Open recording device
    m_deviceId = SDL_OpenAudioDevice(SDL_GetAudioDeviceName(audioIndex, SDL_TRUE), SDL_TRUE,
                                     &m_desiredSpec, &m_receivedSpec, SDL_AUDIO_ALLOW_FORMAT_CHANGE);

    // Device failed to open
    if(m_deviceId == 0)
    {
        // Report error
        printf("Failed to open recording device! SDL Error: %s", SDL_GetError() );
        return;
    }

    //Calculate per sample bytes
    int bytesPerSample = m_receivedSpec.channels * (SDL_AUDIO_BITSIZE(m_receivedSpec.format) / 8);

    //Calculate bytes per second
    int bytesPerSecond = m_receivedSpec.freq * bytesPerSample;

    //Calculate buffer size
    m_bufferByteSize = m_bufferSeconds * bytesPerSecond;

    //Allocate and initialize byte buffer
    m_buffer = std::make_unique<Uint8[]>(m_bufferByteSize);
    std::memset(m_buffer.get(), 0, m_bufferByteSize);
}

void AudioRecordingManager::start() {
}

void AudioRecordingManager::stop() {
}

void AudioRecordingManager::processReceivedSpec(Uint8* stream, int len ) {
    //Copy audio from stream
	std::memcpy(&m_buffer[ m_bufferWritePosition ], stream, len);

	//Move along buffer
	m_bufferWritePosition += len;
}