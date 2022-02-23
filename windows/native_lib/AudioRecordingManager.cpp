#include "AudioRecordingManager.h"

#include <iostream>
#include <functional>

#define IS_WIN32 defined(WIN32) || defined(_WIN32) || defined(__WIN32)

#ifdef IS_WIN32
#include <windows.h>
#endif

static void audioRecordingCallback(void* userdata, Uint8* stream, int len )
{
    AudioRecordingManager* recordManager = (AudioRecordingManager*) userdata;
    recordManager->processReceivedSpec(stream, len);
}

AudioRecordingManager::AudioRecordingManager(AudioConfig audioConfig) {
  m_audioConfig = audioConfig;
}

AudioRecordingManager::~AudioRecordingManager() {
    delete[] m_buffer;
    if(t0.joinable())
        t0.join();
}

void AudioRecordingManager::init(const char* wavFile) {
    std::cout << "==> AudioRecordingManager::init" << std::endl;

    if (SDL_Init(SDL_INIT_AUDIO) != 0) {
        std::cout << "SDL_Init Error: " << SDL_GetError() << std::endl;
        return;
    }

    createWavFile(wavFile);

    SDL_AudioDeviceID playbackDeviceId = 0;

    SDL_zero(m_desiredSpec);
    m_desiredSpec.freq = m_audioConfig.frequency;
    m_desiredSpec.format = AUDIO_F32;
    m_desiredSpec.channels = m_audioConfig.channels;
    m_desiredSpec.samples = m_audioConfig.samples;
    m_desiredSpec.userdata = this;
    m_desiredSpec.callback = audioRecordingCallback;

    SDL_zero(m_receivedSpec);

    m_deviceCount = SDL_GetNumAudioDevices(SDL_TRUE);

    if(m_deviceCount < 1)
    {
        printf( "Unable to get audio capture device! SDL Error: %s\n", SDL_GetError() );
        return;
    }

    // pick the first audio device
    int audioIndex = 0;

    const char *device = SDL_GetAudioDeviceName(audioIndex, SDL_TRUE);
    printf( " device is %s\n", device );

    //Open recording device
    m_deviceId = SDL_OpenAudioDevice(device, SDL_TRUE,
                                     &m_desiredSpec, &m_receivedSpec, SDL_AUDIO_ALLOW_ANY_CHANGE);

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
    m_buffer = new Uint8[m_bufferByteSize];
    std::memset(m_buffer, 0, m_bufferByteSize);

    t0 = std::thread([&]() { consumeAudio(); });
}

void AudioRecordingManager::start() {
    SDL_PauseAudioDevice( m_deviceId, SDL_FALSE );
}

void AudioRecordingManager::stop() {
	SDL_LockAudioDevice( m_deviceId );
	SDL_PauseAudioDevice( m_deviceId, SDL_TRUE );
	SDL_UnlockAudioDevice( m_deviceId );

	SDL_CloseAudioDevice( m_deviceId );

	SDL_Quit();

    std::cout << "==> AudioRecordingManager::stop == "<< std::endl;

	m_finished = true;
	m_cv.notify_one();
	if(t0.joinable())
	    t0.join();
}

void AudioRecordingManager::processReceivedSpec(Uint8* stream, int len ) {
    std::cout << "==> AudioRecordingManager::processReceivedSpec ==, len = "<< len << std::endl;

    //Copy audio from stream
	std::memcpy(&m_buffer[ m_bufferWritePosition ], stream, len);

	//Move along buffer
	m_bufferWritePosition += len;

	m_cv.notify_one();
}

void AudioRecordingManager::createWavFile(const std::string& fileName) {
    m_wavFile.open(fileName, std::ios::out | std::ios::binary);
}

void AudioRecordingManager::consumeAudio() {
    do {
        std::unique_lock<std::mutex> lock(m_mutex);
        while (m_bufferWritePosition == m_bufferReadPosition && !m_finished )
        {
            std::cout << "==> waiting " << std::endl;
            m_cv.wait(lock, [&](){ return (m_bufferWritePosition > m_bufferReadPosition) || m_finished; });
        }

        int len =  m_bufferWritePosition - m_bufferReadPosition;

        std::cout << "==> writing " << sizeof(Uint8) * len << " bytes into wav file" << std::endl;
        char *buffer_raw = (char *) &m_buffer[ m_bufferReadPosition ];
        m_wavFile.write(buffer_raw, sizeof(Uint8) * len);

        //Move along buffer
        m_bufferReadPosition += len;

    } while(!m_finished);

    std::cout << "finished" << std::endl;

    m_wavFile.close();
}